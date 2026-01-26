//
//  ContentView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-01-20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Text("Insights")
                            .font(.headline)
                        Spacer()
                    }
                        .border(Color.red)
                        .padding(8)
                    
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        alignment: .center,
                        spacing: 10,
                    ){
                        Infocard(title: "Name of Data", value1: "Val 1", value2: nil, altValue: "Alt Val", systemImage: "")
                        Infocard(title: "Name of Data", value1: "Val 1", value2: nil, altValue: "Alt Val", systemImage: "")
                        Infocard(title: "Name of Data", value1: "Val 1", value2: nil, altValue: "Alt Val", systemImage: "")
                        Infocard(title: "Name of Data", value1: "Val 1", value2: nil, altValue: "Alt Val", systemImage: "")
                    }
                }
            }
            .navigationTitle("Glucose Dashboard")
        }
            
    }
        
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//#endif
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
//
//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

struct Infocard: View {
    let title: String
    let value1: String
    let value2: String?
    let altValue: String?
    let systemImage: String?

    init(title: String = "Name", value1: String = "Value", value2: String? = nil, altValue: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.value1 = value1
        self.value2 = value2
        self.altValue = altValue
        self.systemImage = systemImage
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 12, weight: .regular))

            Text(value1)
                .font(.system(size: 24, weight: .semibold))

            if let value2, !value2.isEmpty {
                Text(value2)
                    .font(.system(size: 32, weight: .semibold))
            }

            if let altValue, !altValue.isEmpty {
                Text(altValue)
                    .font(.system(size: 12, weight: .semibold))
            }

            Spacer()
        }
        .border(Color.red)
        .padding(8)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
