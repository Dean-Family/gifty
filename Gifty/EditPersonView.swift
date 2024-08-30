//
//  EditPersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct EditPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var person: Person

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("First Name")) {
                    TextField("First Name", text: $person.firstname.bound)
                }

                Section(header: Text("Last Name")) {
                    TextField("Last Name", text: $person.lastname.bound)
                }

                Section {
                    Button("Save") {
                        do {
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error saving person: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationTitle("Edit Person")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EditPersonView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newPerson = Person(context: context)
        newPerson.firstname = "John"
        newPerson.lastname = "Doe"

        return EditPersonView(person: newPerson)
            .environment(\.managedObjectContext, context)
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        get { self ?? "" }
        set { self = newValue }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
