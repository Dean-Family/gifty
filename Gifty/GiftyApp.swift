//
//  GiftyApp.swift
//  Gifty
//
//  Created by Gavin Dean on 1/5/23.
//

import SwiftUI

@main
struct GiftyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
               .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
