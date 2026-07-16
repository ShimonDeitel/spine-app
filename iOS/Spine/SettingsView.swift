import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: SpineStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("spine_show_creator") private var showCreator: Bool = true
    @State private var activeSheet: SpineSheet?
    @State private var showResetConfirm = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show artist/author on shelf list", isOn: $showCreator)
                        .accessibilityIdentifier("showCreatorToggle")
                }

                Section("Spine Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(SPTheme.gold)
                    } else {
                        Button("Upgrade to Pro") {
                            activeSheet = .paywall
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("upgradeProButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            restoreMessage = purchases.isPro ? "Purchases restored." : "No purchases found."
                        }
                    }
                    .buttonStyle(.plain)
                    if let restoreMessage {
                        Text(restoreMessage)
                            .font(.caption)
                            .foregroundStyle(SPTheme.inkFaded)
                    }
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/spine-site/privacy.html")!)
                    Link("Contact Support", destination: URL(string: "mailto:s0533495227@gmail.com")!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(SPTheme.inkFaded)
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirm = true
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all shelved items?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .paywall:
                    PaywallView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SpineStore())
        .environmentObject(PurchaseManager())
}
