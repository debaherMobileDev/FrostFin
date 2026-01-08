import Foundation
import SwiftUI

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - Animation Helpers
struct AnimationConfig {
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.7
    
    static var spring: Animation {
        Animation.spring(response: springResponse, dampingFraction: springDamping)
    }
    
    static var easeInOut: Animation {
        Animation.easeInOut(duration: 0.3)
    }
    
    static var smooth: Animation {
        Animation.interpolatingSpring(stiffness: 300, damping: 30)
    }
}

// MARK: - Constants
struct AppConstants {
    static let dailyBonusCoins = 50
    
    static let minPuzzleTime: TimeInterval = 10
    static let maxPuzzleTime: TimeInterval = 600
    
    static let leaderboardRefreshInterval: TimeInterval = 300 // 5 minutes
}

// MARK: - Score Calculator
struct ScoreCalculator {
    static func calculatePuzzleScore(
        difficulty: PuzzleDifficulty,
        movesUsed: Int,
        maxMoves: Int,
        timeSpent: TimeInterval,
        hintsUsed: Int
    ) -> Int {
        let baseScore = baseScoreFor(difficulty: difficulty)
        
        // Efficiency bonus (0-50% of base score)
        let moveRatio = Double(movesUsed) / Double(maxMoves)
        let efficiencyBonus = moveRatio <= 0.5 ? Int(Double(baseScore) * 0.5) :
                              moveRatio <= 0.75 ? Int(Double(baseScore) * 0.25) : 0
        
        // Time bonus (0-100 points)
        let timeBonus = timeSpent < 60 ? 100 :
                        timeSpent < 120 ? 50 :
                        timeSpent < 300 ? 25 : 0
        
        // Hint penalty (each hint reduces score by 10%)
        let hintPenalty = Int(Double(baseScore) * 0.1 * Double(hintsUsed))
        
        let totalScore = baseScore + efficiencyBonus + timeBonus - hintPenalty
        return max(0, totalScore)
    }
    
    private static func baseScoreFor(difficulty: PuzzleDifficulty) -> Int {
        switch difficulty {
        case .easy: return 100
        case .medium: return 200
        case .hard: return 400
        case .expert: return 800
        }
    }
}

// MARK: - Timer Helper
class PuzzleTimer: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var startTime: Date?
    
    func start() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        stop()
        elapsedTime = 0
        startTime = nil
    }
    
    func formattedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Sound Manager (Placeholder for future implementation)
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    func playSound(_ soundName: String) {
        // Implement sound playing logic here
        // For now, just provide haptic feedback
        HapticFeedback.light()
    }
    
    func playBackgroundMusic() {
        // Implement background music logic
    }
    
    func stopBackgroundMusic() {
        // Implement stop music logic
    }
}

// MARK: - Validation Helpers
struct ValidationHelper {
    static func isValidUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3 && trimmed.count <= 20
    }
    
    static func sanitizeUsername(_ username: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        return username.components(separatedBy: allowed.inverted).joined()
    }
}

