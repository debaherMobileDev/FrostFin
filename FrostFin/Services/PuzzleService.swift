import Foundation

class PuzzleService: ObservableObject {
    static let shared = PuzzleService()
    
    @Published var allPuzzles: [Puzzle] = []
    @Published var dailyPuzzle: Puzzle?
    
    private init() {
        loadPuzzles()
        generateDailyPuzzle()
    }
    
    func loadPuzzles() {
        // Generate sample puzzles
        allPuzzles = [
            createPuzzle1(),
            createPuzzle2(),
            createPuzzle3(),
            createPuzzle4(),
            createPuzzle5(),
            createPuzzle6(),
            createPuzzle7(),
            createPuzzle8(),
            createPuzzle9(),
            createPuzzle10()
        ]
    }
    
    func generateDailyPuzzle() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Use date as seed for consistent daily puzzle
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        let puzzleIndex = dayOfYear % 10
        
        var puzzle = allPuzzles[puzzleIndex]
        puzzle = Puzzle(
            id: puzzle.id,
            number: 0,
            title: "Daily Ice Challenge",
            description: puzzle.description,
            difficulty: .medium,
            elements: puzzle.elements,
            isSolved: false,
            hints: puzzle.hints,
            requiredFishTypes: puzzle.requiredFishTypes,
            maxMoves: puzzle.maxMoves,
            currentMoves: 0,
            temperature: puzzle.temperature,
            isDaily: true,
            date: today
        )
        
