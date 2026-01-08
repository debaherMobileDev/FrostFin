import Foundation

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
    let requirement: Int
    let rewardCoins: Int
    
    init(id: UUID = UUID(), title: String, description: String, iconName: String, isUnlocked: Bool = false, requirement: Int, rewardCoins: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isUnlocked = isUnlocked
        self.requirement = requirement
        self.rewardCoins = rewardCoins
    }
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let username: String
    let score: Int
    let rank: Int
    let country: String
    
    init(id: UUID = UUID(), username: String, score: Int, rank: Int, country: String = "Unknown") {
        self.id = id
        self.username = username
        self.score = score
        self.rank = rank
        self.country = country
    }
}

struct User: Codable {
    var username: String
    var coins: Int
    var puzzlesSolved: Int
    var dailyStreak: Int
    var lastPlayedDate: Date?
    var totalScore: Int
    var unlockedFish: [UUID]
    var achievements: [Achievement]
    var selectedAvatar: String
    var selectedTheme: String
    var bestTime: TimeInterval
    
    init(username: String = "Player", coins: Int = 100, puzzlesSolved: Int = 0, dailyStreak: Int = 0, lastPlayedDate: Date? = nil, totalScore: Int = 0, unlockedFish: [UUID] = [], achievements: [Achievement] = [], selectedAvatar: String = "default", selectedTheme: String = "arctic", bestTime: TimeInterval = 0) {
        self.username = username
        self.coins = coins
        self.puzzlesSolved = puzzlesSolved
        self.dailyStreak = dailyStreak
        self.lastPlayedDate = lastPlayedDate
        self.totalScore = totalScore
        self.unlockedFish = unlockedFish
        self.achievements = achievements
        self.selectedAvatar = selectedAvatar
        self.selectedTheme = selectedTheme
        self.bestTime = bestTime
    }
}

