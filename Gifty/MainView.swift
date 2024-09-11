//
//  MainView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/25/23.
//

import SwiftUI

@available(iOS 17, *)
struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Gift View
            ContentView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Gifts")
                }
                .tag(0)
            
            // Event View
            EventView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
                .tag(1)
            
            // People View
            PersonView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("People")
                }
                .tag(2)
        }
#if os(OSX)
        .padding()
#endif
    }
}


@available(iOS 17, *)
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
