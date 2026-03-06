import Foundation

struct DevServer: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var directory: String
    var port: String
    var startCommand: String
    var isRunning: Bool = false
    var pid: Int32? = nil
    
    // Construtor auxiliar
    init(id: UUID = UUID(), name: String, directory: String, port: String, startCommand: String, isRunning: Bool = false, pid: Int32? = nil) {
        self.id = id
        self.name = name
        self.directory = directory
        self.port = port
        self.startCommand = startCommand
        self.isRunning = isRunning
        self.pid = pid
    }
}
