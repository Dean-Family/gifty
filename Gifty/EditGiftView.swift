//
//  EditGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct EditGiftView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    @Bindable var gift: Gift

    @Query(sort: \Giftee.lastname, order: .forward) private var giftees: [Giftee]
    @Query(sort: \Event.date, order: .forward) private var events: [Event]

    @State private var showingStatusModal = false  // State for showing modal
    @State private var priceInput: String = ""

    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gift Name")) {
                    TextField("Gift Name", text: $gift.name.bound)
                }

                Section(header: Text("Giftee")) {
                    Picker("Select Giftee", selection: $gift.giftee) {
                        Text("None").tag(nil as Giftee?)
                        ForEach(giftees, id: \.self) { giftee in
                            Text("\(giftee.firstname ?? "") \(giftee.lastname ?? "")")
                                .tag(giftee as Giftee?)
                        }
                    }
                }

                Section(header: Text("Event")) {
                    Picker("Select Event", selection: $gift.event) {
                        Text("None").tag(nil as Event?)
                        ForEach(events, id: \.self) { event in
                            Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
                                .tag(event as Event?)
                        }
                    }
                }

                Section(header: Text("Location")) {
                    TextField("Location", text: $gift.location.bound)
                }

                Section(header: Text("Price (in Dollars)")) {
                    TextField("Price", text: $priceInput)
                        .keyboardType(.decimalPad)
                        .onChange(of: priceInput) { newValue in
                            if newValue.isEmpty {
                                gift.cents = nil
                            } else {
                                gift.cents = convertDollarsToCents(newValue)
                            }
                        }
                }
                
                Section(header: Text("Item Description")) {
                    TextEditor(text: $gift.item_description.bound)
                        .frame(height: 100)
                }

                Section(header: Text("Link")) {
                    TextField("Link", text: $gift.link.bound)
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
                            Text(gift.status ?? "Idea")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingStatusModal) {
                        StatusSelectionModal(
                            selectedStatus: $gift.status.bound,
                            isPresented: $showingStatusModal,
                            statuses: statuses
                        )
                    }
                }
            }
            .onAppear {
                priceInput = formatCentsToDollars(gift.cents ?? 0)
            }

            .navigationTitle("Edit Gift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Ensure the link has "http" or "https" scheme
                        if let inputLink = gift.link?.trimmingCharacters(in: .whitespacesAndNewlines), !inputLink.isEmpty {
                            if !inputLink.lowercased().hasPrefix("http://") && !inputLink.lowercased().hasPrefix("https://") {
                                gift.link = "https://\(inputLink)"
                            }
                        }
                        
                        do {
                            try modelContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error saving gift: \(error.localizedDescription)")
                        }
                    }
                }

            }
        }
    }

    // Helper function to format the cents to dollars
    private func formatCentsToDollars(_ cents: Int64) -> String {
        let dollars = Double(cents) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }

    // Helper function to convert dollars to cents
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
