import Foundation

struct AppSettings: Codable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var vibrationEnabled: Bool
    var language: String
    
    init(soundEnabled: Bool = true, musicEnabled: Bool = true, vibrationEnabled: Bool = true, language: String = "en") {
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.vibrationEnabled = vibrationEnabled
        self.language = language
    }
}

