import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case portuguese = "pt-BR"
    case spanish = "es"
    case chinese = "zh"
    case hindi = "hi"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .portuguese: return "Português (BR)"
        case .spanish: return "Español"
        case .chinese: return "中文 (Chinese)"
        case .hindi: return "हिन्दी (Hindi)"
        }
    }
}

class LocalizationManager: ObservableObject {
    @AppStorage("appLanguage") private var currentLanguageStr: String = "en"
    
    @Published var currentLanguage: AppLanguage = .english {
        didSet {
            currentLanguageStr = currentLanguage.rawValue
        }
    }
    
    init() {
        if let lang = AppLanguage(rawValue: currentLanguageStr) {
            self.currentLanguage = lang
        } else {
            // Se o sistema principal do aparelho for um dos suportados, tentamos adivinhar, se não, cai pro ingles
            let sysLang = Locale.current.language.languageCode?.identifier ?? "en"
            if sysLang.starts(with: "pt") {
                self.currentLanguage = .portuguese
            } else if sysLang.starts(with: "es") {
                self.currentLanguage = .spanish
            } else if sysLang.starts(with: "zh") {
                self.currentLanguage = .chinese
            } else if sysLang.starts(with: "hi") {
                self.currentLanguage = .hindi
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    // Mini Dicionário Interno para o protótipo rápido para evitar restrições de string catalog do SPM no terminal
    private let dictionary: [AppLanguage: [String: String]] = [
        .english: [
            "dev_servers": "SERVANT",
            "add_first_server": "Add your first server",
            "quit": "Quit",
            "stop_all": "Stop All",
            "settings": "Settings",
            "language": "Language",
            "servers": "Servers",
            "add_server": "Add Server",
            "name": "Name",
            "directory": "Directory",
            "port": "Port",
            "start_command": "Start Command",
            "save": "Save",
            "cancel": "Cancel",
            "delete": "Delete",
            "select_directory": "Select Directory",
            "open_finder": "Open in Finder",
            "open_vscode": "Open in VS Code",
            "edit": "Edit",
            "edit_server": "Edit Server"
        ],
        .portuguese: [
            "dev_servers": "SERVANT",
            "add_first_server": "Adicione o primeiro servidor",
            "quit": "Sair",
            "stop_all": "Parar Tudo",
            "settings": "Configurações",
            "language": "Idioma",
            "servers": "Servidores",
            "add_server": "Adicionar Servidor",
            "name": "Nome",
            "directory": "Diretório",
            "port": "Porta",
            "start_command": "Comando de Início",
            "save": "Salvar",
            "cancel": "Cancelar",
            "delete": "Apagar",
            "select_directory": "Selecionar Diretório",
            "open_finder": "Abrir no Finder",
            "open_vscode": "Abrir no VS Code",
            "edit": "Editar",
            "edit_server": "Editar Servidor"
        ],
        .spanish: [
            "dev_servers": "SERVANT",
            "add_first_server": "Agrega tu primer servidor",
            "quit": "Salir",
            "stop_all": "Detener Todo",
            "settings": "Ajustes",
            "language": "Idioma",
            "servers": "Servidores",
            "add_server": "Agregar Servidor",
            "name": "Nombre",
            "directory": "Directorio",
            "port": "Puerto",
            "start_command": "Comando de Inicio",
            "save": "Guardar",
            "cancel": "Cancelar",
            "delete": "Eliminar",
            "select_directory": "Seleccionar Directorio",
            "open_finder": "Abrir en Finder",
            "open_vscode": "Abrir en VS Code",
            "edit": "Editar",
            "edit_server": "Editar Servidor"
        ],
        .chinese: [
            "dev_servers": "SERVANT",
            "add_first_server": "添加您的第一个服务器",
            "quit": "退出",
            "stop_all": "全部停止",
            "settings": "设置",
            "language": "语言",
            "servers": "服务器",
            "add_server": "添加服务器",
            "name": "名称",
            "directory": "目录",
            "port": "端口",
            "start_command": "启动命令",
            "save": "保存",
            "cancel": "取消",
            "delete": "删除",
            "select_directory": "选择目录",
            "open_finder": "在 Finder 中打开",
            "open_vscode": "在 VS Code 中打开",
            "edit": "编辑",
            "edit_server": "编辑服务器"
        ],
        .hindi: [
            "dev_servers": "SERVANT",
            "add_first_server": "अपना पहला सर्वर जोड़ें",
            "quit": "बाहर जाएं",
            "stop_all": "सभी रोकें",
            "settings": "सेटिंग्स",
            "language": "भाषा",
            "servers": "सर्वर",
            "add_server": "सर्वर जोड़ें",
            "name": "नाम",
            "directory": "निर्देशिका",
            "port": "पोर्ट",
            "start_command": "प्रारंभ कमांड",
            "save": "सहेजें",
            "cancel": "रद्द करें",
            "delete": "हटाएं",
            "select_directory": "निर्देशica चुनें",
            "open_finder": "Finder में खोलें",
            "open_vscode": "VS Code में खोलें",
            "edit": "संपादित करें",
            "edit_server": "सर्वर संपादित करें"
        ]
    ]
    
    func t(_ key: String) -> String {
        return dictionary[currentLanguage]?[key] ?? key
    }
}
