//
//  EditGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import SwiftData
import PhotosUI // Import PhotosUI for PhotosPicker

@available(iOS 17, *)
struct EditGiftView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode

    @Bindable var gift: Gift

    @Query(sort: \Giftee.lastname, order: .forward) private var giftees: [Giftee]
    @Query(sort: \Event.date, order: .forward) private var events: [Event]

    @State private var showingStatusModal = false
    @State private var priceInput: String = ""

    // States for handling images
    @State private var selectedImages: [Data] = []
    @State private var showImagePicker = false
    @State private var showingCameraPicker = false
    @State private var imagePickerResults: [PhotosPickerItem] = []

    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]
    
    var body: some View {
        NavigationView {
            Form {
                giftNameSection()
                gifteePickerSection()
                eventPickerSection()
                locationSection()
                priceSection()
                descriptionSection()
                linkSection()
                statusSection()
                photoSection() // New section for photos
            }
            .onAppear {
                priceInput = formatCentsToDollars(gift.cents ?? 0)
                // Load existing images
                selectedImages = gift.photos
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
                        saveGift()
                    }
                }
            }
            .photosPicker(isPresented: $showImagePicker, selection: $imagePickerResults, maxSelectionCount: 10, matching: .images)
            .onChange(of: imagePickerResults) { _ in
                for item in imagePickerResults {
                    item.loadTransferable(type: Data.self) { result in
                        if let data = try? result.get() {
                            selectedImages.append(data)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCameraPicker) {
                ImagePicker(sourceType: .camera, selectedImages: $selectedImages)
            }
        }
    }
    
    // Add sections
    private func giftNameSection() -> some View {
        Section(header: Text("Gift Name")) {
            TextField("Gift Name", text: $gift.name.bound)
        }
    }

    private func gifteePickerSection() -> some View {
        Section(header: Text("Giftee")) {
            Picker("Select Giftee", selection: $gift.giftee) {
                Text("None").tag(nil as Giftee?)
                ForEach(giftees, id: \.self) { giftee in
                    Text("\(giftee.firstname ?? "") \(giftee.lastname ?? "")")
                        .tag(giftee as Giftee?)
                }
            }
        }
    }

    private func eventPickerSection() -> some View {
        Section(header: Text("Event")) {
            Picker("Select Event", selection: $gift.event) {
                Text("None").tag(nil as Event?)
                ForEach(events, id: \.self) { event in
                    Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
                        .tag(event as Event?)
                }
            }
        }
    }

    private func locationSection() -> some View {
        Section(header: Text("Where to Purchase")) {
            TextField("Location", text: $gift.location.bound)
        }
    }

    private func priceSection() -> some View {
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
    }

    private func descriptionSection() -> some View {
        Section(header: Text("Item Description")) {
            TextEditor(text: $gift.item_description.bound)
                .frame(height: 100)
        }
    }

    private func linkSection() -> some View {
        Section(header: Text("Link")) {
            TextField("Link", text: $gift.link.bound)
                .keyboardType(.URL)
                .autocapitalization(.none)
        }
    }

    private func statusSection() -> some View {
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

    private func photoSection() -> some View {
        Section(header: Text("Photos")) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { imageData in
                        if let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                        }
                    }
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    Button(action: {
                        showingCameraPicker = true
                    }) {
                        Image(systemName: "camera")
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
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
    
    private func saveGift() {
        // Ensure the link has "http" or "https" scheme
        if let inputLink = gift.link?.trimmingCharacters(in: .whitespacesAndNewlines), !inputLink.isEmpty {
            if !inputLink.lowercased().hasPrefix("http://") && !inputLink.lowercased().hasPrefix("https://") {
                gift.link = "https://\(inputLink)"
            }
        }
        
        // Update photos
        gift.photos = selectedImages

        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving gift: \(error.localizedDescription)")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

@available(iOS 17, *)
#Preview {
    do {
        // Fetch the sample gift
        let gifts = try previewGiftAddContainer.mainContext.fetch(FetchDescriptor<Gift>())
        let sampleGift = gifts.first ?? Gift(name: "", cents: 0, item_description: "", link: "", location: "", status: "Idea", event: nil, giftee: nil)
        
        return EditGiftView(gift: sampleGift)
            .modelContainer(previewGiftAddContainer)
    } catch {
        fatalError("Error fetching gifts: \(error)")
    }
}
