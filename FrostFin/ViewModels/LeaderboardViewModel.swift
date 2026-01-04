import Foundation
import Combine

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboardEntries: [LeaderboardEntry] = []
    @Published var isLoading: Bool = false
    @Published var userRank: Int = 0
    @Published var filterCountry: String = "All"
    
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLeaderboard()
    }
    
    func loadLeaderboard() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.leaderboardEntries = self.userService.leaderboard
            
            // Find user rank
            if let userEntry = self.leaderboardEntries.first(where: { $0.username == self.userService.currentUser.username }) {
                self.userRank = userEntry.rank
            }
            
            self.isLoading = false
        }
    }
    
    func refreshLeaderboard() {
        userService.generateLeaderboard()
        loadLeaderboard()
    }
    
    func filterByCountry(_ country: String) {
        filterCountry = country
        
        if country == "All" {
            leaderboardEntries = userService.leaderboard
        } else {
            leaderboardEntries = userService.leaderboard.filter { $0.country == country }
            
            // Update ranks for filtered list
            for i in 0..<leaderboardEntries.count {
                leaderboardEntries[i] = LeaderboardEntry(
                    id: leaderboardEntries[i].id,
                    username: leaderboardEntries[i].username,
                    score: leaderboardEntries[i].score,
                    rank: i + 1,
                    country: leaderboardEntries[i].country
                )
            }
        }
    }
    
    func getCountries() -> [String] {
        var countries = Set(userService.leaderboard.map { $0.country })
        countries.insert("All")
        return Array(countries).sorted()
    }
}

