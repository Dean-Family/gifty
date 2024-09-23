//
//  GiftTests.swift
//  GiftyTests
//
//  Created by Gavin Dean on 9/22/24.
//

import XCTest
@testable import Gifty
import SwiftData

@available(iOS 17, *)
final class GiftTests: XCTestCase {
    
    func testGiftCreation() {
        let gift = Gift(name: "Test Gift", cents: 5000)
        XCTAssertEqual(gift.name, "Test Gift")
        XCTAssertEqual(gift.cents, 5000)
    }
    
    func testGiftAddPhoto() {
        let gift = Gift()
        let photoData = Data()
        gift.addPhoto(photoData)
        XCTAssertEqual(gift.photos.count, 1)
    }

    func testGiftRemovePhoto() {
        let gift = Gift()
        let photoData = Data()
        gift.addPhoto(photoData)
        gift.removePhoto(at: 0)
        XCTAssertEqual(gift.photos.count, 0)
    }

    func testGiftRelationshipWithGiftee() {
        let giftee = Giftee(firstname: "John", lastname: "Doe")
        let gift = Gift(name: "Book", cents: 2500, giftee: giftee)
        XCTAssertEqual(gift.giftee?.firstname, "John")
        XCTAssertEqual(gift.giftee?.lastname, "Doe")
    }
}
