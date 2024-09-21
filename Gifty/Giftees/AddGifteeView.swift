//
//  AddGifteeView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import ContactsUI
import SwiftData

@available(iOS 17, *)
struct AddGifteeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State private var gifteeFirstName: String = ""
    @State private var gifteeLastName: String = ""
    @State private var showingContactPicker = false

    var body: some View {
        NavigationView {
            formContent
                .navigationBarTitle("Add Giftee", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addGiftee()
                        }
                    }
                }
        }
    }
    
    var formContent: some View {
        VStack(spacing: 20) {
            TextField("Giftee first name", text: $gifteeFirstName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            TextField("Giftee last name", text: $gifteeLastName)
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
                    gifteeFirstName = contact.givenName
                    gifteeLastName = contact.familyName
                }
            }
        }
        .padding()
    }
    
    private func addGiftee() {
        let newGiftee = Giftee(firstname: gifteeFirstName, lastname: gifteeLastName)
        modelContext.insert(newGiftee)
        
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving giftee: \(error.localizedDescription)")
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

@available(iOS 17, *)
struct AddGifteeView_Previews: PreviewProvider {
    static var previews: some View {
        AddGifteeView()
            .modelContainer(for: [Giftee.self]) // Pass the container for the Giftee model
    }
}
