//
//  OccasionSelectorView.swift
//  Gifty
//
//  Created by Gavin Dean on 4/27/23.
//

import SwiftUI

struct OccasionSelectorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var selectedOccasion: Occasion?
    
    @FetchRequest(entity: Occasion.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Occasion.name, ascending: true)],
                  predicate: nil,
                  animation: .default)
    private var occasions: FetchedResults<Occasion>
    
    @State private var isPresentingAddOccasionView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(occasions) { occasion in
                    Text(occasion.name ?? "Unnamed Occasion")
                                .foregroundColor(occasion == selectedOccasion ? .blue : .primary)
                                .onTapGesture {
                                    selectedOccasion = occasion
                                    presentationMode.wrappedValue.dismiss()
                                }
                }
                Button(action: {
                                isPresentingAddOccasionView = true
                            }) {
                                Image(systemName: "plus")
                            }
                            .sheet(isPresented: $isPresentingAddOccasionView) {
                                AddOccasionView()
                            }
            }
            .navigationTitle("Select Occasion")
        }
    }
}

struct AddOccasionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Occasion Details")) {
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Add Occasion")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        saveOccasion()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveOccasion() {
        let newOccasion = Occasion(context: viewContext)
        newOccasion.name = name
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
