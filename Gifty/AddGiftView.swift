//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//

import SwiftUI
import SwiftData

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
    @State private var status: String = ""
    @State private var showingStatusModal = false

    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]
    
    init(giftee: Giftee? = nil, event: Event? = nil) {
            _selectedGiftee = State(initialValue: giftee)
            _selectedEvent = State(initialValue: event)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gift Name")) {
                    TextField("Gift Name", text: $giftName)
                }
                
                Section(header: Text("Giftee")) {
                    Picker("Select Giftee", selection: $selectedGiftee) {
                        Text("None").tag(nil as Giftee?)
                        ForEach(giftees, id: \.self) { giftee in
                            Text("\(giftee.firstname ?? "") \(giftee.lastname ?? "")")
                                .tag(giftee as Giftee?)
                        }
                    }
                }
                
                Section(header: Text("Event")) {
                    Picker("Select Event", selection: $selectedEvent) {
                        Text("None").tag(nil as Event?)
                        ForEach(events, id: \.self) { event in
                            Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
                                .tag(event as Event?)
                        }
                    }
                }

                Section(header: Text("Where to purchase")) {
                    TextField("Location", text: $location)
                }

                Section(header: Text("Price (in Dollars)")) {
                    TextField("Price", text: $priceInDollars)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Item Description")) {
                    TextEditor(text: $itemDescription)
                        .frame(height: 100)
                }

                Section(header: Text("Link")) {
                    TextField("Link", text: $link)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section(header: Text("Status")) {
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
                    .sheet(isPresented: $showingStatusModal) {
                        StatusSelectionModal(
                            selectedStatus: $status,
                            isPresented: $showingStatusModal,
                            statuses: statuses
                        )
                    }
                }
            }
            .navigationTitle("Add Gift")
            .navigationBarTitleDisplayMode(.inline)
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
    }

    private func addGift() {
        let newGift = Gift()
        newGift.name = giftName
        newGift.giftee = selectedGiftee
        newGift.event = selectedEvent
        newGift.location = location
        newGift.cents = convertDollarsToCents(priceInDollars)
        newGift.item_description = itemDescription

        // Ensure the link has "http" or "https" scheme if it's not empty
        var sanitizedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sanitizedLink.isEmpty {
            if !sanitizedLink.lowercased().hasPrefix("http://") && !sanitizedLink.lowercased().hasPrefix("https://") {
                sanitizedLink = "https://\(sanitizedLink)"
            }
        }
        newGift.link = sanitizedLink
        
        newGift.status = status

        modelContext.insert(newGift)
        
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving gift: \(error.localizedDescription)")
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

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

@available(iOS 17, *)
#Preview {
    AddGiftView()
        .modelContainer(previewGiftContainer)
}

