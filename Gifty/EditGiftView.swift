//
//  EditGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct EditGiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var gift: Gift

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gift Name")) {
                    TextField("Gift Name", text: Binding(
                        get: { gift.name ?? "" },
                        set: { gift.name = $0 }
                    ))
                }

                // Additional sections for other attributes (like person, event, etc.)
                // Example:
                Section(header: Text("Person")) {
                    TextField("Person", text: Binding(
                        get: { "\(gift.person?.firstname ?? "") \(gift.person?.lastname ?? "")" },
                        set: { _ in }
                    ))
                }

                Section {
                    Button("Save") {
                        do {
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error saving gift: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .navigationTitle("Edit Gift")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
