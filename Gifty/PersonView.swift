//
//  PersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import CoreData

struct PersonView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastname, ascending: true)],
        animation: .default)
    private var persons: FetchedResults<Person>
    @State private var showingAddPersonView: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(persons) { person in
                    NavigationLink {
                        Text(person.firstname ?? "Unknown")
                        Text((person.lastname ?? "Unknown"))
                    } label: {
                        Text(person.firstname ?? "Unknown")
                        Text(person.lastname ?? "Unknown")
                    }
                    .contextMenu { // Context menu for right-click actions
                                Button(action: {
                                    deletePerson(person: person)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                }
                .onDelete(perform: deletePersons)
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
                        showingAddPersonView = true
                    }) {
                        Label("Add Person", systemImage: "plus")
                    }
                }
                

            }
            Text("Select an person")
            
        }
        .sheet(isPresented: $showingAddPersonView) {
            AddPersonView().environment(\.managedObjectContext, self.viewContext)
        }
    }

    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach(viewContext.delete)

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
    private func deletePerson(person: Person) {
        withAnimation {
            viewContext.delete(person)

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

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
