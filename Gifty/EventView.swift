//
//  EventView.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct EventView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date, order: .forward) private var events: [Event]
    @State private var showingAddEventView: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Events").font(.headline)) {
                    ForEach(events, id: \.self) { event in
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
            AddEventView().environment(\.modelContext, self.modelContext)
        }
    }

    private func deleteEvents(offsets: IndexSet) {
        withAnimation {
            offsets.map { events[$0] }.forEach(modelContext.delete)

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteEvent(event: Event) {
        withAnimation {
            modelContext.delete(event)

            do {
                try modelContext.save()
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

@available(iOS 17, *)
struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView().modelContainer(for: [Event.self, Person.self, Gift.self])
    }
}
