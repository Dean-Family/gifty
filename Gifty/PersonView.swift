//
//  PersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct PersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var persons: [Person]

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
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
            AddPersonView()
        }
    }

    private func fullName(for person: Person) -> String {
        let firstName = person.firstname ?? "Unknown"
        let lastName = person.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }

    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach { modelContext.delete($0) }

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deletePerson(person: Person) {
        withAnimation {
            modelContext.delete(person)

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

@available(iOS 17, *)
struct PersonView_Previews: PreviewProvider {
    static var previews: some View {
        PersonView()
    }
}
