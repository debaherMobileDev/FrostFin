import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var username: String = ""
    @Published var isOnboardingComplete: Bool = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to FrostFin",
            description: "Dive into an immersive underwater puzzle adventure set in icy depths",
            imageName: "snowflake.circle.fill",
            color: Color.frostBackground1
        ),
        OnboardingPage(
            title: "How to Play",
            description: "Move fish and manipulate ice blocks to solve challenging puzzles",
            imageName: "gamecontroller.fill",
            color: Color.frostBackground2
        ),
        OnboardingPage(
            title: "Underwater World",
            description: "Explore a dynamic environment where temperature affects gameplay",
            imageName: "drop.fill",
            color: Color.frostBackground1
        ),
        OnboardingPage(
            title: "Daily Ice Challenges",
            description: "Complete daily puzzles to earn rewards and maintain your streak",
            imageName: "calendar.circle.fill",
            color: Color.frostAccent
        ),
        OnboardingPage(
            title: "Customization",
            description: "Unlock new fish species, avatars, and themes as you progress",
            imageName: "star.fill",
            color: Color.frostBackground1
        ),
        OnboardingPage(
            title: "Ready to Dive?",
            description: "Enter your username and start your frozen adventure!",
            imageName: "figure.wave",
            color: Color.frostBackground2
        )
    ]
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation(.spring()) {
                currentPage += 1
            }
            HapticFeedback.light()
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation(.spring()) {
                currentPage -= 1
            }
            HapticFeedback.light()
        }
    }
    
    func skipToEnd() {
        withAnimation(.spring()) {
            currentPage = pages.count - 1
        }
    }
    
    func completeOnboarding() {
        let sanitizedUsername = ValidationHelper.sanitizeUsername(username)
        
        if ValidationHelper.isValidUsername(sanitizedUsername) {
            UserService.shared.currentUser.username = sanitizedUsername
            UserService.shared.saveUser()
            UserService.shared.initializeAchievements()
            
            withAnimation {
                isOnboardingComplete = true
            }
            HapticFeedback.success()
        } else {
            HapticFeedback.error()
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

