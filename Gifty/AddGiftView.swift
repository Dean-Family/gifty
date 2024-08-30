//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//
import SwiftUI
import CoreData
import ContactsUI

struct AddGiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastname, ascending: true)]
    ) var persons: FetchedResults<Person>

    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)]
    ) var events: FetchedResults<Event>
    
    @State private var giftName: String = ""
    @State private var selectedPerson: Person?
    @State private var selectedEvent: Event?
    @State private var showingContactPicker = false
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Gift", displayMode: .inline)
                .onAppear(perform: setDefaultSelections)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear(perform: setDefaultSelections)
        #endif
    }
    
    var formContent: some View {
        VStack {
            TextField("Gift name", text: $giftName, onCommit: {
                addGift()
            })
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            
            Picker("Select Person", selection: $selectedPerson) {
                ForEach(persons, id: \.self) { person in
                    Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "")").tag(person as Person?)
                }
            }
            
            Button("Select from Contacts") {
                showingContactPicker = true
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    saveContactToCoreData(contact: contact)
                }
            }
            
            Picker("Select Event", selection: $selectedEvent) {
                ForEach(events, id: \.self) { event in
                    Text(event.name ?? "Unknown").tag(event as Event?)
                }
            }
            
            Button("Save") {
                addGift()
            }
        }
        .padding()
    }

    private func setDefaultSelections() {
        if let firstPerson = persons.first {
            selectedPerson = firstPerson
        }
        if let firstEvent = events.first {
            selectedEvent = firstEvent
        }
    }
    
    private func saveContactToCoreData(contact: CNContact) {
        let newPerson = Person(context: viewContext)
        newPerson.firstname = contact.givenName
        newPerson.lastname = contact.familyName
        
        do {
            try viewContext.save()
            selectedPerson = newPerson
        } catch {
            // Handle the error
        }
    }
    
    private func addGift() {
        let newGift = Gift(context: viewContext)
        newGift.name = giftName
        newGift.person = selectedPerson
        newGift.event = selectedEvent
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
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

struct AddGiftView_Previews: PreviewProvider {
    static var previews: some View {
        AddGiftView()
    }
}
