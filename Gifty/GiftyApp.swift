//
//  GiftyApp.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
@main
struct GiftyApp: App {
    let modelContainer: ModelContainer

        init() {
            do {
                modelContainer = try ModelContainer(for: Gift.self, Giftee.self, Event.self)
            } catch {
                fatalError("Could not initialize ModelContainer: \(error)")
            }
        }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [Gift.self, Giftee.self, Event.self])
    }
}
