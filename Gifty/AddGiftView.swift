//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 4/26/23.
//

import SwiftUI
struct AddGiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var giftName = ""
    @State private var giftDesc = ""

    var body: some View {
        VStack {
            
            HStack {
                Text("Name: ")
                    .fontWeight(.bold)
                TextField("Enter gift name", text: $giftName )
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
            }

            HStack {
                Text("Description: ")
                    .fontWeight(.bold)
                TextEditor(text: $giftDesc)
                    .frame(width: 300, height: 100)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
            }
            HStack {
                Button(action: {
                    addGift()
                }) {
                    Text("Add Gift")
                        .fontWeight(.bold)
                        .padding(10)
                }
            }
            Spacer()
        }
        .navigationTitle("Add Gift")
    }

    private func addGift() {
        guard !giftName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        let newGift = Item(context: viewContext)
        newGift.timestamp = Date()
        newGift.name = giftName
        newGift.desc = giftDesc

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
