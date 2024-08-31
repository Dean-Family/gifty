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
    @State private var showingAddGiftView: Bool = false

    @ObservedObject var event: Event

    // FetchRequest to get the gifts associated with this event
    @FetchRequest private var gifts: FetchedResults<Gift>

    init(event: Event) {
        self.event = event

        // Initialize the FetchRequest to filter gifts by this event
        _gifts = FetchRequest<Gift>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Gift.name, ascending: true)],
            predicate: NSPredicate(format: "event == %@", event)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Event on \(event.date!, formatter: dateFormatter)")
                .font(.title2)
                .padding()

            if !gifts.isEmpty {
                List {
                    Section(header: Text("Gifts").font(.headline)) {
                        ForEach(gifts) { gift in
                            NavigationLink {
                                GiftDetailView(gift: gift)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(gift.name ?? "Unknown")
                                            .font(.headline)

                                        if let person = gift.person {
                                            Text("For \(person.firstname ?? "Unknown") \(person.lastname ?? "Unknown")")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                            .contextMenu {
                                Button(action: {
                                    deleteGift(gift: gift)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteGifts)
                    }
                }
            } else {
                Text("No gifts associated with this event.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle(event.name ?? "Event")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button("Edit") {
                        showingEditEventView = true
                    }
                    Button(action: {
                        showingAddGiftView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditEventView) {
            EditEventView(event: event)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(event: event)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func deleteGifts(offsets: IndexSet) {
        withAnimation {
            offsets.map { gifts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteGift(gift: Gift) {
        withAnimation {
            viewContext.delete(gift)

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
