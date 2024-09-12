//
//  GifteeView.swift
//  Gifty
//
//  Created by Gavin Dean on 11/30/23.
//

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct GifteeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var giftees: [Giftee]

    @State private var showingAddGifteeView: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("People").font(.headline)) {
                    ForEach(giftees) { giftee in
                        NavigationLink(destination: GifteeDetailView(giftee: giftee)) {
                            VStack(alignment: .leading) {
                                Text(fullName(for: giftee))
                                    .font(.headline)
                                    .padding(.vertical, 2)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                deleteGiftee(giftee: giftee)
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteGiftees)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddGifteeView = true
                    }) {
                        Label("Add Giftee", systemImage: "plus")
                    }
                }
            }
            Text("Select a giftee")
        }
        .sheet(isPresented: $showingAddGifteeView) {
            AddGifteeView()
        }
    }

    private func fullName(for giftee: Giftee) -> String {
        let firstName = giftee.firstname ?? "Unknown"
        let lastName = giftee.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }

    private func deleteGiftees(offsets: IndexSet) {
        withAnimation {
            offsets.map { giftees[$0] }.forEach { modelContext.delete($0) }

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteGiftee(giftee: Giftee) {
        withAnimation {
            modelContext.delete(giftee)

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

@available(iOS 17, *)
struct GifteeView_Previews: PreviewProvider {
    static var previews: some View {
        GifteeView()
    }
}
