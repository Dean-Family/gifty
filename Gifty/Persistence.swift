//
//  Persistence.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

//import SwiftData
//import Foundation
//
//@available(iOS 17, *)
//struct PersistenceController {
//    static let shared = PersistenceController()
//
//    @MainActor
//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let modelContext = result.modelContainer.mainContext
//        
//        for _ in 0..<10 {
//            let newGift = Gift(name: "Gift")
//            modelContext.insert(newGift)
//        }
//        for _ in 0..<10 {
//            let newEvent = Event(date: Date(), name: "Christmas")
//            modelContext.insert(newEvent)
//        }
//        for _ in 0..<10 {
//            let newGiftee = Giftee(firstname: "Tina", lastname: "Esting")
//            modelContext.insert(newGiftee)
//        }
//        return result
//    }()
//
//    let modelContainer: ModelContainer
//
//    init(inMemory: Bool = false) {
//        let config = ModelConfiguration(isStoredInMemory: inMemory)
//        modelContainer = try! ModelContainer(for: [Gift.self, Giftee.self, Event.self], configuration: config)
//    }
//}
