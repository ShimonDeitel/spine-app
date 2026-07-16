import SwiftUI
import PhotosUI

enum SpineSheet: Identifiable {
    case add
    case edit(ShelfItem)
    case paywall

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return "edit-\(item.id)"
        case .paywall: return "paywall"
        }
    }
}

struct ItemFormView: View {
    @EnvironmentObject private var store: SpineStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let existing: ShelfItem?

    @State private var title: String
    @State private var creator: String
    @State private var type: CollectionType
    @State private var spineColor: Color
    @State private var pickerItem: PhotosPickerItem?
    @State private var coverPhotoData: Data?

    init(existing: ShelfItem?) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _creator = State(initialValue: existing?.creator ?? "")
        _type = State(initialValue: existing?.type ?? .book)
        _spineColor = State(initialValue: existing?.spineColor ?? Color(red: 0.55, green: 0.35, blue: 0.28))
        _coverPhotoData = State(initialValue: existing?.coverPhotoData)
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Title", text: $title)
                        .accessibilityIdentifier("titleField")
                    TextField("Artist / Author / Studio", text: $creator)
                        .accessibilityIdentifier("creatorField")
                    Picker("Type", selection: $type) {
                        ForEach(CollectionType.allCases) { t in
                            Label(t.rawValue, systemImage: t.systemImage).tag(t)
                        }
                    }
                    .accessibilityIdentifier("typePicker")
                }

                Section("Spine Color") {
                    ColorPicker("Spine color", selection: $spineColor, supportsOpacity: false)
                        .accessibilityIdentifier("spineColorPicker")
                }

                Section("Cover Photo") {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        HStack {
                            if let coverPhotoData, let uiImage = UIImage(data: coverPhotoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .foregroundStyle(SPTheme.gold)
                                    .frame(width: 44, height: 44)
                            }
                            Text(coverPhotoData != nil ? "Cover photo added" : "Add a cover photo")
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("coverPhotoPicker")
                }

                if isEditing {
                    Section {
                        Button("Remove from Shelf", role: .destructive) {
                            if let existing {
                                store.deleteItem(existing.id)
                            }
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("deleteItemButton")
                    }
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle(isEditing ? "Edit Item" : "Add to Shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.plain)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .buttonStyle(.plain)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("saveItemButton")
                }
            }
            .onChange(of: pickerItem) { _, item in
                Task {
                    if let item, let data = try? await item.loadTransferable(type: Data.self) {
                        coverPhotoData = data
                    }
                }
            }
        }
    }

    private func save() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let components = spineColor.resolve(in: EnvironmentValues())
        let red = Double(components.red)
        let green = Double(components.green)
        let blue = Double(components.blue)

        if let existing {
            store.updateItem(
                existing.id, title: title, creator: creator, type: type,
                spineRed: red, spineGreen: green, spineBlue: blue, coverPhotoData: coverPhotoData
            )
            dismiss()
        } else {
            guard store.canAddItem(isPro: purchases.isPro) else { return }
            store.addItem(
                title: title, creator: creator, type: type,
                spineRed: red, spineGreen: green, spineBlue: blue, coverPhotoData: coverPhotoData, isPro: purchases.isPro
            )
            dismiss()
        }
    }
}
