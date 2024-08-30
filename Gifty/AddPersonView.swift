//
//  AddPersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import CoreData
import ContactsUI

struct AddPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var personFirstName: String = ""
    @State private var personLastName: String = ""
    @State private var showingContactPicker = false

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
            
            Button("Select from Contacts") {
                showingContactPicker = true
            }
        #if os(iOS)
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    personFirstName = contact.givenName
                    personLastName = contact.familyName
                }
            }
            #endif
            
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

        #if os(iOS)
struct ContactPickerView: UIViewControllerRepresentable {
    var didSelectContact: (CNContact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(didSelectContact: didSelectContact)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var didSelectContact: (CNContact) -> Void
        
        init(didSelectContact: @escaping (CNContact) -> Void) {
            self.didSelectContact = didSelectContact
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            didSelectContact(contact)
        }
    }
}

#endif
#Preview {
    AddPersonView()
}
