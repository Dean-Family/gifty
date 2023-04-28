import SwiftUI
import CoreData

struct GiftsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedOccasion: Occasion?
    @State private var isPresentingOccasionSelector = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    private var filteredItems: [Item] {
            items.filter { item in
                item.occasion == selectedOccasion
            }
        }
    @State private var isPresentingAddGiftView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    GiftRow(item: item)
                        .contextMenu {
                            Button(action: { deleteItems(offsets: IndexSet(integer: filteredItems.firstIndex(of: item)!)) }) {
                                                            Label("Delete", systemImage: "trash")
                                                        }
                        }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Gifts")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                                    Button(action: { isPresentingOccasionSelector = true }) {
                                        Image(systemName: "calendar")
                                    }
                                }
                ToolbarItem(placement: .automatic) {
                    Button(action: { isPresentingAddGiftView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddGiftView) {
                AddGiftView().environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $isPresentingOccasionSelector) {
                            OccasionSelectorView(selectedOccasion: $selectedOccasion)
                                .environment(\.managedObjectContext, viewContext)
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
    @State private var selectedOccasion: Occasion?

    var item: Item
    
    @FetchRequest(
       sortDescriptors: [NSSortDescriptor(keyPath: \Occasion.timestamp, ascending: true)],
       animation: .default)
    private var occasions: FetchedResults<Occasion>
    var title: String {
            if let occasionName = selectedOccasion?.name {
                return "\(occasionName)"
            } else {
                return "Gift Details"
            }
        }

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
            HStack {
               Text("Occasion: ")
               .fontWeight(.bold)
                if isEditing {
                    Picker("Occasion", selection: $selectedOccasion) {
                        ForEach(occasions) { occasion in
                            Text(occasion.name ?? "Unnamed occasion").tag(occasion as Occasion?)
                        }
                    }
                    .pickerStyle(.automatic)
                } else {
                    Text(item.occasion?.name ?? "No occasion")
                        .foregroundColor(.gray)
                        .onAppear {
                            selectedOccasion = item.occasion
                        }
                }

            }
            .padding()
            Spacer()
        }
        .padding()
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    if isEditing {
                        item.name = editedName
                        item.desc = editedDesc
                        item.occasion = selectedOccasion
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
                        selectedOccasion = item.occasion
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

