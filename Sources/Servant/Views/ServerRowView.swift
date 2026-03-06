import SwiftUI

struct ServerRowView: View {
    @EnvironmentObject var serverManager: ServerManager
    @EnvironmentObject var localizationManager: LocalizationManager
    var server: DevServer
    
    @State private var isHovering = false

    var body: some View {
        let isActivelyResponding = serverManager.respondingServers.contains(server.id)
        
        HStack(alignment: .center, spacing: 12) {
            
            // Coluna Esquerda: Bolinha + Textos
            HStack(alignment: .top, spacing: 10) {
                // Bolinha Status com brilho se ativo
                ZStack {
                    if server.isRunning && isActivelyResponding {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .blur(radius: 2)
                    }
                    
                    Circle()
                        .fill(server.isRunning ? (isActivelyResponding ? Color.green : Color.yellow) : Color(NSColor.tertiaryLabelColor))
                        .frame(width: 7, height: 7)
                }
                .frame(width: 12, height: 12)
                .padding(.top, 3) 
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(server.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    HStack(spacing: 6) {
                        Text(":\(server.port)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(4)
                            .foregroundColor(.secondary.opacity(0.8))
                        
                        Text(server.directory.replacingOccurrences(of: FileManager.default.homeDirectoryForCurrentUser.path, with: "~"))
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.5))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Ações Rápidas (Finder / VS Code / Play-Stop)
            HStack(spacing: 8) {
                if isHovering {
                    Group {
                        Button(action: openInFinder) {
                            Image(systemName: "folder")
                                .foregroundColor(.secondary)
                        }
                        .help(localizationManager.t("open_finder"))
                        
                        Button(action: openInVSCode) {
                            Image(systemName: "command")
                                .foregroundColor(.secondary)
                        }
                        .help(localizationManager.t("open_vscode"))
                    }
                    .font(.system(size: 12))
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    
                    Divider()
                        .frame(height: 12)
                }
                
                Button(action: {
                    serverManager.toggleServer(id: server.id)
                }) {
                    ZStack {
                        if server.isRunning {
                           Circle().fill(Color.red.opacity(0.1)).frame(width: 24, height: 24)
                        } else {
                           Circle().fill(Color.green.opacity(0.1)).frame(width: 24, height: 24)
                        }
                        
                        Image(systemName: server.isRunning ? "stop.fill" : "play.fill")
                            .foregroundColor(server.isRunning ? .red.opacity(0.8) : .green.opacity(0.8))
                            .font(.system(size: 11, weight: .bold))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(isHovering ? Color.white.opacity(0.05) : Color.clear)
        .cornerRadius(10)
        .onHover { hover in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isHovering = hover
            }
        }
    }
    
    private func openInFinder() {
        let url = URL(fileURLWithPath: server.directory)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }
    
    private func openInVSCode() {
        let url = URL(fileURLWithPath: server.directory)
        let configuration = NSWorkspace.OpenConfiguration()
        
        // Tenta abrir com VS Code (comum em dev)
        if let vscodeUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.VSCode") {
            NSWorkspace.shared.open([url], withApplicationAt: vscodeUrl, configuration: configuration)
        } else {
            // Se não tiver VS Code, abre no Finder como fallback
            openInFinder()
        }
    }
}

