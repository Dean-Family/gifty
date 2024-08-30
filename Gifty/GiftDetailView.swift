//
//  GiftDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//

import SwiftUI
import CoreData

struct GiftDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var gift: Gift

    @FetchRequest private var relatedPerson: FetchedResults<Person>
    @FetchRequest private var relatedEvent: FetchedResults<Event>

    init(gift: Gift) {
        self.gift = gift
        self._relatedPerson = FetchRequest(
            entity: Person.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "SELF == %@", gift.person ?? Person())
        )
        self._relatedEvent = FetchRequest(
            entity: Event.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "SELF == %@", gift.event ?? Event())
        )
    }

    var body: some View {
        VStack {
            Text(gift.name ?? "Unknown")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if let person = relatedPerson.first {
                Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "?")")
                    .font(.title2)
                    .padding()
            }

            if let event = relatedEvent.first {
                Text("Event on \(event.date!, formatter: dateFormatter)")
                    .font(.title2)
                    .padding()
                Text(event.name ?? "Unknown")
            }

            Spacer()
        }
        .navigationTitle(gift.name ?? "Gift")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
