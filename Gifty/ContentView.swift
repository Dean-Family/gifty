import SwiftUI
import CoreData

struct GiftsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var isPresentingAddGiftView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    GiftRow(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Gifts")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { isPresentingAddGiftView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddGiftView) {
                AddGiftView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct GiftRow: View {
    var item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name ?? "Unnamed gift")
                .font(.headline)
            Text("Date: \(item.timestamp ?? Date(), formatter: dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

struct GiftsView_Previews: PreviewProvider {
    static var previews: some View {
        GiftsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

