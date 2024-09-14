//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//

import SwiftUI
import SwiftData
import ContactsUI

@available(iOS 17, *)
struct AddGiftView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query(sort: \Giftee.lastname, order: .forward) var giftees: [Giftee]
    @Query(sort: \Event.date, order: .forward) var events: [Event]

    @State private var giftName: String = ""
    @State private var selectedGiftee: Giftee?
    @State private var selectedEvent: Event?
    @State private var location: String = ""
    @State private var priceInDollars: String = ""
    @State private var itemDescription: String = ""
    @State private var link: String = ""
    @State private var status: String = "Idea"
    @State private var showingStatusModal = false

    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]

    init(giftee: Giftee? = nil, event: Event? = nil) {
        _selectedGiftee = State(initialValue: giftee)
        _selectedEvent = State(initialValue: event)
    }
    
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
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    var formContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Gift Name", text: $giftName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
                Picker("Select Giftee", selection: $selectedGiftee) {
                    Text("None").tag(nil as Giftee?)
                    ForEach(giftees, id: \.self) { giftee in
                        Text("\(giftee.firstname ?? "Unknown") \(giftee.lastname ?? "")")
                            .tag(giftee as Giftee?)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Picker("Select Event", selection: $selectedEvent) {
                    Text("None").tag(nil as Event?)
                    ForEach(events, id: \.self) { event in
                        Text(event.name ?? "Unknown")
                            .tag(event as Event?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                TextField("Where to purchase", text: $location)
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
    
    private func addGift() {
        let newGift = Gift()
        newGift.name = giftName
        newGift.giftee = selectedGiftee
        newGift.event = selectedEvent
        newGift.location = location
        newGift.cents = convertDollarsToCents(priceInDollars)
        newGift.item_description = itemDescription
        
        // Ensure the link has "http" or "https" scheme
        var sanitizedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sanitizedLink.lowercased().hasPrefix("http://") && !sanitizedLink.lowercased().hasPrefix("https://") {
            sanitizedLink = "https://\(sanitizedLink)"
        }
        newGift.link = sanitizedLink
        
        newGift.status = status

        modelContext.insert(newGift)
        
        do {
            try modelContext.save()
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
