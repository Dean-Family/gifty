//
//  EventView.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI
import CoreData

struct EventView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)],
        animation: .default)
    private var events: FetchedResults<Event>
    @State private var showingAddEventView: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(events) { event in
                    NavigationLink {
                        Text("Event on \(event.date!, formatter: dateFormatter)")
                        Text("\(event.name ?? "Unknown")")
                    } label: {
                        Text(event.date!, formatter: dateFormatter)
                        Text(event.name ?? "Unknown")
                    }
                    .contextMenu { // Context menu for right-click actions
                                Button(action: {
                                    deleteEvent(event: event)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                }
                .onDelete(perform: deleteEvents)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        action: {
                        showingAddEventView = true
                    }) {
                        Label("Add Event", systemImage: "plus")
                    }
                }
                

            }
            Text("Select an event")
            
        }
        .sheet(isPresented: $showingAddEventView) {
            AddEventView().environment(\.managedObjectContext, self.viewContext)
        }
    }

    private func deleteEvents(offsets: IndexSet) {
        withAnimation {
            offsets.map { events[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    private func deleteEvent(event: Event) {
        withAnimation {
            viewContext.delete(event)

            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
