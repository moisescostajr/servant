import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var serverManager: ServerManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Header Topo
            HStack {
                Text(localizationManager.t("dev_servers"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.secondary.opacity(0.8))
                Spacer()
                Button(action: {
                    openWindow(id: "SettingsWindow")
                    // Traz o app pro foco frontal caso o menu popup esteja solto
                    NSApp.activate(ignoringOtherApps: true)
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color.secondary.opacity(0.8))
                        .font(.system(size: 13))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Lista de Servidores
            if serverManager.servers.isEmpty {
                Text(localizationManager.t("add_first_server"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 6) {
                    ForEach(serverManager.servers) { server in
                        ServerRowView(server: server)
                    }
                }
                .padding(.horizontal, 12)
            }
            
            Spacer(minLength: 16)
            
            // Footer
            HStack {
                Button(localizationManager.t("quit")) {
                    serverManager.stopAll()
                    NSApplication.shared.terminate(nil)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary.opacity(0.8))
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(localizationManager.t("stop_all")) {
                    serverManager.stopAll()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(serverManager.servers.contains(where: { $0.isRunning }) ? .red.opacity(0.8) : .secondary)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 320)
        // Estética dark blur (glassmorphism) da imagem
        .background(
            ZStack {
                Color.black.opacity(0.3)
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            }
        )
        // Para cantos arredondados limpos no menu popup
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) 
    }
}

// Uma bridge nativa para utilizar os blurs bonitos do macOS
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
