import Foundation

enum FishType: String, Codable, CaseIterable {
    case iceBreaker = "Ice Breaker"
    case currentGuide = "Current Guide"
    case mechanismTrigger = "Mechanism Trigger"
    case freezer = "Freezer"
    case heater = "Heater"
    
    var ability: String {
        switch self {
        case .iceBreaker:
            return "Breaks through ice blocks"
        case .currentGuide:
            return "Directs water currents"
        case .mechanismTrigger:
            return "Activates puzzle mechanisms"
        case .freezer:
            return "Freezes water into ice"
        case .heater:
            return "Melts ice blocks"
        }
    }
    
    var imageName: String {
        switch self {
        case .iceBreaker:
            return "fish.icebreaker"
        case .currentGuide:
            return "fish.guide"
        case .mechanismTrigger:
            return "fish.trigger"
        case .freezer:
            return "fish.freezer"
        case .heater:
            return "fish.heater"
        }
    }
}

struct Fish: Identifiable, Codable {
    let id: UUID
    let type: FishType
    let name: String
    var isUnlocked: Bool
    let unlockRequirement: Int // Number of puzzles to unlock
    
    init(id: UUID = UUID(), type: FishType, name: String, isUnlocked: Bool = false, unlockRequirement: Int = 0) {
        self.id = id
        self.type = type
        self.name = name
        self.isUnlocked = isUnlocked
        self.unlockRequirement = unlockRequirement
    }
}

