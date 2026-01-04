import SwiftUI

struct PuzzleView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: PuzzleViewModel
    @StateObject private var userService = UserService.shared
    
    init(puzzle: Puzzle) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzle: puzzle))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.frostBackground1
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                puzzleHeader
                
                // Puzzle Board
                puzzleBoardView
                    .padding()
                
                // Controls
                controlsView
            }
            
            // Hint Overlay
            if viewModel.showHint {
                hintOverlay
            }
            
            // Completion Overlay
            if viewModel.showCelebration {
                completionOverlay
            }
        }
    }
    
    private var puzzleHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text(viewModel.currentPuzzle.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentPuzzle.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.resetPuzzle()
                    HapticFeedback.light()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Stats bar
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white)
                    Text(viewModel.timer.formattedTime())
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.white)
                    Text("\(viewModel.moves)/\(viewModel.currentPuzzle.maxMoves)")
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "thermometer.medium")
                        .foregroundColor(.white)
                    Text(viewModel.currentPuzzle.temperature.formatTemperature())
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
            }
            .font(.caption)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.top)
        .background(Color.frostDark)
    }
    
    private var puzzleBoardView: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let offsetX = (geometry.size.width - boardSize) / 2
            let offsetY = (geometry.size.height - boardSize) / 2
            
            ZStack {
                // Background ice effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.frostIce.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .shimmer()
                    .frame(width: boardSize, height: boardSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Puzzle elements
                ForEach(viewModel.currentPuzzle.elements) { element in
                    let scaledX = offsetX + (element.position.x / 400) * boardSize
                    let scaledY = offsetY + (element.position.y / 400) * boardSize
                    
                    PuzzleElementView(element: element, isSelected: viewModel.selectedElement?.id == element.id)
                        .position(x: scaledX, y: scaledY)
                        .onTapGesture {
                            viewModel.activateElement(element)
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let relativeX = (value.location.x - offsetX) / boardSize * 400
                                    let relativeY = (value.location.y - offsetY) / boardSize * 400
                                    let newPosition = CGPoint(
                                        x: max(30, min(370, relativeX)),
                                        y: max(30, min(370, relativeY))
                                    )
                                    viewModel.moveElement(element, to: newPosition)
                                }
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    private var controlsView: some View {
        HStack(spacing: 20) {
            // Hint button
            Button(action: {
                viewModel.useHint()
            }) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                    Text("Hint (\(userService.currentUser.hintsAvailable))")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange)
                )
            }
            
            // Description
            VStack(alignment: .leading, spacing: 5) {
                Text("Objective")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(viewModel.currentPuzzle.description)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
            )
        }
        .padding()
    }
    
    private var hintOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.dismissHint()
                }
            
            VStack(spacing: 20) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Hint")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.currentPuzzle.hints[viewModel.currentHintIndex])
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack(spacing: 15) {
                    if viewModel.currentHintIndex < viewModel.currentPuzzle.hints.count - 1 {
                        Button(action: {
                            viewModel.nextHint()
                        }) {
                            Text("Next Hint")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.orange)
                                )
                        }
                    }
                    
                    Button(action: {
                        viewModel.dismissHint()
                    }) {
                        Text("Got it!")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.frostAccent)
                            )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.frostDark)
            )
            .padding(40)
        }
    }
    
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shimmer()
                
                Text("Puzzle Completed!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    Text("Time: \(viewModel.timer.formattedTime())")
                        .foregroundColor(.white)
                    Text("Moves: \(viewModel.moves)/\(viewModel.currentPuzzle.maxMoves)")
                        .foregroundColor(.white)
                    Text("Hints: \(viewModel.hintsUsed)")
                        .foregroundColor(.white)
                }
                .font(.headline)
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.frostAccent)
                        )
                }
                .padding(.top)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.frostBackground1)
            )
            .padding(40)
        }
    }
}

struct PuzzleElementView: View {
    let element: PuzzleElement
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(elementColor)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.white, lineWidth: isSelected ? 4 : 2)
                )
                .shadow(color: elementColor.opacity(0.7), radius: 8, x: 0, y: 4)
            
            Image(systemName: elementIcon)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
        }
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var elementColor: Color {
        switch element.type {
        case .iceBlock:
            return element.state == .frozen ? Color.blue : Color.cyan.opacity(0.5)
        case .fish:
            return Color.orange
        case .mechanism:
            return element.state == .active ? Color.green : Color.gray
        case .current:
            return Color.teal
        case .goal:
            return Color.yellow
        }
    }
    
    private var elementIcon: String {
        switch element.type {
        case .iceBlock:
            return element.state == .frozen ? "snowflake" : "drop.fill"
        case .fish:
            return "pawprint.fill"
        case .mechanism:
            return "gearshape.fill"
        case .current:
            return "wind"
        case .goal:
            return "flag.fill"
        }
    }
}

#Preview {
    PuzzleView(puzzle: Puzzle(
        number: 1,
        title: "Test Puzzle",
        description: "Test Description",
        difficulty: .easy,
        elements: [
            PuzzleElement(position: CGPoint(x: 100, y: 100), type: .fish),
            PuzzleElement(position: CGPoint(x: 200, y: 200), type: .goal)
        ]
    ))
}

