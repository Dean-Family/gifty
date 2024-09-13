//
//  EventDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct EventDetailView: View {
    @Environment(\.modelContext) private var viewContext
    @State private var showingEditEventView: Bool = false
    @State private var showingAddGiftView: Bool = false
    @State private var refreshTrigger: Bool = false  // Trigger for view update

    var event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let eventName = event.name {
                Text(eventName)
                    .font(.title3)
            }
            if let eventDate = event.date {
                Text("Event on \(eventDate, formatter: dateFormatter)")
            } else {
                Text("Event on Unknown Date")
            }
            if let eventDescription = event.event_description {
                Text(eventDescription)
            }

            if let gifts = event.gifts, !gifts.isEmpty {
                List {
                    Section(header: Text("Gifts").font(.headline)) {
                        ForEach(gifts, id: \.self) { gift in
                            NavigationLink {
                                GiftDetailView(gift: gift)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(gift.name ?? "Unknown")
                                            .font(.headline)

                                        if let giftee = gift.giftee {
                                            Text("For \(giftee.firstname ?? "Unknown") \(giftee.lastname ?? "Unknown")")
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
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            refreshTrigger.toggle()  // Trigger the view update
        }
        .id(refreshTrigger)  // Force a refresh of the list
        .sheet(isPresented: $showingEditEventView) {
            EditEventView(event: event)
                .environment(\.modelContext, viewContext)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(event: event)
                .environment(\.modelContext, viewContext)
                .onDisappear {
                    refreshTrigger.toggle()  // Trigger a refresh when AddGiftView is dismissed
                }
        }
    }

    private func deleteGift(gift: Gift) {
        withAnimation {
            viewContext.delete(gift)
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
