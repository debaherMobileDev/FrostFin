import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var username: String
    @Published var selectedAvatar: String
    @Published var selectedTheme: String
    @Published var showUsernameAlert: Bool = false
    @Published var usernameError: String = ""
    
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    let availableAvatars = ["default", "arctic", "explorer", "master", "legend"]
    let availableThemes = ["arctic", "deep", "frozen", "crystal"]
    
    init() {
        self.settings = userService.settings
        self.username = userService.currentUser.username
        self.selectedAvatar = userService.currentUser.selectedAvatar
        self.selectedTheme = userService.currentUser.selectedTheme
    }
    
    func toggleSound() {
        settings.soundEnabled.toggle()
        userService.settings.soundEnabled = settings.soundEnabled
        userService.saveSettings()
        HapticFeedback.light()
    }
    
    func toggleMusic() {
        settings.musicEnabled.toggle()
        userService.settings.musicEnabled = settings.musicEnabled
        userService.saveSettings()
        
        if settings.musicEnabled {
            SoundManager.shared.playBackgroundMusic()
        } else {
            SoundManager.shared.stopBackgroundMusic()
        }
        
        HapticFeedback.light()
    }
    
    func toggleVibration() {
        settings.vibrationEnabled.toggle()
        userService.settings.vibrationEnabled = settings.vibrationEnabled
        userService.saveSettings()
        HapticFeedback.medium()
    }
    
    func updateUsername(_ newUsername: String) {
        let sanitized = ValidationHelper.sanitizeUsername(newUsername)
        
        if ValidationHelper.isValidUsername(sanitized) {
            username = sanitized
            userService.currentUser.username = sanitized
            userService.saveUser()
            HapticFeedback.success()
        } else {
            usernameError = "Username must be 3-20 characters long"
            showUsernameAlert = true
            HapticFeedback.error()
        }
    }
    
    func selectAvatar(_ avatar: String) {
        selectedAvatar = avatar
        userService.currentUser.selectedAvatar = avatar
        userService.saveUser()
        HapticFeedback.light()
    }
    
    func selectTheme(_ theme: String) {
        selectedTheme = theme
        userService.currentUser.selectedTheme = theme
        userService.saveUser()
        HapticFeedback.light()
    }
    
    func resetProgress() {
        // Reset user progress (use with caution)
        userService.currentUser = User()
        userService.saveUser()
        username = userService.currentUser.username
        HapticFeedback.warning()
    }
    
    func exportData() -> String {
        // Export user data as JSON string
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(userService.currentUser),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return ""
    }
}

