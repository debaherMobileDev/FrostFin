import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var userService = UserService.shared
    @State private var showResetAlert = false
    @State private var showUsernameSheet = false
    
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
                        // Profile Section
                        profileSection
                        
                        // Game Settings
                        gameSettingsSection
                        
                        // Customization
                        customizationSection
                        
                        // Achievements
                        achievementsSection
                        
                        // Account
                        accountSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showUsernameSheet) {
                usernameEditSheet
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all progress? This cannot be undone.")
            }
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 15) {
            // Avatar
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shimmer()
            
            // Username
            VStack(spacing: 5) {
                Text(viewModel.username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    showUsernameSheet = true
                }) {
                    Text("Edit Username")
                        .font(.caption)
                        .foregroundColor(.frostAccent)
                }
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(userService.currentUser.puzzlesSolved)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Solved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(userService.currentUser.dailyStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(userService.currentUser.coins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Coins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frostCard()
    }
    
    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Game Settings")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                SettingRow(icon: "speaker.wave.2.fill", title: "Sound Effects", isOn: $viewModel.settings.soundEnabled) {
                    viewModel.toggleSound()
                }
                
                Divider()
                
                SettingRow(icon: "music.note", title: "Background Music", isOn: $viewModel.settings.musicEnabled) {
                    viewModel.toggleMusic()
                }
                
                Divider()
                
                SettingRow(icon: "iphone.radiowaves.left.and.right", title: "Vibration", isOn: $viewModel.settings.vibrationEnabled) {
                    viewModel.toggleVibration()
                }
            }
            .padding()
            .frostCard()
        }
    }
    
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Customization")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                // Avatars
                VStack(alignment: .leading, spacing: 10) {
                    Text("Avatar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.availableAvatars, id: \.self) { avatar in
                                AvatarOption(
                                    name: avatar,
                                    isSelected: viewModel.selectedAvatar == avatar
                                ) {
                                    viewModel.selectAvatar(avatar)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Themes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.availableThemes, id: \.self) { theme in
                                ThemeOption(
                                    name: theme,
                                    isSelected: viewModel.selectedTheme == theme
                                ) {
                                    viewModel.selectTheme(theme)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .frostCard()
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                ForEach(userService.currentUser.achievements) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }
            .padding()
            .frostCard()
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                Button(action: {
                    showResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.red)
                        Text("Reset Progress")
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .frostCard()
        }
    }
    
    private var usernameEditSheet: some View {
        NavigationView {
            ZStack {
                Color.frostBackground2.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Edit Username")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        viewModel.updateUsername(viewModel.username)
                        showUsernameSheet = false
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.frostAccent)
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showUsernameSheet = false
                    }
                }
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.frostAccent)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { _ in
                    action()
                }
        }
        .padding(.vertical, 5)
    }
}

struct AvatarOption: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .frostAccent : .gray)
                
                Text(name.capitalized)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.frostAccent.opacity(0.2) : Color.white.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.frostAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct ThemeOption: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(themeColor)
                    .frame(width: 40, height: 40)
                
                Text(name.capitalized)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.frostAccent.opacity(0.2) : Color.white.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color.frostAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
    
    private var themeColor: Color {
        switch name {
        case "arctic": return .blue
        case "deep": return .indigo
        case "frozen": return .cyan
        case "crystal": return .teal
        default: return .gray
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.white.opacity(0.5))
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    SettingsView()
}

