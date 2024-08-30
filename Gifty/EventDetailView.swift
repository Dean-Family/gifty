//
//  EventDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct EventDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditEventView: Bool = false

    @ObservedObject var event: Event

    var body: some View {
        VStack {
            Spacer()
            Text("Event on \(event.date!, formatter: dateFormatter)")
                .font(.title2)
                .padding()

            Spacer()
        }
        .navigationTitle(event.name ?? "Event")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditEventView = true
                }
            }
        }
        .sheet(isPresented: $showingEditEventView) {
            EditEventView(event: event)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
