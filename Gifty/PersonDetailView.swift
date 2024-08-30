//
//  PersonDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//
import SwiftUI
import CoreData

struct PersonDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditPersonView: Bool = false

    @ObservedObject var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Spacer()
        }
        .padding()
        .navigationTitle(fullName(for: person))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditPersonView = true
                }
            }
        }
        .sheet(isPresented: $showingEditPersonView) {
            EditPersonView(person: person)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func fullName(for person: Person) -> String {
        let firstName = person.firstname ?? "Unknown"
        let lastName = person.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
