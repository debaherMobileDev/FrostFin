import Foundation

class UserService: ObservableObject {
    static let shared = UserService()
    
    @Published var currentUser: User
    @Published var settings: AppSettings
    @Published var availableFish: [Fish]
    @Published var leaderboard: [LeaderboardEntry] = []
    
    private let userDefaultsKey = "FrostFinUser"
    private let settingsDefaultsKey = "FrostFinSettings"
    private let fishDefaultsKey = "FrostFinFish"
    
    private init() {
        // Load user from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        } else {
            self.currentUser = User()
        }
        
        // Load settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: settingsDefaultsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = AppSettings()
        }
        
        // Load fish from UserDefaults or create default
        if let data = UserDefaults.standard.data(forKey: fishDefaultsKey),
           let fish = try? JSONDecoder().decode([Fish].self, from: data) {
            self.availableFish = fish
        } else {
            self.availableFish = Self.createDefaultFish()
        }
        
        generateLeaderboard()
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsDefaultsKey)
        }
    }
    
    func saveFish() {
        if let encoded = try? JSONEncoder().encode(availableFish) {
            UserDefaults.standard.set(encoded, forKey: fishDefaultsKey)
        }
    }
    
    func addCoins(_ amount: Int) {
        currentUser.coins += amount
        saveUser()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard currentUser.coins >= amount else { return false }
        currentUser.coins -= amount
        saveUser()
        return true
    }
    
    func useHint() -> Bool {
        guard currentUser.hintsAvailable > 0 else { return false }
        currentUser.hintsAvailable -= 1
        saveUser()
        return true
    }
    
    func buyHints(_ count: Int, cost: Int) -> Bool {
        guard spendCoins(cost) else { return false }
        currentUser.hintsAvailable += count
        saveUser()
        return true
    }
    
    func completePuzzle(difficulty: PuzzleDifficulty, moves: Int, maxMoves: Int, timeSpent: TimeInterval) {
        currentUser.puzzlesSolved += 1
        
        // Calculate score based on difficulty, efficiency, and time
        let baseScore = difficultyScore(difficulty)
        let efficiencyBonus = moves <= maxMoves / 2 ? baseScore / 2 : 0
        let timeBonus = timeSpent < 60 ? 50 : (timeSpent < 120 ? 25 : 0)
        let totalScore = baseScore + efficiencyBonus + timeBonus
        
        currentUser.totalScore += totalScore
        
        // Award coins
        let coins = baseScore / 10
        addCoins(coins)
        
        // Update best time
        if currentUser.bestTime == 0 || timeSpent < currentUser.bestTime {
            currentUser.bestTime = timeSpent
        }
        
        // Check achievements
        checkAchievements()
        
        // Check fish unlocks
        checkFishUnlocks()
        
        saveUser()
    }
    
    func completeDailyPuzzle() {
        updateDailyStreak()
        addCoins(50) // Bonus for daily puzzle
        checkAchievements()
    }
    
    func updateDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastPlayed = currentUser.lastPlayedDate {
            let lastPlayedDay = calendar.startOfDay(for: lastPlayed)
            let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                currentUser.dailyStreak += 1
            } else if daysDifference > 1 {
                // Streak broken
                currentUser.dailyStreak = 1
            }
            // If daysDifference == 0, same day, don't update streak
        } else {
            currentUser.dailyStreak = 1
        }
        
        currentUser.lastPlayedDate = today
        saveUser()
    }
    
    private func difficultyScore(_ difficulty: PuzzleDifficulty) -> Int {
        switch difficulty {
        case .easy: return 100
        case .medium: return 200
        case .hard: return 400
        case .expert: return 800
        }
    }
    
    private func checkAchievements() {
        var updated = false
        
        for i in 0..<currentUser.achievements.count {
            if !currentUser.achievements[i].isUnlocked {
                let achievement = currentUser.achievements[i]
                let unlocked: Bool
                
                switch achievement.title {
                case "First Freeze":
                    unlocked = currentUser.puzzlesSolved >= 1
                case "Ice Novice":
                    unlocked = currentUser.puzzlesSolved >= 5
                case "Frozen Explorer":
                    unlocked = currentUser.puzzlesSolved >= 10
                case "Arctic Master":
                    unlocked = currentUser.puzzlesSolved >= 25
                case "Streak Starter":
                    unlocked = currentUser.dailyStreak >= 3
                case "Dedicated Diver":
                    unlocked = currentUser.dailyStreak >= 7
                case "Speed Swimmer":
                    unlocked = currentUser.bestTime > 0 && currentUser.bestTime < 120
                case "Coin Collector":
                    unlocked = currentUser.coins >= 500
                default:
                    unlocked = false
                }
                
                if unlocked {
                    currentUser.achievements[i].isUnlocked = true
                    addCoins(achievement.rewardCoins)
                    updated = true
                }
            }
        }
        
        if updated {
            saveUser()
        }
    }
    
    private func checkFishUnlocks() {
        var updated = false
        
        for i in 0..<availableFish.count {
            if !availableFish[i].isUnlocked {
                if currentUser.puzzlesSolved >= availableFish[i].unlockRequirement {
                    availableFish[i].isUnlocked = true
                    if !currentUser.unlockedFish.contains(availableFish[i].id) {
                        currentUser.unlockedFish.append(availableFish[i].id)
                    }
                    updated = true
                }
            }
        }
        
        if updated {
            saveFish()
            saveUser()
        }
    }
    
    private static func createDefaultFish() -> [Fish] {
        return [
            Fish(type: .iceBreaker, name: "Frosty", isUnlocked: true, unlockRequirement: 0),
            Fish(type: .currentGuide, name: "Current", isUnlocked: false, unlockRequirement: 2),
            Fish(type: .mechanismTrigger, name: "Trigger", isUnlocked: false, unlockRequirement: 5),
            Fish(type: .freezer, name: "Chiller", isUnlocked: false, unlockRequirement: 10),
            Fish(type: .heater, name: "Warm", isUnlocked: false, unlockRequirement: 15)
        ]
    }
    
    func initializeAchievements() {
        if currentUser.achievements.isEmpty {
            currentUser.achievements = [
                Achievement(title: "First Freeze", description: "Complete your first puzzle", iconName: "snowflake", requirement: 1, rewardCoins: 50),
                Achievement(title: "Ice Novice", description: "Complete 5 puzzles", iconName: "star.fill", requirement: 5, rewardCoins: 100),
                Achievement(title: "Frozen Explorer", description: "Complete 10 puzzles", iconName: "star.circle.fill", requirement: 10, rewardCoins: 200),
                Achievement(title: "Arctic Master", description: "Complete 25 puzzles", iconName: "crown.fill", requirement: 25, rewardCoins: 500),
                Achievement(title: "Streak Starter", description: "Maintain a 3-day streak", iconName: "flame.fill", requirement: 3, rewardCoins: 100),
                Achievement(title: "Dedicated Diver", description: "Maintain a 7-day streak", iconName: "flame.circle.fill", requirement: 7, rewardCoins: 300),
                Achievement(title: "Speed Swimmer", description: "Complete a puzzle in under 2 minutes", iconName: "hare.fill", requirement: 1, rewardCoins: 150),
                Achievement(title: "Coin Collector", description: "Accumulate 500 coins", iconName: "bitcoinsign.circle.fill", requirement: 500, rewardCoins: 200)
            ]
            saveUser()
        }
    }
    
    func generateLeaderboard() {
        // Generate sample leaderboard data
        let usernames = ["ArcticAce", "IcyPhantom", "FrozenKing", "ColdWave", "GlacierPro", "FrostMaster", "IceBlade", "PolarStar", "SnowDrift", "ChillSeeker"]
        let countries = ["USA", "Canada", "Norway", "Sweden", "Finland", "Iceland", "Russia", "Japan", "UK", "Germany"]
        
        leaderboard = []
        for i in 0..<10 {
            let score = 10000 - (i * 500) + Int.random(in: 0..<400)
            let entry = LeaderboardEntry(
                username: usernames[i],
                score: score,
                rank: i + 1,
                country: countries[i]
            )
            leaderboard.append(entry)
        }
        
        // Add current user if they have a score
        if currentUser.totalScore > 0 {
            let userRank = leaderboard.count + 1
            let userEntry = LeaderboardEntry(
                username: currentUser.username,
                score: currentUser.totalScore,
                rank: userRank,
                country: "You"
            )
            leaderboard.append(userEntry)
            leaderboard.sort { $0.score > $1.score }
            
            // Update ranks
            for i in 0..<leaderboard.count {
                leaderboard[i] = LeaderboardEntry(
                    id: leaderboard[i].id,
                    username: leaderboard[i].username,
                    score: leaderboard[i].score,
                    rank: i + 1,
                    country: leaderboard[i].country
                )
            }
        }
    }
}

