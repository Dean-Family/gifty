//
//  AddEventView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import CoreData
import ContactsUI

struct AddEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @State private var selectedContact: CNContact?
    @State private var showingContactPicker = false

    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Event", displayMode: .inline)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    var formContent: some View {
        VStack(spacing: 20) {
            TextField("Event name", text: $eventName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

            DatePicker("Event Date", selection: $eventDate, displayedComponents: [.date])
                .padding()

            Button("Get Birthday From Contacts") {
                showingContactPicker = true
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    handleSelectedContact(contact: contact)
                }
            }

            Button("Save") {
                addEvent()
            }
        }
        .padding()
    }

    private func handleSelectedContact(contact: CNContact) {
        selectedContact = contact

        // Use CNContactFormatter for full name formatting
        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "\(contact.givenName) \(contact.familyName)"

        // Check if the name ends with 's' and adjust possessive form
        if eventName.isEmpty {
            if fullName.last?.lowercased() == "s" {
                eventName = "\(fullName)' Birthday"
            } else {
                eventName = "\(fullName)'s Birthday"
            }
        }

        // If the contact has a birthday, use it to set the event date
        if let birthday = contact.birthday {
            var dateComponents = DateComponents()
            dateComponents.day = birthday.day
            dateComponents.month = birthday.month
            let currentYear = Calendar.current.component(.year, from: Date())
            
            // Determine the correct year
            dateComponents.year = currentYear
            if let birthdateThisYear = Calendar.current.date(from: dateComponents), birthdateThisYear < Date() {
                // If the birthday this year has already passed, set it for the next year
                dateComponents.year = currentYear + 1
            }
            
            if let birthdate = Calendar.current.date(from: dateComponents) {
                eventDate = birthdate
            }
        }
    }

    private func addEvent() {
        let newEvent = Event(context: viewContext)
        newEvent.name = eventName
        newEvent.date = eventDate

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
}

extension Date {
    func getYear() -> Int {
        return Calendar.current.component(.year, from: self)
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
