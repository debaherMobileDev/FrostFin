import Foundation
import SwiftUI
import Combine

class PuzzleViewModel: ObservableObject {
    @Published var currentPuzzle: Puzzle
    @Published var moves: Int = 0
    @Published var hintsUsed: Int = 0
    @Published var isCompleted: Bool = false
    @Published var showHint: Bool = false
    @Published var currentHintIndex: Int = 0
    @Published var selectedElement: PuzzleElement?
    @Published var showCelebration: Bool = false
    
    let timer = PuzzleTimer()
    private let puzzleService = PuzzleService.shared
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(puzzle: Puzzle) {
        self.currentPuzzle = puzzle
        timer.start()
    }
    
    deinit {
        timer.stop()
    }
    
    func moveElement(_ element: PuzzleElement, to position: CGPoint) {
        guard !isCompleted else { return }
        
        if let index = currentPuzzle.elements.firstIndex(where: { $0.id == element.id }) {
            currentPuzzle.elements[index].position = position
            moves += 1
            HapticFeedback.light()
            
            // Check win condition after move
            checkWinCondition()
        }
    }
    
    func activateElement(_ element: PuzzleElement) {
        guard !isCompleted else { return }
        
        if let index = currentPuzzle.elements.firstIndex(where: { $0.id == element.id }) {
            selectedElement = currentPuzzle.elements[index]
            
            // Perform action based on element type
            switch element.type {
            case .fish:
                activateFish(at: index)
            case .mechanism:
                toggleMechanism(at: index)
            case .iceBlock:
                interactWithIce(at: index)
            case .current:
                redirectCurrent(at: index)
            case .goal:
                break // Goals are passive
            }
            
            moves += 1
            HapticFeedback.medium()
            
            checkWinCondition()
        }
    }
    
    private func activateFish(at index: Int) {
        currentPuzzle.elements[index].state = .active
        
        // Fish affects nearby elements based on type
        let fishPosition = currentPuzzle.elements[index].position
        
        for i in 0..<currentPuzzle.elements.count {
            if i == index { continue }
            
            let distance = distanceBetween(fishPosition, currentPuzzle.elements[i].position)
            if distance < 100 { // Fish effective radius
                switch currentPuzzle.elements[i].type {
                case .iceBlock:
                    // Ice breaker or heater can melt ice
                    if currentPuzzle.elements[i].state == .frozen {
                        currentPuzzle.elements[i].state = .melted
                    }
                case .mechanism:
                    // Mechanism trigger activates mechanisms
                    currentPuzzle.elements[i].state = .active
                default:
                    break
                }
            }
        }
    }
    
    private func toggleMechanism(at index: Int) {
        if currentPuzzle.elements[index].state == .active {
            currentPuzzle.elements[index].state = .inactive
        } else {
            currentPuzzle.elements[index].state = .active
        }
    }
    
    private func interactWithIce(at index: Int) {
        // Temperature affects ice
        if currentPuzzle.temperature < 0 {
            currentPuzzle.elements[index].state = .frozen
        } else {
            currentPuzzle.elements[index].state = .melted
        }
    }
    
    private func redirectCurrent(at index: Int) {
        currentPuzzle.elements[index].state = .active
    }
    
    private func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func useHint() {
        guard currentHintIndex < currentPuzzle.hints.count else { return }
        
        // Try to use hint from user service
        if userService.useHint() {
            showHint = true
            hintsUsed += 1
            HapticFeedback.light()
        } else {
            // Try to buy hint with coins
            if userService.spendCoins(AppConstants.hintCostCoins) {
                showHint = true
                hintsUsed += 1
                HapticFeedback.light()
            }
        }
    }
    
    func nextHint() {
        if currentHintIndex < currentPuzzle.hints.count - 1 {
            currentHintIndex += 1
        }
    }
    
    func dismissHint() {
        showHint = false
    }
    
    private func checkWinCondition() {
        // Simple win condition: all goals must be in completed state
        // or all ice blocks must be melted and mechanisms activated
        
        let allGoalsCompleted = currentPuzzle.elements
            .filter { $0.type == .goal }
            .allSatisfy { isElementCompleted($0) }
        
        if allGoalsCompleted && !currentPuzzle.elements.filter({ $0.type == .goal }).isEmpty {
            completePuzzle()
        }
    }
    
    private func isElementCompleted(_ element: PuzzleElement) -> Bool {
        // Check if goal is reached by checking if any fish is nearby
        let goalPosition = element.position
        
        return currentPuzzle.elements.contains { puzzleElement in
            puzzleElement.type == .fish &&
            puzzleElement.state == .active &&
            distanceBetween(puzzleElement.position, goalPosition) < 50
        }
    }
    
    private func completePuzzle() {
        guard !isCompleted else { return }
        
        isCompleted = true
        timer.stop()
        
        // Calculate score and update user
        let timeSpent = timer.elapsedTime
        let score = ScoreCalculator.calculatePuzzleScore(
            difficulty: currentPuzzle.difficulty,
            movesUsed: moves,
            maxMoves: currentPuzzle.maxMoves,
            timeSpent: timeSpent,
            hintsUsed: hintsUsed
        )
        
        // Update user progress
        userService.completePuzzle(
            difficulty: currentPuzzle.difficulty,
            moves: moves,
            maxMoves: currentPuzzle.maxMoves,
            timeSpent: timeSpent
        )
        
        // Update puzzle status in service
        puzzleService.updatePuzzleProgress(
            puzzleId: currentPuzzle.id,
            moves: moves,
            solved: true
        )
        
        // Handle daily puzzle completion
        if currentPuzzle.isDaily {
            userService.completeDailyPuzzle()
        }
        
        // Show celebration
        showCelebration = true
        HapticFeedback.success()
    }
    
    func resetPuzzle() {
        timer.reset()
        timer.start()
        moves = 0
        hintsUsed = 0
        isCompleted = false
        showCelebration = false
        currentHintIndex = 0
        
        // Reset all elements to initial state
        for i in 0..<currentPuzzle.elements.count {
            switch currentPuzzle.elements[i].type {
            case .iceBlock:
                currentPuzzle.elements[i].state = .frozen
            case .fish:
                currentPuzzle.elements[i].state = .active
            case .mechanism:
                currentPuzzle.elements[i].state = .inactive
            case .current:
                currentPuzzle.elements[i].state = .active
            case .goal:
                currentPuzzle.elements[i].state = .inactive
            }
        }
    }
}

