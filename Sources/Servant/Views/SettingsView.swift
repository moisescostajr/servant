import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var serverManager: ServerManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var showingFormSheet = false
    @State private var serverToEdit: DevServer? = nil
    
    var body: some View {
        VStack {
            // Header e Idioma
            HStack {
                Text(localizationManager.t("settings"))
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Picker(localizationManager.t("language"), selection: $localizationManager.currentLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
            }
            .padding()
            
            Divider()
            
            // Lista de Servidores
            List {
                Section(header: Text(localizationManager.t("servers"))) {
                    if serverManager.servers.isEmpty {
                        Text(localizationManager.t("add_first_server"))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(serverManager.servers.enumerated()), id: \.element.id) { index, server in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(server.name).font(.headline)
                                    Text("\(server.directory) - Port: \(server.port)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                Button(localizationManager.t("edit")) {
                                    serverToEdit = server
                                    showingFormSheet = true
                                }
                                .foregroundColor(.blue)
                                .buttonStyle(.plain)
                                .padding(.trailing, 8)
                                
                                Button(localizationManager.t("delete")) {
                                    serverManager.removeServer(at: index)
                                }
                                .foregroundColor(.red)
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(InsetListStyle()) 
            
            // Footer
            HStack {
                Spacer()
                Button(action: {
                    serverToEdit = nil
                    showingFormSheet = true
                }) {
                    Image(systemName: "plus")
                    Text(localizationManager.t("add_server"))
                }
                .padding()
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .navigationTitle(localizationManager.t("settings"))
        .sheet(isPresented: $showingFormSheet) {
            ServerFormSheet(isPresented: $showingFormSheet, serverToEdit: serverToEdit)
                .id(serverToEdit?.id ?? UUID()) // Força reinicialização do @State
                .environmentObject(serverManager)
                .environmentObject(localizationManager)
        }
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct ServerFormSheet: View {
    @EnvironmentObject var serverManager: ServerManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Binding var isPresented: Bool
    var serverToEdit: DevServer?
    
    @State private var name: String = ""
    @State private var directory: String = ""
    @State private var port: String = ""
    @State private var startCommand: String = ""
    
    @FocusState private var focusedField: Field?
    enum Field {
        case name, directory, port, command
    }
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !directory.isEmpty &&
        !port.trimmingCharacters(in: .whitespaces).isEmpty &&
        !startCommand.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(serverToEdit == nil ? localizationManager.t("add_server") : localizationManager.t("edit_server"))
                .font(.headline)
            
            Form {
                TextField(localizationManager.t("name"), text: $name)
                    .focused($focusedField, equals: .name)
                
                HStack {
                    TextField(localizationManager.t("directory"), text: $directory)
                        .focused($focusedField, equals: .directory)
                        .disabled(true)
                        .opacity(0.7)
                    
                    Button(action: selectDirectory) {
                        Image(systemName: "folder")
                    }
                    .help(localizationManager.t("select_directory"))
                }
                
                TextField(localizationManager.t("port"), text: $port)
                    .focused($focusedField, equals: .port)
                TextField(localizationManager.t("start_command"), text: $startCommand)
                    .focused($focusedField, equals: .command)
            }
            .padding(.bottom, 10)
            
            HStack {
                Button(localizationManager.t("cancel")) {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: saveAction) {
                    Text(localizationManager.t("save"))
                        .bold()
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .tint(isFormValid ? .blue : .gray.opacity(0.3)) // Feedback visual mais claro
                .disabled(!isFormValid)
                .scaleEffect(isFormValid ? 1.0 : 0.98)
                .animation(.spring(), value: isFormValid)
            }
        }
        .padding(25)
        .frame(width: 450)
        .onAppear {
            if let server = serverToEdit {
                name = server.name
                directory = server.directory
                port = server.port
                startCommand = server.startCommand
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedField = .name
            }
        }
    }
    
    private func saveAction() {
        let server = DevServer(
            id: serverToEdit?.id ?? UUID(),
            name: name,
            directory: directory,
            port: port,
            startCommand: startCommand
        )
        
        if serverToEdit == nil {
            serverManager.addServer(server)
        } else {
            serverManager.updateServer(server)
        }
        isPresented = false
    }
    
    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                self.directory = url.path(percentEncoded: false)
                if name.isEmpty {
                    name = url.lastPathComponent
                }
            }
        }
    }
}
