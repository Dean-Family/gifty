//
//  AddGiftView.swift
//  Gifty
//
//  Created by Gavin Dean on 10/17/23.
//
import SwiftUI
import CoreData

struct AddGiftView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: Person.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.lastname, ascending: true)]
    ) var persons: FetchedResults<Person>

    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)]
    ) var events: FetchedResults<Event>
    
    @State private var giftName: String = ""
    @State private var selectedPerson: Person?
    @State private var selectedEvent: Event?


    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationBarTitle("Add Gift", displayMode: .inline)
        }
        #else
        formContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    var formContent: some View {
            VStack {
                TextField("Gift name", text: $giftName, onCommit: {
                    addGift()
                })
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                Picker("Select Person", selection: $selectedPerson) {
                    ForEach(persons, id: \.self) { person in
                        Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "")").tag(person as Person?)
                    }
                }

                Picker("Select Event", selection: $selectedEvent) {
                    ForEach(events, id: \.self) { event in
                        Text(event.name ?? "Unknown").tag(event as Event?)
                    }
                }
                Button("Save") {
                    addGift()
                }
            }
            .padding()
        }
    
    private func addGift() {
        let newGift = Gift(context: viewContext)
        newGift.name = giftName
        newGift.person = selectedPerson
        newGift.event = selectedEvent
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // handle the Core Data error
        }
    }
}

struct AddGiftView_Previews: PreviewProvider {
    static var previews: some View {
        AddGiftView()
    }
}
