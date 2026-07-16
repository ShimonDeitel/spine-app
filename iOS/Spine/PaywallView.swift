import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var purchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                SPTheme.backdrop.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(SPTheme.goldBright)
                        .padding(.top, 40)

                    Text("Spine Pro")
                        .font(SPTheme.titleFont)
                        .foregroundStyle(SPTheme.ink)

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow("infinity", "Unlimited shelved items")
                        featureRow("sparkles", "Support future updates")
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    Button {
                        purchasing = true
                        Task {
                            await purchases.purchase()
                            purchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        HStack {
                            if purchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(purchases.product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Pro")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(SPTheme.gold)
                        .foregroundStyle(SPTheme.backdrop)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .disabled(purchasing || purchases.product == nil)
                    .padding(.horizontal, 24)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .buttonStyle(.plain)
                    .font(.footnote)
                    .foregroundStyle(SPTheme.inkFaded)
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .buttonStyle(.plain)
                        .foregroundStyle(SPTheme.ink)
                }
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(SPTheme.goldBright)
                .frame(width: 24)
            Text(text)
                .foregroundStyle(SPTheme.ink)
        }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
