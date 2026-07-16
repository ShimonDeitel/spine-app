import Foundation
import Combine

@MainActor
final class SpineStore: ObservableObject {
    @Published private(set) var items: [ShelfItem] = []

    static let freeItemLimit = 6

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("spine_data.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
        }
        load()
        if items.isEmpty {
            seedDefaults()
        }
    }

    private func seedDefaults() {
        items = [
            ShelfItem(title: "Kind of Blue", creator: "Miles Davis", type: .vinyl, spineRed: 0.16, spineGreen: 0.24, spineBlue: 0.35),
            ShelfItem(title: "Dune", creator: "Frank Herbert", type: .book, spineRed: 0.62, spineGreen: 0.44, spineBlue: 0.20),
            ShelfItem(title: "Chrono Trigger", creator: "Square", type: .game, spineRed: 0.42, spineGreen: 0.20, spineBlue: 0.46)
        ]
        save()
    }

    func canAddItem(isPro: Bool) -> Bool {
        isPro || items.count < Self.freeItemLimit
    }

    @discardableResult
    func addItem(
        title: String,
        creator: String,
        type: CollectionType,
        spineRed: Double,
        spineGreen: Double,
        spineBlue: Double,
        coverPhotoData: Data?,
        isPro: Bool
    ) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAddItem(isPro: isPro) else { return false }
        items.append(ShelfItem(
            title: trimmed,
            creator: creator.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            spineRed: spineRed,
            spineGreen: spineGreen,
            spineBlue: spineBlue,
            coverPhotoData: coverPhotoData
        ))
        save()
        return true
    }

    func updateItem(
        _ id: UUID,
        title: String,
        creator: String,
        type: CollectionType,
        spineRed: Double,
        spineGreen: Double,
        spineBlue: Double,
        coverPhotoData: Data?
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].title = trimmed
        items[idx].creator = creator.trimmingCharacters(in: .whitespacesAndNewlines)
        items[idx].type = type
        items[idx].spineRed = spineRed
        items[idx].spineGreen = spineGreen
        items[idx].spineBlue = spineBlue
        if let coverPhotoData {
            items[idx].coverPhotoData = coverPhotoData
        }
        save()
    }

    func deleteItem(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func item(_ id: UUID) -> ShelfItem? {
        items.first { $0.id == id }
    }

    func deleteAllData() {
        items = []
        seedDefaults()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [ShelfItem]
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            items = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: items)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
