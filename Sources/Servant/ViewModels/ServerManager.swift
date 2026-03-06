import Foundation
import Combine
import SwiftUI

@MainActor
class ServerManager: ObservableObject {
    @Published var servers: [DevServer] = []
    
    // Lista de IDs dos servidores que já estão respondendo na porta HTTP local
    @Published var respondingServers: Set<UUID> = []
    
    // Gerenciadores de Tarefas Ativas (PIDs e Timers de Ping)
    private var runningProcesses: [UUID: Process] = [:]
    private var pingTimers: [UUID: Timer] = [:]
    
    private let userDefaultsKey = "devServersList"
    
    init() {
        loadServers()
        
        // Se a lista estiver vazia, carrega uns de exemplo
        if servers.isEmpty {
            servers = [
                DevServer(name: "Playground", directory: "~/Documents/Projects/Playground", port: "3000", startCommand: "npm run dev"),
                DevServer(name: "Sneakers Vault", directory: "~/Documents/Projects/Sneakers", port: "5173", startCommand: "npm run dev")
            ]
            saveServers()
        }
        
        // Garante que o estado inicie limpo após um possível erro prévio do App
        for i in 0..<servers.count {
            servers[i].isRunning = false
            servers[i].pid = nil
        }
    }
    
    // MARK: - Persistência UserDefaults
    func saveServers() {
        if let encoded = try? JSONEncoder().encode(servers) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadServers() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([DevServer].self, from: savedData) {
            self.servers = decoded
        }
    }
    
    // MARK: - Ações CRUD
    func addServer(_ server: DevServer) {
        servers.append(server)
        saveServers()
    }
    
    func updateServer(_ server: DevServer) {
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
            saveServers()
        }
    }
    
    func removeServer(at index: Int) {
        let server = servers[index]
        stopServer(id: server.id)
        servers.remove(at: index)
        saveServers()
    }
    
    // MARK: - Processamento de Servidor (Iniciar / Parar)
    func toggleServer(id: UUID) {
        if let index = servers.firstIndex(where: { $0.id == id }) {
            if servers[index].isRunning {
                stopServer(id: id)
            } else {
                startServer(id: id)
            }
        }
    }
    
    func startServer(id: UUID) {
        guard let index = servers.firstIndex(where: { $0.id == id }) else { return }
        
        let server = servers[index]
        let expandedPath = NSString(string: server.directory).expandingTildeInPath
        
        // Verifica se o diretório existe
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDir) || !isDir.boolValue {
            print("❌ Erro: Diretório não encontrado ou não é uma pasta: \(expandedPath)")
            return
        }

        let process = Process()
        let outputPipe = Pipe()
        
        // ZSH env para pegar coisas locais como `npm` e `yarn`
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        // IMPORTANTE: Escapar o path com aspas para suportar espaços. 
        // Adicionamos caminhos comuns ao PATH caso o shell não os carregue automaticamente.
        let command = "export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin; cd \"\(expandedPath)\" && \(server.startCommand)"
        process.arguments = ["-l", "-c", command]
        
        // Captura tanto a saída comum quanto erros no mesmo pipe para diagnóstico completo
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        // Monitora se o processo terminar sozinho (erro ou crash)
        process.terminationHandler = { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let idx = self.servers.firstIndex(where: { $0.id == id }), self.servers[idx].isRunning {
                    print("ℹ️ Processo [\(server.name)] terminou.")
                    self.stopServer(id: id)
                }
            }
        }
        
        do {
            try process.run()
            
            // Listener para capturar toda a saída do terminal em tempo real
            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
                    print("📝 [\(server.name)]: \(outputString.trimmingCharacters(in: .whitespacesAndNewlines))")
                }
            }

            // Atualiza UI para 'Iniciando', ainda sem confirmar Porta local
            self.servers[index].isRunning = true
            self.servers[index].pid = process.processIdentifier
            self.runningProcesses[id] = process
            
            // Começa o ping ativo para validar o "Sinal Verde"
            startPingLoop(for: server)
            
        } catch {
            print("❌ Erro crítico ao tentar iniciar o processo do servidor: \(error.localizedDescription)")
        }
    }
    
    func stopServer(id: UUID) {
        guard let index = servers.firstIndex(where: { $0.id == id }) else { return }
        
        // Interrompe o processo nativo e os sub-processos usando o group ID (PGID)
        // No macOS, matar o processo pai do shell (zsh) nem sempre mata os filhos (npm/node)
        // Usamos um comando shell para garantir que toda a árvore de processos morra
        if let pid = servers[index].pid {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
            task.arguments = ["-P", "\(pid)"] // Mata filhos do PID
            try? task.run()
            
            // Mata o processo principal também
            if let processItem = runningProcesses[id] {
                processItem.terminate()
            }
        }
        
        runningProcesses.removeValue(forKey: id)
        
        // Pára o Loop de Ping da UI
        pingTimers[id]?.invalidate()
        pingTimers.removeValue(forKey: id)
        
        self.respondingServers.remove(id)
        
        self.servers[index].isRunning = false
        self.servers[index].pid = nil
    }
    
    func stopAll() {
        for server in servers where server.isRunning {
            stopServer(id: server.id)
        }
    }
    
    // MARK: - Ping Híbrido (Health Check HTTP Real)
    private func startPingLoop(for server: DevServer) {
        let serverId = server.id
        guard let url = URL(string: "http://localhost:\(server.port)") else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD" // Fast ping request sem baixar o body inteiro
            request.timeoutInterval = 1.0
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                Task { @MainActor in
                    let isUp = (error == nil) && (response as? HTTPURLResponse) != nil
                    if isUp {
                        self.respondingServers.insert(serverId)
                    } else {
                        self.respondingServers.remove(serverId)
                    }
                }
            }
            task.resume()
        }
        pingTimers[serverId] = timer
    }
}
