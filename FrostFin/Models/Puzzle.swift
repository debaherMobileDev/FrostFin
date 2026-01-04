import Foundation

enum PuzzleDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
}

struct PuzzleElement: Identifiable, Codable {
    let id: UUID
    var position: CGPoint
    let type: ElementType
    var state: ElementState
    
    enum ElementType: String, Codable {
        case iceBlock
        case fish
        case mechanism
        case current
        case goal
    }
    
    enum ElementState: String, Codable {
        case frozen
        case melted
        case active
        case inactive
        case completed
    }
    
    init(id: UUID = UUID(), position: CGPoint, type: ElementType, state: ElementState = .inactive) {
        self.id = id
        self.position = position
        self.type = type
        self.state = state
    }
}

struct Puzzle: Identifiable, Codable {
    let id: UUID
    let number: Int
    let title: String
    let description: String
    let difficulty: PuzzleDifficulty
    var elements: [PuzzleElement]
    var isSolved: Bool
    var hints: [String]
    var requiredFishTypes: [FishType]
    let maxMoves: Int
    var currentMoves: Int
    let temperature: Double // Affects ice melting/freezing
    let isDaily: Bool
    let date: Date?
    
    init(id: UUID = UUID(), number: Int, title: String, description: String, difficulty: PuzzleDifficulty, elements: [PuzzleElement] = [], isSolved: Bool = false, hints: [String] = [], requiredFishTypes: [FishType] = [], maxMoves: Int = 50, currentMoves: Int = 0, temperature: Double = -5.0, isDaily: Bool = false, date: Date? = nil) {
        self.id = id
        self.number = number
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.elements = elements
        self.isSolved = isSolved
        self.hints = hints
        self.requiredFishTypes = requiredFishTypes
        self.maxMoves = maxMoves
        self.currentMoves = currentMoves
        self.temperature = temperature
        self.isDaily = isDaily
        self.date = date
    }
}

