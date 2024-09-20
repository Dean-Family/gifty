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
            // Initialize the ModelContainer for your models
            modelContainer = try ModelContainer(for: Gift.self, Giftee.self, Event.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Pass the initialized modelContainer to the view
            MainView()
                .modelContainer(modelContainer) // Apply the initialized modelContainer here
        }
    }
}
