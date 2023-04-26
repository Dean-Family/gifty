//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 4/26/23.
//

import SwiftUI

struct AddGiftView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var giftName: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Gift Name", text: $giftName)
            }
            .navigationTitle("Add Gift")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addItem()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = giftName

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
