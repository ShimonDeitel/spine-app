import SwiftUI

struct SpineHomeView: View {
    @EnvironmentObject private var store: SpineStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var activeSheet: SpineSheet?
    @State private var deletingItem: ShelfItem?
    @State private var selectedItem: ShelfItem?

    var body: some View {
        NavigationStack {
            ZStack {
                SPTheme.backdrop.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text("Spine")
                                .font(SPTheme.titleFont)
                                .foregroundStyle(SPTheme.ink)
                            Spacer()
                            Button {
                                if store.canAddItem(isPro: purchases.isPro) {
                                    activeSheet = .add
                                } else {
                                    activeSheet = .paywall
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(SPTheme.gold)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("addItemButton")
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 8)

                        if store.items.isEmpty {
                            emptyState
                        } else {
                            LiteralShelfView(items: store.items) { item in
                                selectedItem = item
                            }
                            .padding(.horizontal, 18)

                            if !purchases.isPro {
                                Text("Free plan: \(store.items.count)/\(SpineStore.freeItemLimit) items shelved")
                                    .font(.caption)
                                    .foregroundStyle(SPTheme.inkFaded)
                                    .padding(.horizontal, 18)
                            }

                            VStack(spacing: 10) {
                                ForEach(store.items) { item in
                                    ItemRow(
                                        item: item,
                                        onEdit: { activeSheet = .edit(item) },
                                        onDelete: { deletingItem = item }
                                    )
                                    .accessibilityIdentifier("itemRow_\(item.title)")
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 12)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    ItemFormView(existing: nil)
                case .edit(let item):
                    ItemFormView(existing: item)
                case .paywall:
                    PaywallView()
                }
            }
            .sheet(item: $selectedItem) { item in
                ItemFormView(existing: item)
            }
            .confirmationDialog(
                "Remove this item from the shelf?",
                isPresented: Binding(
                    get: { deletingItem != nil },
                    set: { if !$0 { deletingItem = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    if let deletingItem {
                        store.deleteItem(deletingItem.id)
                    }
                    self.deletingItem = nil
                }
                Button("Cancel", role: .cancel) {
                    deletingItem = nil
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 48))
                .foregroundStyle(SPTheme.inkFaded)
            Text("Your shelf is empty")
                .font(SPTheme.headlineFont)
                .foregroundStyle(SPTheme.ink)
            Text("Tap + to add a vinyl record, book, or game to your shelf.")
                .font(.subheadline)
                .foregroundStyle(SPTheme.inkFaded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Add an Item") {
                if store.canAddItem(isPro: purchases.isPro) {
                    activeSheet = .add
                } else {
                    activeSheet = .paywall
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(SPTheme.gold)
            .foregroundStyle(SPTheme.backdrop)
            .clipShape(Capsule())
        }
        .padding(.top, 60)
        .padding(.horizontal, 18)
    }
}

/// The quirky signature feature: the collection renders as a literal wood
/// shelf with each item drawn as an upright spine (varying height/color per
/// type), not a plain list — tap a spine to open it.
struct LiteralShelfView: View {
    let items: [ShelfItem]
    var onTapItem: (ShelfItem) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(items) { item in
                    SpineBar(item: item)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .ignore)
                        .accessibilityIdentifier("spineBar_\(item.title)")
                        .accessibilityAddTraits(.isButton)
                        .onTapGesture {
                            onTapItem(item)
                        }
                }
            }
            .padding(.bottom, 14)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(SPTheme.surfaceRaised)
                    .frame(height: 14)
                    .offset(y: 14)
            }
        }
        .frame(height: 190)
    }
}

struct SpineBar: View {
    let item: ShelfItem

    private var height: CGFloat {
        switch item.type {
        case .vinyl: return 150
        case .book: return 160
        case .game: return 110
        }
    }

    private var width: CGFloat {
        switch item.type {
        case .vinyl: return 34
        case .book: return 28
        case .game: return 24
        }
    }

    var body: some View {
        VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 3)
                .fill(item.spineColor)
                .frame(width: width, height: height)
                .overlay(
                    VStack {
                        Image(systemName: item.type.systemImage)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.top, 8)
                        Spacer()
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 0)
        }
    }
}

struct ItemRow: View {
    let item: ShelfItem
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onEdit) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.spineColor)
                        .frame(width: 34, height: 44)
                        .overlay(
                            Image(systemName: item.type.systemImage)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(SPTheme.headlineFont)
                            .foregroundStyle(SPTheme.ink)
                        if !item.creator.isEmpty {
                            Text(item.creator)
                                .font(.subheadline)
                                .foregroundStyle(SPTheme.inkFaded)
                        }
                        Text(item.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(SPTheme.inkFaded)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(SPTheme.inkFaded)
                    .padding(8)
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .ignore)
                    .accessibilityIdentifier("itemMenu_\(item.title)")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .padding(12)
        .background(SPTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SPTheme.rule, lineWidth: 1)
        )
    }
}

#Preview {
    SpineHomeView()
        .environmentObject(SpineStore())
        .environmentObject(PurchaseManager())
}
