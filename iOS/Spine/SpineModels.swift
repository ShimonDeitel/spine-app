import Foundation
import SwiftUI

enum CollectionType: String, Codable, CaseIterable, Identifiable {
    case vinyl = "Vinyl"
    case book = "Book"
    case game = "Game"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .vinyl: return "opticaldisc"
        case .book: return "book.closed"
        case .game: return "gamecontroller"
        }
    }
}

/// A single shelved collection item (vinyl record, book, or game).
struct ShelfItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var creator: String
    var type: CollectionType
    var spineRed: Double
    var spineGreen: Double
    var spineBlue: Double
    var coverPhotoData: Data?
    var createdDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        creator: String = "",
        type: CollectionType = .book,
        spineRed: Double = 0.55,
        spineGreen: Double = 0.35,
        spineBlue: Double = 0.28,
        coverPhotoData: Data? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.creator = creator
        self.type = type
        self.spineRed = spineRed
        self.spineGreen = spineGreen
        self.spineBlue = spineBlue
        self.coverPhotoData = coverPhotoData
        self.createdDate = createdDate
    }

    var spineColor: Color {
        Color(red: spineRed, green: spineGreen, blue: spineBlue)
    }

    var hasCover: Bool { coverPhotoData != nil }
}
