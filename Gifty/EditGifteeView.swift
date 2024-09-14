//
//  EditGifteeView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct EditGifteeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @Bindable var giftee: Giftee  // Use @Bindable instead of @ObservedObject

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("First Name")) {
                    TextField("First Name", text: $giftee.firstname.bound)
                }

                Section(header: Text("Last Name")) {
                    TextField("Last Name", text: $giftee.lastname.bound)
                }
            }
            .navigationTitle("Edit Giftee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error saving giftee: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 17, *)
@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Giftee.self, configurations: .init(isStoredInMemoryOnly: true))
        let sampleGiftee = Giftee(firstname: "Sample", lastname: "User")
        container.mainContext.insert(sampleGiftee)
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

@available(iOS 17, *)
#Preview {
    do {
        let giftees = try previewContainer.mainContext.fetch(FetchDescriptor<Giftee>())
        let sampleGiftee = giftees.first ?? Giftee(firstname: "", lastname: "")
        
        return EditGifteeView(giftee: sampleGiftee)
            .modelContainer(previewContainer)
    } catch {
        fatalError("Error fetching giftees: \(error)")
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        get { self ?? "" }
        set { self = newValue }
    }
}
