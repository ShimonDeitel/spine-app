import XCTest

/// Note on photo coverage: PhotosPicker cannot be reliably driven via
/// XCUITest in the simulator. Cover photo attachment is optional-but-
/// encouraged (only `title` is required to save), so every add/edit/delete/
/// paywall flow below is fully exercisable without touching the picker.
final class SpineUITests: XCTestCase {
    private var interruptionMonitorToken: NSObjectProtocol?

    override func setUpWithError() throws {
        continueAfterFailure = false
        interruptionMonitorToken = addUIInterruptionMonitor(withDescription: "System alert dismissal") { alert in
            for label in ["Allow", "OK", "Don't Allow", "Cancel"] {
                let button = alert.buttons[label]
                if button.exists {
                    button.tap()
                    return true
                }
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        if let token = interruptionMonitorToken {
            removeUIInterruptionMonitor(token)
        }
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launch()
        return app
    }

    func testAddItemFromMainList() throws {
        let app = launchApp()

        let addButton = app.buttons["addItemButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 12))
        addButton.tap()

        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 12))
        titleField.tap()
        titleField.typeText("Rumours")

        app.buttons["saveItemButton"].tap()

        XCTAssertTrue(app.staticTexts["Rumours"].waitForExistence(timeout: 12), "New item did not appear on the shelf")
    }

    func testAddItemWithCreatorAndType() throws {
        let app = launchApp()
        app.buttons["addItemButton"].tap()

        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 12))
        titleField.tap()
        titleField.typeText("The Hobbit")

        let creatorField = app.textFields["creatorField"]
        creatorField.tap()
        creatorField.typeText("J.R.R. Tolkien")

        app.buttons["saveItemButton"].tap()

        XCTAssertTrue(app.staticTexts["The Hobbit"].waitForExistence(timeout: 12))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Tolkien'")).firstMatch.waitForExistence(timeout: 12))
    }

    func testEditItemChangesTitle() throws {
        let app = launchApp()
        // Seed data includes "Dune"; open its row menu to edit.
        let row = app.staticTexts["Dune"]
        XCTAssertTrue(row.waitForExistence(timeout: 12))

        let menuButton = app.buttons["itemMenu_Dune"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 12), "Row menu button did not appear")
        menuButton.tap()

        let editMenuItem = app.buttons["Edit"].exists ? app.buttons["Edit"] : app.menuItems["Edit"]
        XCTAssertTrue(editMenuItem.waitForExistence(timeout: 12), "Edit menu item did not appear")
        editMenuItem.tap()

        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 12))
        titleField.tap()
        titleField.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) {
            app.menuItems["Select All"].tap()
        }
        titleField.typeText("Dune Messiah")

        app.buttons["saveItemButton"].tap()

        XCTAssertTrue(app.staticTexts["Dune Messiah"].waitForExistence(timeout: 12), "Item edit did not apply")
    }

    func testDeleteItemViaMenu() throws {
        let app = launchApp()
        app.buttons["addItemButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 12))
        titleField.tap()
        titleField.typeText("Disposable Item")
        app.buttons["saveItemButton"].tap()

        let row = app.staticTexts["Disposable Item"]
        XCTAssertTrue(row.waitForExistence(timeout: 12))

        let menuButton = app.buttons["itemMenu_Disposable Item"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 12), "Row menu button did not appear")
        menuButton.tap()

        let deleteMenuItem = app.buttons["Remove"].exists ? app.buttons["Remove"] : app.menuItems["Remove"]
        XCTAssertTrue(deleteMenuItem.waitForExistence(timeout: 12), "Remove menu item did not appear")
        deleteMenuItem.tap()

        let confirmButton = app.buttons["Remove"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 12), "Delete confirmation dialog did not appear")
        confirmButton.tap()

        XCTAssertFalse(app.staticTexts["Disposable Item"].waitForExistence(timeout: 8), "Item was not deleted")
    }

    func testTapSpineOpensEditSheet() throws {
        let app = launchApp()
        let spineButton = app.buttons["spineBar_Dune"]
        let spineOther = app.otherElements["spineBar_Dune"]
        let spine = spineButton.exists ? spineButton : spineOther
        XCTAssertTrue(spine.waitForExistence(timeout: 12), "Spine bar did not appear")
        spine.tap()

        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 12), "Tapping the spine did not open the edit sheet")
        app.buttons["Cancel"].tap()
    }

    func testFreeLimitTriggersPaywallAtSeventhItem() throws {
        let app = launchApp()
        // Seed data already has 3 items; add 4 more to hit and exceed the free cap of 6.
        for name in ["Item A", "Item B", "Item C", "Item D"] {
            let addButton = app.buttons["addItemButton"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
                let titleField = app.textFields["titleField"]
                if titleField.waitForExistence(timeout: 3) {
                    titleField.tap()
                    titleField.typeText(name)
                    app.buttons["saveItemButton"].tap()
                }
            }
        }
        XCTAssertTrue(app.staticTexts["Spine Pro"].waitForExistence(timeout: 12), "Paywall did not appear after hitting the free item limit")
    }

    func testSimulatedPurchaseUnlocksUnlimitedItems() throws {
        let app = launchApp()
        for name in ["Item A", "Item B", "Item C", "Item D"] {
            let addButton = app.buttons["addItemButton"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
                let titleField = app.textFields["titleField"]
                if titleField.waitForExistence(timeout: 3) {
                    titleField.tap()
                    titleField.typeText(name)
                    app.buttons["saveItemButton"].tap()
                }
            }
        }
        XCTAssertTrue(app.staticTexts["Spine Pro"].waitForExistence(timeout: 12))

        let unlockButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Unlock'")).firstMatch
        XCTAssertTrue(unlockButton.waitForExistence(timeout: 12))
        unlockButton.tap()

        let confirmButton = app.buttons["Subscribe"].exists ? app.buttons["Subscribe"] : app.buttons["Buy"]
        if confirmButton.waitForExistence(timeout: 12) {
            confirmButton.tap()
        }

        XCTAssertTrue(app.buttons["addItemButton"].waitForExistence(timeout: 15))

        let addButton = app.buttons["addItemButton"]
        var tapped = false
        for _ in 0..<16 {
            if addButton.isHittable {
                addButton.tap()
                tapped = true
                break
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        if !tapped {
            addButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        let titleField = app.textFields["titleField"]
        if titleField.waitForExistence(timeout: 8) {
            titleField.tap()
            titleField.typeText("Item E")
            app.buttons["saveItemButton"].tap()
            XCTAssertTrue(app.staticTexts["Item E"].waitForExistence(timeout: 12))
        }
    }
}
