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
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastname, ascending: true)],
        animation: .default
    ) private var persons: FetchedResults<Person>

    @State private var showingAddPersonView: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("People").font(.headline)) {
                    ForEach(persons) { person in
                        NavigationLink(destination: PersonDetailView(person: person)) {
                            VStack(alignment: .leading) {
                                Text(fullName(for: person))
                                    .font(.headline)
                                    .padding(.vertical, 2)
                            }
                        }
                        .contextMenu {
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
            }
            .toolbar {
        #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddPersonView = true
                    }) {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            Text("Select a person")
        }
        .sheet(isPresented: $showingAddPersonView) {
            AddPersonView().environment(\.managedObjectContext, viewContext)
        }
    }

    private func fullName(for person: Person) -> String {
        let firstName = person.firstname ?? "Unknown"
        let lastName = person.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }

    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
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
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
