//
//  PersonDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//
import SwiftUI
import CoreData

struct PersonDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditPersonView: Bool = false
    @State private var showingAddGiftView: Bool = false

    @ObservedObject var person: Person

    // FetchRequest to get the gifts associated with this person
    @FetchRequest private var gifts: FetchedResults<Gift>

    init(person: Person) {
        self.person = person

        // Initialize the FetchRequest to filter gifts by this person
        _gifts = FetchRequest<Gift>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Gift.name, ascending: true)]
//            predicate: NSPredicate(format: "person == %@", person)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(person: person)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func fullName(for person: Person) -> String {
        let firstName = person.firstname ?? "Unknown"
        let lastName = person.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
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
