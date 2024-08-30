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
    @State private var location: String = ""
    @State private var priceInDollars: String = ""
    @State private var itemDescription: String = ""
    @State private var link: String = ""
    @State private var status: String = "Idea"  // Default status
    @State private var showingStatusModal = false  // State for showing modal
    
    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Gift", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addGift()
                        }
                    }
                }
                .onAppear(perform: setDefaultSelections)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear(perform: setDefaultSelections)
        #endif
    }
    
    var formContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Gift Name", text: $giftName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
                Picker("Select Person", selection: $selectedPerson) {
                    ForEach(persons, id: \.self) { person in
                        Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "")")
                            .tag(person as Person?)
                    }
                }
                
                Picker("Select Event", selection: $selectedEvent) {
                    ForEach(events, id: \.self) { event in
                        Text(event.name ?? "Unknown")
                            .tag(event as Event?)
                    }
                }
                
                TextField("Location", text: $location)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
                TextField("Price (in Dollars)", text: $priceInDollars)
                    .keyboardType(.decimalPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
                TextEditor(text: $itemDescription)
                    .frame(height: 100)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .autocapitalization(.sentences)
                
                TextField("Link", text: $link)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

                Button(action: {
                    showingStatusModal = true
                }) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(status)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .sheet(isPresented: $showingStatusModal) {
                    StatusSelectionModal(selectedStatus: $status, isPresented: $showingStatusModal, statuses: statuses)
                }
            }
            .padding()
        }
    }

    private func setDefaultSelections() {
        if let firstPerson = persons.first {
            selectedPerson = firstPerson
        }
        if let firstEvent = events.first {
            selectedEvent = firstEvent
        }
    }
    
    private func addGift() {
        let newGift = Gift(context: viewContext)
        newGift.name = giftName
        newGift.person = selectedPerson
        newGift.event = selectedEvent
        newGift.location = location
        newGift.cents = convertDollarsToCents(priceInDollars)
        newGift.item_description = itemDescription
        newGift.link = link
        newGift.status = status  // Save the selected status
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }

    private func convertDollarsToCents(_ dollars: String) -> Int64 {
        let cleanedDollars = dollars.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
        if let dollarValue = Double(cleanedDollars) {
            return Int64(dollarValue * 100)
        }
        return 0
    }
}

struct StatusSelectionModal: View {
    @Binding var selectedStatus: String
    @Binding var isPresented: Bool  // Binding to control the sheet's visibility
    let statuses: [String]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(statuses, id: \.self) { status in
                    Button(action: {
                        selectedStatus = status
                        isPresented = false  // Dismiss the sheet when a status is selected
                    }) {
                        HStack {
                            Text(status)
                            Spacer()
                            if selectedStatus == status {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Status")
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false  // Dismiss the sheet when "Done" is tapped
            })
        }
    }
}

struct AddGiftView_Previews: PreviewProvider {
    static var previews: some View {
        AddGiftView()
    }
}
