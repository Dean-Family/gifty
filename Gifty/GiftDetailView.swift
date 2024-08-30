//
//  GiftDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct GiftDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var gift: Gift

    @State private var showingEditGiftView = false

    var body: some View {
        VStack {

            if let person = gift.person {
                Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "?")")
                    .font(.title2)
                    .padding()
            }

            if let event = gift.event {
                Text("Event on \(event.date!, formatter: dateFormatter)")
                    .font(.title2)
                    .padding()
                Text(event.name ?? "Unknown")
            }

            Spacer()
        }
        .navigationTitle(gift.name ?? "Gift")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit Gift") {
                    showingEditGiftView = true
                }
            }
        }
        .sheet(isPresented: $showingEditGiftView) {
            EditGiftView(gift: gift).environment(\.managedObjectContext, viewContext)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
