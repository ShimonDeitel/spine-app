import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SpineHomeView()
                .tabItem {
                    Label("Shelf", systemImage: "books.vertical.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(SPTheme.gold)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(SPTheme.surface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(SpineStore())
        .environmentObject(PurchaseManager())
}
