import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @StateObject private var userService = UserService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.frostBackground1, Color.frostBackground2]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Spacer()
                    } else {
                        // Leaderboard List
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(viewModel.leaderboardEntries) { entry in
                                    LeaderboardRow(
                                        entry: entry,
                                        isCurrentUser: entry.username == userService.currentUser.username
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Leaderboard")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshLeaderboard()
                        HapticFeedback.light()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            // User's rank card
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Your Rank")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("#\(viewModel.userRank > 0 ? "\(viewModel.userRank)" : "Unranked")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Total Score")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(userService.currentUser.totalScore.formatWithCommas())")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
            )
            .padding(.horizontal)
            
            // Filter options (placeholder for future implementation)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.getCountries(), id: \.self) { country in
                        FilterButton(
                            title: country,
                            isSelected: viewModel.filterCountry == country
                        ) {
                            viewModel.filterByCountry(country)
                            HapticFeedback.light()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.frostDark)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            ZStack {
                if entry.rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: entry.rank == 1 ? "crown.fill" : "medal.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("\(entry.rank)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.username)
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .frostAccent : .primary)
                
                Text(entry.country)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.score.formatWithCommas())")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isCurrentUser ? Color.frostAccent.opacity(0.2) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isCurrentUser ? Color.frostAccent : Color.clear, lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color.orange
        default: return Color.clear
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.frostAccent : Color.white.opacity(0.2))
                )
        }
    }
}

#Preview {
    LeaderboardView()
}

