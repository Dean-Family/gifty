//
//  AddPersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI

struct AddPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var personFirstName: String = ""
    @State private var personLastName: String = ""

    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Person", displayMode: .inline)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    var formContent: some View {
            VStack {
                TextField("Person first name", text: $personFirstName, onCommit: {
                    addPerson()
                })
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                TextField("Person last name", text: $personLastName, onCommit: {
                    addPerson()
                })
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                Button("Save") {
                    addPerson()
                }
            }
            .padding()
        }
    
    private func addPerson() {
        let newPerson = Person(context: viewContext)
        newPerson.firstname = personFirstName
        newPerson.lastname = personLastName
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
}

#Preview {
    AddPersonView()
}
