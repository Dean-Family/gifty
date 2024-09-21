//
//  GiftyUITests.swift
//  GiftyUITests
//
//  Created by Gavin Dean on 7/9/23.
//


import XCTest

final class GiftyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Set up is called before each test method invocation.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Tear down is called after each test method invocation.
    }

    func testTabSelection() throws {
        let app = XCUIApplication()
        app.launch()

        // Test default tab is Gifts
        XCTAssertTrue(app.tabBars.buttons["Gifts"].isSelected, "Expected the default tab to be Gifts")

        // Switch to Events tab
        app.tabBars.buttons["Events"].tap()
        XCTAssertTrue(app.tabBars.buttons["Events"].isSelected, "Expected Events tab to be selected")
        
        // Switch to Giftees tab
        app.tabBars.buttons["Giftees"].tap()
        XCTAssertTrue(app.tabBars.buttons["Giftees"].isSelected, "Expected Giftees tab to be selected")
    }
    func testGiftsTabIsSelectedByDefault() throws {
        let app = XCUIApplication()
        app.launch()

        // Check that the Gifts tab is selected by default
        XCTAssertTrue(app.tabBars.buttons["Gifts"].isSelected, "Expected the Gifts tab to be selected when the app launches.")
    }


    func testEventsTabSelection() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap on Events tab
        app.tabBars.buttons["Events"].tap()

        // Check that the Events tab is selected
        XCTAssertTrue(app.tabBars.buttons["Events"].isSelected, "Expected the Events tab to be selected.")
    }

    func testGifteesTabSelection() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap on Giftees tab
        app.tabBars.buttons["Giftees"].tap()

        // Check that the Giftees tab is selected
        XCTAssertTrue(app.tabBars.buttons["Giftees"].isSelected, "Expected the Giftees tab to be selected.")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
