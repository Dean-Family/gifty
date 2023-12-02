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
                ForEach(gifts) { gift in
                    NavigationLink {
                        Text(gift.name ?? "Unknown")
                    } label: {
                        Text(gift.name ?? "Unknown")
                    }
                    .contextMenu { // Context menu for right-click actions
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
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        action: {
                        showingAddGiftView = true
                    }) {
                        Label("Add Gift", systemImage: "plus")
                    }
                }
                

            }
            Text("Select an gift")
            
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
                // Handle the error appropriately
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

private let giftFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
