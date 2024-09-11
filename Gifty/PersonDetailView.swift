//
//  PersonDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//
import SwiftUI
import SwiftData

@available(iOS 17, *)
struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditPersonView: Bool = false
    @State private var showingAddGiftView: Bool = false

    @Bindable var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let gifts = person.gifts, !gifts.isEmpty {
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

                                        if let event = gift.event {
                                            Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
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
                Text("No gifts associated with this person.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle(fullName(for: person))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button("Edit") {
                        showingEditPersonView = true
                    }
                    Button(action: {
                        showingAddGiftView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditPersonView) {
            EditPersonView(person: person)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(person: person)
        }
    }
    private func fullName(for person: Person) -> String {
        let firstName = person.firstname ?? "Unknown"
        let lastName = person.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }

    private func deleteGifts(offsets: IndexSet) {
        withAnimation {
            if let gifts = person.gifts {
                offsets.map { gifts[$0] }.forEach { modelContext.delete($0) }

                do {
                    try modelContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    private func deleteGift(gift: Gift) {
        withAnimation {
            modelContext.delete(gift)

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
