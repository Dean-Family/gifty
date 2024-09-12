//
//  GifteeDetailView.swift
//  Gifty
//
//  Created by Gavin Dean on 8/29/24.
//
import SwiftUI
import SwiftData

@available(iOS 17, *)
struct GifteeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGifteeView: Bool = false
    @State private var showingAddGiftView: Bool = false
    @State private var refreshTrigger: Bool = false  // Trigger for view refresh

    @Bindable var giftee: Giftee

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let gifts = giftee.gifts, !gifts.isEmpty {
                List {
                    Section(header: Text("Gifts").font(.headline)) {
                        ForEach(gifts) { gift in
                            NavigationLink {
                                GiftDetailView(gift: gift)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(gift.name ?? "Unknown")
                                            .font(.headline)

                                        if let event = gift.event {
                                            Text("\(event.name ?? "Unknown Event") on \(event.date!, formatter: dateFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                            .contextMenu {
                                Button(action: {
                                    deleteGift(gift: gift)
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteGifts)
                    }
                }
            } else {
                Text("No gifts associated with this giftee.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle(fullName(for: giftee))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button("Edit") {
                        showingEditGifteeView = true
                    }
                    Button(action: {
                        showingAddGiftView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            refreshTrigger.toggle()  // Refresh view on appearance
        }
        .id(refreshTrigger)  // Force a refresh using .id()
        .sheet(isPresented: $showingEditGifteeView) {
            EditGifteeView(giftee: giftee)
        }
        .sheet(isPresented: $showingAddGiftView) {
            AddGiftView(giftee: giftee)
                .onDisappear {
                    refreshTrigger.toggle()  // Refresh when AddGiftView is dismissed
                }
        }
    }

    private func fullName(for giftee: Giftee) -> String {
        let firstName = giftee.firstname ?? "Unknown"
        let lastName = giftee.lastname ?? "Unknown"
        return "\(firstName) \(lastName)"
    }

    private func deleteGifts(offsets: IndexSet) {
        withAnimation {
            if let gifts = giftee.gifts {
                offsets.map { gifts[$0] }.forEach { modelContext.delete($0) }

                do {
                    try modelContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    private func deleteGift(gift: Gift) {
        withAnimation {
            modelContext.delete(gift)

            do {
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
