//
//  Event.swift
//  Gifty
//
//  Created by Gavin Dean on 9/2/24.
//
//

import Foundation
import SwiftData


@available(iOS 17, *)
@Model public class Event {
    var date: Date?
    var name: String?
    var event_description: String?
    var gifts: [Gift]?

    public init(date: Date? = nil, name: String? = nil, event_description: String? = nil) {
        self.date = date
        self.name = name
        self.event_description = event_description
    }
}
