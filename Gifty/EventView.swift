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
                Section(header: Text("Events").font(.headline)) {
                    ForEach(events) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.name ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(event.date!, formatter: dateFormatter)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                        .contextMenu {
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
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
