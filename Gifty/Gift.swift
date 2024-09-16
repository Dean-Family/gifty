//
//  Gift.swift
//  Gifty
//
//  Created by Gavin Dean on 9/2/24.
//
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model public class Gift {
    var name: String?
    var cents: Int64?
    var item_description: String?
    var link: String?
    var location: String?
    var status: String?
    var event: Event?
    var giftee: Giftee?
    
    // Add a property to store photos as an array of Data
    var photos: [Data] = []
    
    public init(name: String? = nil, cents: Int64? = 0, item_description: String? = nil, link: String? = nil, location: String? = nil, status: String? = nil, event: Event? = nil, giftee: Giftee? = nil, photos: [Data] = []) {
        self.name = name
        self.cents = cents
        self.item_description = item_description
        self.link = link
        self.location = location
        self.status = status
        self.event = event
        self.giftee = giftee
        self.photos = photos
    }
    
    // Method to add a new photo
    func addPhoto(_ photo: Data) {
        photos.append(photo)
    }
    
    // Method to remove a photo at a specific index
    func removePhoto(at index: Int) {
        if photos.indices.contains(index) {
            photos.remove(at: index)
        }
    }
}
