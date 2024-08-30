//
//  ContentView.swift
//  Gifty
//
//  Created by Gavin Dean on 7/9/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Gift.name, ascending: true)],
        animation: .default)
    private var gifts: FetchedResults<Gift>
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
            AddGiftView().environment(\.managedObjectContext, self.viewContext)
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
    formatter.dateStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
