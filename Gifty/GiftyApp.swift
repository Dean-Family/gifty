//
//  GiftyApp.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI

@available(iOS 17, *)
@main
struct GiftyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [Gift.self, Person.self, Event.self])
    }
}
