//
//  Giftee.swift
//  Gifty
//
//  Created by Gavin Dean on 9/2/24.
//
//

import Foundation
import SwiftData


@available(iOS 17, *)
@Model public class Giftee {
    var firstname: String?
    var lastname: String?
    var gifts: [Gift]?

    public init(firstname: String? = nil, lastname: String? = nil) {
        self.firstname = firstname
        self.lastname = lastname
    }
}
