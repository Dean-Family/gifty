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

    @FetchRequest(
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastname, ascending: true)]
    ) private var people: FetchedResults<Person>

    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)]
    ) private var events: FetchedResults<Event>

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gift Name")) {
                    TextField("Gift Name", text: Binding(
                        get: { gift.name ?? "" },
                        set: { gift.name = $0 }
                    ))
                }

                Section(header: Text("Person")) {
                    Picker("Select Person", selection: Binding(
                        get: { gift.person ?? people.first },
                        set: { gift.person = $0 }
                    )) {
                        ForEach(people, id: \.self) { person in
                            Text("\(person.firstname ?? "") \(person.lastname ?? "")")
                                .tag(person as Person?)
                        }
                    }
                }

                Section(header: Text("Event")) {
                    Picker("Select Event", selection: Binding(
                        get: { gift.event ?? events.first },
                        set: { gift.event = $0 }
                    )) {
                        ForEach(events, id: \.self) { event in
                            Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
                                .tag(event as Event?)
                        }
                    }
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
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
