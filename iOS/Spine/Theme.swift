import SwiftUI

/// Spine's identity: a warm walnut-wood bookshelf aesthetic — deep brown
/// backdrop with a gold-leaf accent, distinct from every sibling app's
/// palette.
enum SPTheme {
    static let backdrop = Color(red: 0.192, green: 0.145, blue: 0.114)  // walnut
    static let surface = Color(red: 0.239, green: 0.184, blue: 0.145)
    static let surfaceRaised = Color(red: 0.286, green: 0.224, blue: 0.180)
    static let ink = Color(red: 0.965, green: 0.937, blue: 0.902)
    static let inkFaded = Color(red: 0.965, green: 0.937, blue: 0.902).opacity(0.6)
    static let rule = Color.white.opacity(0.08)

    static let gold = Color(red: 0.804, green: 0.647, blue: 0.318)
    static let goldBright = Color(red: 0.898, green: 0.741, blue: 0.408)
    static let burgundy = Color(red: 0.545, green: 0.212, blue: 0.212)
    static let danger = Color(red: 0.827, green: 0.365, blue: 0.318)

    static let titleFont = Font.system(.title2, design: .serif).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
