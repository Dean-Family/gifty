//
import SwiftUI
import SwiftData
import MapKit

import SwiftUI
import SwiftData

@available(iOS 17, *)
struct GiftDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGiftView: Bool = false
    @Bindable var gift: Gift

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Gift Name
            Text(gift.name ?? "Unnamed Gift")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            // Associated Giftee
            if let giftee = gift.giftee {
                HStack {
                    Text("Gift for:")
                        .font(.headline)
                    Spacer()
                    Text("\(giftee.firstname ?? "Unknown") \(giftee.lastname ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Associated Event
            if let event = gift.event {
                HStack {
                    Text("Event:")
                        .font(.headline)
                    Spacer()
                    Text("\(event.name ?? "Unknown Event") on \(event.date ?? Date(), formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Location Display
            if let location = gift.location, !location.isEmpty {
                HStack {
                    Text("Where to purchase:")
                        .font(.headline)
                    Spacer()
                    if let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let mapURL = URL(string: "http://maps.apple.com/?q=\(encodedLocation)") {
                        Link(location, destination: mapURL)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    } else {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Price Display
            HStack {
                Text("Price:")
                    .font(.headline)
                Spacer()
                Text(formatPrice(cents: gift.cents))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

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

            // Associated Giftee
            if let link = gift.link, let linkURL = URL(string: link) {
                HStack {
                    Text("Link:")
                        .font(.headline)
                    Spacer()
                    Link(link, destination: linkURL)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }


            Spacer()
        }
        .padding()
        .navigationTitle(gift.name ?? "Gift")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit Gift") {
                    showingEditGiftView = true
                }
            }
        }
        .sheet(isPresented: $showingEditGiftView) {
            EditGiftView(gift: gift)
                .environment(\.modelContext, modelContext)
        }
    }

    private func formatPrice(cents: Int64?) -> String {
        let dollars = Double(cents ?? 0) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
