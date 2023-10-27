//
//  GiftyApp.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI

@main
struct GiftyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
