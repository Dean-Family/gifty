//
//  AddPersonView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import ContactsUI
import SwiftData

@available(iOS 17, *)
struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State private var personFirstName: String = ""
    @State private var personLastName: String = ""
    @State private var showingContactPicker = false

    var body: some View {
        NavigationView {
            formContent
                .navigationBarTitle("Add Person", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addPerson()
                        }
                    }
                }
        }
    }
    
    var formContent: some View {
        VStack(spacing: 20) {
            TextField("Person first name", text: $personFirstName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            TextField("Person last name", text: $personLastName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            Divider()
                .padding(.vertical)
            
            Button("Select from Contacts") {
                showingContactPicker = true
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(.blue)
            .padding(.top)
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    personFirstName = contact.givenName
                    personLastName = contact.familyName
                }
            }
        }
        .padding()
    }
    
    private func addPerson() {
        let newPerson = Person(firstname: personFirstName, lastname: personLastName)
        modelContext.insert(newPerson)
        
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving person: \(error.localizedDescription)")
        }
    }
}

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
