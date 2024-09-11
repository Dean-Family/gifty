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

    var event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Event on \(event.date ?? Date(), formatter: dateFormatter)")
                .font(.title2)
                .padding()

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
        .sheet(isPresented: $showingEditEventView) {
            EditEventView(event: event)
                .environment(\.modelContext, viewContext)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(event: event)
                .environment(\.modelContext, viewContext)
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
