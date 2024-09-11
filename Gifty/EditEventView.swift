//
//  EditEventView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct EditEventView: View {
    @Environment(\.presentationMode) var presentationMode

    @Bindable var event: Event

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Name")) {
                    TextField("Event Name", text: $event.name.boundString)
                }

                Section(header: Text("Event Date")) {
                    DatePicker("Event Date", selection: $event.date.boundDate, displayedComponents: .date)
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

extension Optional where Wrapped == String {
    var boundString: String {
        get { self ?? "" }
        set { self = newValue }
    }
}

extension Optional where Wrapped == Date {
    var boundDate: Date {
        get { self ?? Date() }
        set { self = newValue }
    }
}
