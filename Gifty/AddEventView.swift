//
//  AddEventView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import ContactsUI
import SwiftData

@available(iOS 17, *)
struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventDescription: String = ""

    #if os(iOS)
    @State private var selectedContact: CNContact?
    @State private var showingContactPicker = false
    #endif

    var body: some View {
        NavigationView {
            formContent
                .navigationBarTitle("Add Event", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addEvent()
                        }
                    }
                }
        }
    }

    var formContent: some View {
        VStack(spacing: 20) {
            TextField("Event name", text: $eventName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

            DatePicker("Event Date", selection: $eventDate, displayedComponents: [.date])
                .padding()
                TextEditor(text: $eventDescription)
                    .frame(height: 100)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .autocapitalization(.sentences)

            #if os(iOS)
            Button("Get Birthday From Contacts") {
                showingContactPicker = true
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    handleSelectedContact(contact: contact)
                }
            }
            #endif
        }
        .padding()
    }

    #if os(iOS)
    private func handleSelectedContact(contact: CNContact) {
        selectedContact = contact

        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "\(contact.givenName) \(contact.familyName)"

        if eventName.isEmpty {
            eventName = fullName.hasSuffix("s") ? "\(fullName)' Birthday" : "\(fullName)'s Birthday"
        }

        if let birthday = contact.birthday {
            var dateComponents = DateComponents()
            dateComponents.day = birthday.day
            dateComponents.month = birthday.month
            let currentYear = Calendar.current.component(.year, from: Date())

            dateComponents.year = currentYear
            if let birthdateThisYear = Calendar.current.date(from: dateComponents), birthdateThisYear < Date() {
                dateComponents.year = currentYear + 1
            }

            if let birthdate = Calendar.current.date(from: dateComponents) {
                eventDate = birthdate
            }
        }
    }
    #endif

    private func addEvent() {
        let newEvent = Event(date: eventDate, name: eventName)
        modelContext.insert(newEvent)

        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Handle the error
        }
    }
}

@available(iOS 17, *)
struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
