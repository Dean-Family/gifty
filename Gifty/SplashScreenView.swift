//
//  SplashScreenView.swift
//  Gifty
//
//  Created by Gavin Dean on 4/10/23.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                GiftsView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            } else {
                Image("Title")
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
