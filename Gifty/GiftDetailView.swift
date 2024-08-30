//
import SwiftUI
import CoreData

struct GiftDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var gift: Gift

    @State private var showingEditGiftView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Gift Name
                Text(gift.name ?? "Unnamed Gift")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                // Status
                HStack {
                    Text("Status:")
                        .font(.headline)
                    Spacer()
                    Text(gift.status ?? "Unknown Status")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)

                // Associated Person
                if let person = gift.person {
                    HStack {
                        Text("Gift for:")
                            .font(.headline)
                        Spacer()
                        Text("\(person.firstname ?? "Unknown") \(person.lastname ?? "?")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                }

                // Associated Event
                if let event = gift.event {
                    HStack {
                        Text("Event:")
                            .font(.headline)
                        Spacer()
                        Text(event.name ?? "Unknown Event")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 2)
                    
                    HStack {
                        Text("Date:")
                            .font(.headline)
                        Spacer()
                        Text(event.date!, formatter: dateFormatter)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                }

                // Location
                if let location = gift.location, !location.isEmpty {
                    HStack {
                        Text("Location:")
                            .font(.headline)
                        Spacer()
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                }

                // Cents (Price)
                HStack {
                    Text("Price:")
                        .font(.headline)
                    Spacer()
                    Text(formatPrice(cents: gift.cents))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)

                // Item Description
                if let itemDescription = gift.item_description, !itemDescription.isEmpty {
                    Text("Description")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(itemDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                }

                // Link
                if let link = gift.link, !link.isEmpty {
                    Link("More Info", destination: URL(string: link)!)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(gift.name ?? "Gift")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit Gift") {
                    showingEditGiftView = true
                }
            }
        }
        .sheet(isPresented: $showingEditGiftView) {
            EditGiftView(gift: gift).environment(\.managedObjectContext, viewContext)
        }
    }

    private func formatPrice(cents: Int64) -> String {
        let dollars = Double(cents) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
