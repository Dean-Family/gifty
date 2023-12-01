//
//  AddEventView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName: String = ""
    @State private var eventDate = Date()

    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Event", displayMode: .inline)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    var formContent: some View {
            VStack {
                TextField("Event name", text: $eventName, onCommit: {
                    addEvent()
                })
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                DatePicker("Event date", selection: $eventDate, displayedComponents: [.date])
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                Button("Save") {
                    addEvent()
                }
            }
            .padding()
        }
    
    private func addEvent() {
        let newEvent = Event(context: viewContext)
        newEvent.date = Date()
        newEvent.name = eventName
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
}

#Preview {
    AddEventView()
}