        dailyPuzzle = puzzle
    }
    
    func getPuzzle(by id: UUID) -> Puzzle? {
        return allPuzzles.first { $0.id == id }
    }
    
    func updatePuzzleProgress(puzzleId: UUID, moves: Int, solved: Bool) {
        if let index = allPuzzles.firstIndex(where: { $0.id == puzzleId }) {
            allPuzzles[index].currentMoves = moves
            allPuzzles[index].isSolved = solved
        }
    }
    
    // MARK: - Sample Puzzles
    
    private func createPuzzle1() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 100, y: 100), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 200, y: 100), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 300, y: 100), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 1,
            title: "First Freeze",
            description: "Guide the fish to break through the ice and reach the goal.",
            difficulty: .easy,
            elements: elements,
            hints: ["Use the Ice Breaker fish to clear the path", "Tap the fish to move it", "Ice blocks need to be broken"],
            requiredFishTypes: [.iceBreaker],
            maxMoves: 10,
            temperature: -2.0
        )
    }
    
    private func createPuzzle2() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 50, y: 150), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 150, y: 150), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 250, y: 150), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 350, y: 150), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 2,
            title: "Current Flow",
            description: "Direct the water current to move ice blocks and clear the path.",
            difficulty: .easy,
            elements: elements,
            hints: ["Use Current Guide fish to redirect water flow", "Water currents can move ice blocks", "Plan your moves carefully"],
            requiredFishTypes: [.currentGuide],
            maxMoves: 15,
            temperature: -3.0
        )
    }
    
    private func createPuzzle3() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 100, y: 100), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 200, y: 100), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 100, y: 200), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 300, y: 200), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 3,
            title: "Mechanism Maze",
            description: "Activate mechanisms to open new paths through the frozen waters.",
            difficulty: .medium,
            elements: elements,
            hints: ["Mechanism Trigger fish can activate switches", "Some mechanisms open ice barriers", "Timing is important"],
            requiredFishTypes: [.mechanismTrigger],
            maxMoves: 20,
            temperature: -4.0
        )
    }
    
    private func createPuzzle4() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 80, y: 120), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 180, y: 120), type: .iceBlock, state: .melted),
            PuzzleElement(position: CGPoint(x: 280, y: 120), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 180, y: 220), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 4,
            title: "Temperature Control",
            description: "Use Freezer and Heater fish to control ice states.",
            difficulty: .medium,
            elements: elements,
            hints: ["Freezer fish can create ice bridges", "Heater fish can melt obstacles", "Temperature affects all nearby ice"],
            requiredFishTypes: [.freezer, .heater],
            maxMoves: 25,
            temperature: 0.0
        )
    }
    
    private func createPuzzle5() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 100, y: 80), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 200, y: 80), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 100, y: 180), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 300, y: 180), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 200, y: 280), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 5,
            title: "Complex Currents",
            description: "Navigate multiple currents and mechanisms in this challenging puzzle.",
            difficulty: .hard,
            elements: elements,
            hints: ["Combine multiple fish abilities", "Order of actions matters", "Use currents to your advantage", "Break ice before activating mechanisms"],
            requiredFishTypes: [.iceBreaker, .currentGuide, .mechanismTrigger],
            maxMoves: 30,
            temperature: -5.0
        )
    }
    
    private func createPuzzle6() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 150, y: 100), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 250, y: 100), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 200, y: 150), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 150, y: 200), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 250, y: 200), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 6,
            title: "Ice Fortress",
            description: "Break through the ice fortress using strategic planning.",
            difficulty: .hard,
            elements: elements,
            hints: ["Multiple ice layers require careful breaking", "Save moves by planning ahead", "Some ice blocks protect mechanisms"],
            requiredFishTypes: [.iceBreaker, .mechanismTrigger],
            maxMoves: 35,
            temperature: -6.0
        )
    }
    
    private func createPuzzle7() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 100, y: 100), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 200, y: 100), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 300, y: 100), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 150, y: 200), type: .iceBlock, state: .melted),
            PuzzleElement(position: CGPoint(x: 250, y: 200), type: .iceBlock, state: .melted),
            PuzzleElement(position: CGPoint(x: 200, y: 300), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 7,
            title: "Thermal Bridges",
            description: "Create ice bridges by freezing water at the right temperature.",
            difficulty: .expert,
            elements: elements,
            hints: ["Freeze water to create paths", "Water currents can carry fish", "Temperature must be below zero to freeze", "Plan bridge placement carefully"],
            requiredFishTypes: [.freezer, .currentGuide],
            maxMoves: 40,
            temperature: 1.0
        )
    }
    
    private func createPuzzle8() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 120, y: 120), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 220, y: 120), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 320, y: 120), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 170, y: 220), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 270, y: 220), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 220, y: 320), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 8,
            title: "Synchronized Swim",
            description: "Coordinate multiple fish to solve this complex puzzle.",
            difficulty: .expert,
            elements: elements,
            hints: ["Both fish must work together", "Mechanisms need simultaneous activation", "Break ice between mechanisms", "Coordinate movements precisely"],
            requiredFishTypes: [.mechanismTrigger, .iceBreaker],
            maxMoves: 45,
            temperature: -7.0
        )
    }
    
    private func createPuzzle9() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 100, y: 100), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 200, y: 100), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 300, y: 100), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 150, y: 200), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 250, y: 200), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 100, y: 300), type: .iceBlock, state: .melted),
            PuzzleElement(position: CGPoint(x: 300, y: 300), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 9,
            title: "Arctic Master",
            description: "Use all your skills to conquer this ultimate frozen challenge.",
            difficulty: .expert,
            elements: elements,
            hints: ["All fish types may be needed", "Study the layout before starting", "Temperature changes affect strategy", "Multiple solutions may exist", "Efficiency earns bonus points"],
            requiredFishTypes: [.iceBreaker, .currentGuide, .mechanismTrigger, .freezer, .heater],
            maxMoves: 50,
            temperature: -8.0
        )
    }
    
    private func createPuzzle10() -> Puzzle {
        let elements = [
            PuzzleElement(position: CGPoint(x: 150, y: 100), type: .current, state: .active),
            PuzzleElement(position: CGPoint(x: 250, y: 100), type: .mechanism, state: .inactive),
            PuzzleElement(position: CGPoint(x: 100, y: 200), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 200, y: 200), type: .fish, state: .active),
            PuzzleElement(position: CGPoint(x: 300, y: 200), type: .iceBlock, state: .frozen),
            PuzzleElement(position: CGPoint(x: 150, y: 300), type: .iceBlock, state: .melted),
            PuzzleElement(position: CGPoint(x: 250, y: 300), type: .goal, state: .inactive)
        ]
        
        return Puzzle(
            number: 10,
            title: "Deep Freeze",
            description: "Navigate the deepest, coldest waters in this final challenge.",
            difficulty: .expert,
            elements: elements,
            hints: ["Extreme cold affects all mechanics", "Ice is harder to break at low temperatures", "Use heater fish strategically", "Currents freeze faster", "Master timing and positioning"],
            requiredFishTypes: [.iceBreaker, .heater, .currentGuide, .mechanismTrigger],
            maxMoves: 55,
            temperature: -10.0
        )
    }
}

