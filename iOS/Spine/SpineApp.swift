import SwiftUI

@main
struct SpineApp: App {
    @StateObject private var store = SpineStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.dark)
        }
    }
}
