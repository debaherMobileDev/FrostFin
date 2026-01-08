import SwiftUI

struct HomeView: View {
    @StateObject private var puzzleService = PuzzleService.shared
    @StateObject private var userService = UserService.shared
    @State private var selectedPuzzle: Puzzle?
    @State private var showPuzzle = false
    @State private var showDailyChallenge = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.frostBackground1, Color.frostBackground2]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        headerView
                        
                        // Daily Challenge Card
                        dailyChallengeCard
                        
                        // User Stats
                        userStatsView
                        
                        // Puzzle Grid
                        puzzleGridView
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("FrostFin")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showPuzzle) {
                if let puzzle = selectedPuzzle {
                    PuzzleView(puzzle: puzzle)
                }
            }
            .sheet(isPresented: $showDailyChallenge) {
                if let dailyPuzzle = puzzleService.dailyPuzzle {
                    PuzzleView(puzzle: dailyPuzzle)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome, \(userService.currentUser.username)!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Let's dive into some puzzles")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                // Coins
                HStack(spacing: 5) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(userService.currentUser.coins)")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
            }
        }
        .padding()
    }
    
    private var dailyChallengeCard: some View {
        Button(action: {
            showDailyChallenge = true
            HapticFeedback.medium()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title)
                        .foregroundColor(.frostAccent)
                    
                    VStack(alignment: .leading) {
                        Text("Daily Ice Challenge")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Complete today's puzzle for bonus rewards!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.frostAccent)
                }
            }
            .padding()
            .frostCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var userStatsView: some View {
        HStack(spacing: 15) {
            StatCard(title: "Solved", value: "\(userService.currentUser.puzzlesSolved)", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Streak", value: "\(userService.currentUser.dailyStreak)", icon: "flame.fill", color: .orange)
            StatCard(title: "Score", value: "\(userService.currentUser.totalScore.formatWithCommas())", icon: "star.fill", color: .yellow)
        }
    }
    
    private var puzzleGridView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Puzzles")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(puzzleService.allPuzzles) { puzzle in
                    PuzzleCard(puzzle: puzzle, isUnlocked: puzzle.number == 1 || userService.currentUser.puzzlesSolved >= puzzle.number - 1)
                        .onTapGesture {
                            if puzzle.number == 1 || userService.currentUser.puzzlesSolved >= puzzle.number - 1 {
                                selectedPuzzle = puzzle
                                showPuzzle = true
                                HapticFeedback.medium()
                            } else {
                                HapticFeedback.error()
                            }
                        }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .frostCard()
    }
}

struct PuzzleCard: View {
    let puzzle: Puzzle
    let isUnlocked: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: isUnlocked ? difficultyIcon : "lock.fill")
                    .foregroundColor(isUnlocked ? difficultyColor : .gray)
                
                Spacer()
                
                if puzzle.isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(puzzle.title)
                .font(.headline)
                .foregroundColor(isUnlocked ? .primary : .gray)
            
            Text(puzzle.difficulty.rawValue)
                .font(.caption)
                .foregroundColor(isUnlocked ? difficultyColor : .gray)
            
            if !isUnlocked {
                Text("Solve puzzle \(puzzle.number - 1)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .frostCard()
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    private var difficultyIcon: String {
        switch puzzle.difficulty {
        case .easy: return "snowflake"
        case .medium: return "snowflake.circle"
        case .hard: return "snowflake.circle.fill"
        case .expert: return "crown.fill"
        }
    }
    
    private var difficultyColor: Color {
        switch puzzle.difficulty {
        case .easy: return .green
        case .medium: return .blue
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

#Preview {
    HomeView()
}

