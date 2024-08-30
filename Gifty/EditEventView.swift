//
//  EditEventView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct EditEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var event: Event

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Name")) {
                    TextField("Event Name", text: Binding(
                        get: { event.name ?? "" },
                        set: { event.name = $0 }
                    ))
                }

                Section(header: Text("Event Date")) {
                    DatePicker("Event Date", selection: Binding(
                        get: { event.date ?? Date() },
                        set: { event.date = $0 }
                    ), displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Event")
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
                            print("Error saving event: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
