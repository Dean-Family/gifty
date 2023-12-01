//
//  MainView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/25/23.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Item View
            ContentView()
                .tabItem {
                    Image(systemName: "gift")
                    Text("Items")
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
            PeopleView()
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

struct PeopleView: View {
    var body: some View {
        NavigationView {
            Text("People for giftees go here")
                .navigationTitle("People")
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
