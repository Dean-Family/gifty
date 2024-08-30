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
        VStack {
            Text(person.firstname ?? "Unknown")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text(person.lastname ?? "Unknown")
                .font(.title2)
                .padding()

            Spacer()
        }
        .navigationTitle("\(person.firstname ?? "Unknown") \(person.lastname ?? "Unknown")")
        .navigationBarTitleDisplayMode(.inline)
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
}
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()