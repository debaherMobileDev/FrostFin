import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            Color.frostBackground1
                .ignoresSafeArea()
            
            VStack {
                // Skip button
                if viewModel.currentPage < viewModel.pages.count - 1 {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.skipToEnd()
                        }) {
                            Text("Skip")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, isLastPage: index == viewModel.pages.count - 1, username: $viewModel.username)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            viewModel.previousPage()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    
                    Spacer()
                    
                    if viewModel.currentPage < viewModel.pages.count - 1 {
                        Button(action: {
                            viewModel.nextPage()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.frostAccent))
                        }
                    } else {
                        Button(action: {
                            viewModel.completeOnboarding()
                            isOnboardingComplete = true
                        }) {
                            Text("Start Adventure")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(
                                    Capsule()
                                        .fill(Color.frostAccent)
                                )
                        }
                        .disabled(viewModel.username.isEmpty)
                        .opacity(viewModel.username.isEmpty ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @Binding var username: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(.white)
                .shimmer()
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if isLastPage {
                VStack(spacing: 15) {
                    Text("Choose Your Username")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.top, 20)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}

