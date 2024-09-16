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

                Section(header: Text("Where to Purchase")) {
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

@available(iOS 17, *)
@MainActor
let previewGiftContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Giftee.self, Event.self, Gift.self, configurations: .init(isStoredInMemoryOnly: true))

        // Create sample giftees
        let sampleGiftee1 = Giftee(firstname: "John", lastname: "Doe")
        let sampleGiftee2 = Giftee(firstname: "Jane", lastname: "Smith")

        // Create sample events
        let sampleEvent1 = Event(date: Date(), name: "Birthday Party", event_description: "A fun gathering.")
        let sampleEvent2 = Event(date: Date(), name: "Wedding", event_description: "A beautiful ceremony.")

        // Insert giftees and events into the context
        container.mainContext.insert(sampleGiftee1)
        container.mainContext.insert(sampleGiftee2)
        container.mainContext.insert(sampleEvent1)
        container.mainContext.insert(sampleEvent2)

        // Create a sample gift
        let sampleGift = Gift(
            name: "Watch",
            cents: 12999,  // $129.99
            item_description: "A fancy wristwatch.",
            link: "https://example.com/watch",
            location: "Macys",
            status: "Ordered",
            event: sampleEvent1,
            giftee: sampleGiftee1
        )

        // Insert the sample gift into the context
        container.mainContext.insert(sampleGift)

        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

@available(iOS 17, *)
#Preview {
    do {
        // Fetch the sample gift
        let gifts = try previewGiftContainer.mainContext.fetch(FetchDescriptor<Gift>())
        let sampleGift = gifts.first ?? Gift(name: "", cents: 0, item_description: "", link: "", location: "", status: "Idea", event: nil, giftee: nil)
        
        return EditGiftView(gift: sampleGift)
            .modelContainer(previewGiftContainer)
    } catch {
        fatalError("Error fetching gifts: \(error)")
    }
}
