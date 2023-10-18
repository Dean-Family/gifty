//
//  AddItemView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//
import SwiftUI
import CoreData

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var itemName: String = ""

    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Item", displayMode: .inline)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    var formContent: some View {
            VStack {
                TextField("Item name", text: $itemName, onCommit: {
                    addItem()
                })
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                Button("Save") {
                    addItem()
                }
            }
            .padding()
        }
    
    private func addItem() {
        let newItem = Item(context: viewContext)
        newItem.timestamp = Date()
        newItem.name = itemName
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
