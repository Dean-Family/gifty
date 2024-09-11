//
//  ContentView.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Gift.name, order: .forward)
    private var gifts: [Gift]
    
    @State private var showingAddGiftView: Bool = false

    var body: some View {
        NavigationView {
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

                                    if let person = gift.person, let event = gift.event {
                                        Text("For \(person.firstname ?? "Unknown") \(person.lastname ?? "Unknown")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        Text("\(event.name ?? "Unknown") on \(event.date!, formatter: dateFormatter)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    } else if let person = gift.person {
                                        Text("For \(person.firstname ?? "Unknown") \(person.lastname ?? "Unknown")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    } else if let event = gift.event {
                                        Text("\(event.name ?? "Unknown") on \(event.date!, formatter: dateFormatter)")
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
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddGiftView = true
                    }) {
                        Label("Add Gift", systemImage: "plus")
                    }
                }
            }
            Text("Select a gift")
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView().environment(\.modelContext, self.modelContext)
        }
    }

    private func deleteGifts(offsets: IndexSet) {
        withAnimation {
            offsets.map { gifts[$0] }.forEach { modelContext.delete($0) }

            do {
                try modelContext.save()
            } catch {
                print("Error saving after deleting gifts: \(error)")
            }
        }
    }

    private func deleteGift(gift: Gift) {
        withAnimation {
            modelContext.delete(gift)

            do {
                try modelContext.save()
            } catch {
                print("Error saving after deleting gift: \(error)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

@available(iOS 17, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().modelContainer(for: [Gift.self, Event.self, Person.self])
    }
}
