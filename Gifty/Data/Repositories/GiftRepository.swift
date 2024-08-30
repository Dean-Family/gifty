//
//  GiftRepository.swift
//  Gifty
//
//  Created by Gavin Dean on 7/15/24.
//

import CoreData

protocol GiftRepositoryProtocol {
    func addGift(name: String, date: Date)
    func getGifts() -> [Gift]
    func deleteGift(gift: Gift)
}

class GiftRepository: GiftRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addGift(name: String, date: Date) {
        let gift = Gift(context: context)
        gift.name = name
        gift.date = date
        saveContext()
    }
    
    func getGifts() -> [Gift] {
        let request: NSFetchRequest<Gift> = Gift.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch gifts: \(error)")
            return []
        }
    }
    
    func deleteGift(gift: Gift) {
        context.delete(gift)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
