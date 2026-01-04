import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Custom colors for FrostFin
    static let frostBackground1 = Color(hex: "2F77B7")
    static let frostBackground2 = Color(hex: "C6D6E4")
    static let frostAccent = Color(hex: "E81D4C")
    static let frostIce = Color(hex: "E3F2FD")
    static let frostDark = Color(hex: "1A4D7A")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func frostGradientBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [Color.frostBackground1, Color.frostBackground2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    func frostCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
    
    func frostButton() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.frostAccent)
                    .shadow(color: Color.frostAccent.opacity(0.3), radius: 5, x: 0, y: 3)
            )
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}

// MARK: - Shimmer Effect for Ice
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 300
                }
            }
    }
}

// MARK: - String Extensions
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - Date Extensions
extension Date {
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func daysAgo() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: Date())
        return components.day ?? 0
    }
}

// MARK: - Double Extensions
extension Double {
    func formatTemperature() -> String {
        return String(format: "%.1f°C", self)
    }
}

// MARK: - Int Extensions
extension Int {
    func formatWithCommas() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

