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
struct EditGifteeView_Previews: PreviewProvider {
    static var previews: some View {
        let previewGiftee = Giftee(firstname: "John", lastname: "Doe")
        return EditGifteeView(giftee: previewGiftee)
    }
}

extension Optional where Wrapped == String {
    var bound: String {
        get { self ?? "" }
        set { self = newValue }
    }
}
