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
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var showingAddItemView: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("\(item.name ?? "Unknown")")
                    } label: {
                        Text(item.name ?? "Unknown")
                    }
                    .contextMenu { // Context menu for right-click actions
                                Button(action: {
                                    deleteItem(item: item)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                }
                .onDelete(perform: deleteItems)
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
                        showingAddItemView = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                

            }
            Text("Select an item")
            
        }
        .sheet(isPresented: $showingAddItemView) {
            AddItemView().environment(\.managedObjectContext, self.viewContext)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
    private func deleteItem(item: Item) {
        withAnimation {
            viewContext.delete(item)

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

private let itemFormatter: DateFormatter = {
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
