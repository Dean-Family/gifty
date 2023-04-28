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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Occasion.timestamp, ascending: true)]) private var occasions: FetchedResults<Occasion>
    
    @State private var selectedOccasion: Occasion?


    @State private var giftName = ""
    @State private var giftDesc = ""

    var body: some View {
        VStack {
            
            HStack {
                Text("Name: ")
                    .fontWeight(.bold)
                    .padding(10)
                TextField("Enter gift name", text: $giftName )
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }

            HStack {
                Text("Description: ")
                    .fontWeight(.bold)
                    .padding(10)
                TextEditor(text: $giftDesc)
                    .frame(width: 300, height: 100)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }

            HStack {
                Text("Occasion: ")
                    .fontWeight(.bold)
                    .padding(10)
                Picker("Occasion", selection: $selectedOccasion) {
                    ForEach(occasions) { occasion in
                        Text(occasion.name ?? "Unnamed occasion").tag(occasion as Occasion?)
                    }
                }
                .pickerStyle(.automatic)
                .padding()
            }

            HStack {
                Button(action: {
                    addGift()
                }) {
                    Text("Add Gift")
                        .fontWeight(.bold)
                        .padding()
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
        newGift.occasion = selectedOccasion

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
