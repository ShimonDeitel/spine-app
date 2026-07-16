import XCTest
@testable import Spine

final class SpineTests: XCTestCase {

    @MainActor
    private func freshStore() -> SpineStore {
        let store = SpineStore()
        for i in store.items { store.deleteItem(i.id) }
        return store
    }

    @MainActor
    func testAddItemRespectsFreeLimit() {
        let store = freshStore()
        for title in ["A", "B", "C", "D", "E", "F"] {
            XCTAssertTrue(store.addItem(title: title, creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: false))
        }
        XCTAssertFalse(store.addItem(title: "Overflow", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: false))
        XCTAssertTrue(store.addItem(title: "Overflow", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: true))
    }

    @MainActor
    func testAddItemRejectsBlankTitle() {
        let store = freshStore()
        XCTAssertFalse(store.addItem(title: "   ", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: false))
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testAddItemStoresCoverPhotoData() {
        let store = freshStore()
        let data = Data([0x01, 0x02])
        store.addItem(title: "OK Computer", creator: "Radiohead", type: .vinyl, spineRed: 0.2, spineGreen: 0.2, spineBlue: 0.2, coverPhotoData: data, isPro: false)
        let saved = store.items[0]
        XCTAssertEqual(saved.coverPhotoData, data)
        XCTAssertTrue(saved.hasCover)
        XCTAssertEqual(saved.type, .vinyl)
    }

    @MainActor
    func testUpdateItemChangesFields() {
        let store = freshStore()
        store.addItem(title: "Old Title", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: false)
        let item = store.items[0]
        store.updateItem(item.id, title: "New Title", creator: "Author", type: .game, spineRed: 0.1, spineGreen: 0.1, spineBlue: 0.1, coverPhotoData: nil)
        let updated = store.item(item.id)!
        XCTAssertEqual(updated.title, "New Title")
        XCTAssertEqual(updated.type, .game)
    }

    @MainActor
    func testUpdatePreservesExistingCoverWhenNoNewOneProvided() {
        let store = freshStore()
        let data = Data([0x09])
        store.addItem(title: "Item", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: data, isPro: false)
        let item = store.items[0]
        store.updateItem(item.id, title: "Item", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil)
        XCTAssertEqual(store.item(item.id)!.coverPhotoData, data)
    }

    @MainActor
    func testDeleteItemRemovesIt() {
        let store = freshStore()
        store.addItem(title: "Removable", creator: "", type: .book, spineRed: 0.5, spineGreen: 0.5, spineBlue: 0.5, coverPhotoData: nil, isPro: false)
        let item = store.items[0]
        store.deleteItem(item.id)
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = freshStore()
        store.deleteAllData()
        XCTAssertFalse(store.items.isEmpty)
    }
}
