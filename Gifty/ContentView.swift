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
                        .contextMenu {
                            Button(action: { deleteItems(offsets: IndexSet(integer: items.firstIndex(of: item)!)) }) {
                                                            Label("Delete", systemImage: "trash")
                                                        }
                        }
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
        NavigationLink(destination: GiftDetailView(item: item)) {
            VStack(alignment: .leading) {
                Text(item.name ?? "Unnamed gift")
                    .font(.headline)
                Text("Date: \(item.timestamp ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct GiftDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedDesc = ""

    var item: Item

    var body: some View {
        VStack {
            HStack {
                Text("Name: ")
                    .fontWeight(.bold)
                if isEditing {
                    TextField("Enter gift name", text: $editedName)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(item.name ?? "Unnamed gift")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            HStack {
                Text("Description: ")
                    .fontWeight(.bold)
                if isEditing {
                    TextEditor(text: $editedDesc)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 100)
                } else {
                    Text(item.desc ?? "No description")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            Spacer()
        }
        .padding()
        .navigationTitle("Gift Details")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    if isEditing {
                        item.name = editedName
                        item.desc = editedDesc
                        do {
                            try viewContext.save()
                            isEditing = false
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } else {
                        isEditing = true
                        editedName = item.name ?? ""
                        editedDesc = item.desc ?? ""
                    }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
            
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

