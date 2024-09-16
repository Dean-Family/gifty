//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//

import SwiftUI
import SwiftData
import PhotosUI // Import PhotosUI for PhotosPicker

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

    // States for handling images
    @State private var selectedImages: [Data] = []
    @State private var showImagePicker = false
    @State private var showingCameraPicker = false
    @State private var imagePickerResults: [PhotosPickerItem] = []

    let statuses = ["Idea", "Planned", "Reserved", "Ordered", "Shipped", "Received", "Wrapped", "Delivered", "Given", "Opened", "Thanked", "Used", "Exchanged", "Returned", "Re-Gifted", "Expired", "Cancelled", "On Hold", "Pending", "Not Applicable"]

    init(giftee: Giftee? = nil, event: Event? = nil) {
        _selectedGiftee = State(initialValue: giftee)
        _selectedEvent = State(initialValue: event)
    }

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
            TextField("Gift Name", text: $giftName)
        }
    }

    private func gifteePickerSection() -> some View {
        Section(header: Text("Giftee")) {
            Picker("Select Giftee", selection: $selectedGiftee) {
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
            Picker("Select Event", selection: $selectedEvent) {
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
            TextField("Location", text: $location)
        }
    }

    private func priceSection() -> some View {
        Section(header: Text("Price (in Dollars)")) {
            TextField("Price", text: $priceInDollars)
                .keyboardType(.decimalPad)
        }
    }

    private func descriptionSection() -> some View {
        Section(header: Text("Item Description")) {
            TextEditor(text: $itemDescription)
                .frame(height: 100)
        }
    }

    private func linkSection() -> some View {
        Section(header: Text("Link")) {
            TextField("Link", text: $link)
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
        newGift.photos = selectedImages // Add images

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
        .modelContainer(previewGiftAddContainer)
}

// Define `previewGiftAddContainer` here or import it if defined elsewhere
@available(iOS 17, *)
@MainActor
let previewGiftAddContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Giftee.self, Event.self, Gift.self, configurations: .init(isStoredInMemoryOnly: true))

        // Create sample giftees and events
        let sampleGiftee1 = Giftee(firstname: "John", lastname: "Doe")
        let sampleEvent1 = Event(date: Date(), name: "Birthday Party", event_description: "A fun gathering.")

        // Insert into the context
        container.mainContext.insert(sampleGiftee1)
        container.mainContext.insert(sampleEvent1)

        return container
    } catch {
        fatalError("Failed to create container: \(error)")
    }
}()

@available(iOS 17, *)
#Preview {
    AddGiftView()
        .modelContainer(previewGiftAddContainer)
}
