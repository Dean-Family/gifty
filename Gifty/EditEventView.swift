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
                Section(header: Text("Event Description")) {
                    TextEditor(text: $event.event_description.bound)
                        .frame(height: 100)
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

@available(iOS 17, *)
@MainActor
let eventPreviewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Event.self, configurations: .init(isStoredInMemoryOnly: true))
        let sampleEvent = Event(date: Date(), name: "Birthday Party", event_description: "A fun gathering with friends.")
        container.mainContext.insert(sampleEvent)
        return container
    } catch {
        fatalError("Failed to create container for Event")
    }
}()

@available(iOS 17, *)
#Preview {
    do {
        let events = try eventPreviewContainer.mainContext.fetch(FetchDescriptor<Event>())
        let sampleEvent = events.first ?? Event(date: Date(), name: "", event_description: "")
        
        return EditEventView(event: sampleEvent)
            .modelContainer(eventPreviewContainer)
    } catch {
        fatalError("Error fetching events: \(error)")
    }
}

