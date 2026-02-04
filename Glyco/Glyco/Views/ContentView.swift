//
//  ContentView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-01-20.
//

import SwiftUI
import CoreData
//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    @State private var amount: Int = 1
//    @State private var unit: TimeUnit = .hours
    @State private var insightRangeText = "1 Day"
    @State private var isShowingRangePicker = false
    
    @State private var weeks: Int = 0
    @State private var days: Int = 0
    @State private var hours: Int = 0
//
//    enum TimeUnit: String, CaseIterable {
//        case hours = "Hour"
//        case days = "Day"
//        case weeks = "Week"
//        case months = "Month"
//    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // FIRST ROW (Title and time picker)
                    HStack(spacing: 0){
                        // TITLE
                        Text("Insights")
                            .font(.headline)
                        // BUTTON TO TOGGLE TIME RANGE
                        Button(action: { isShowingRangePicker = true }) {
                            HStack(spacing: 6) {
                                Text(insightRangeText)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .layoutPriority(1)
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.gray)
                            }
                        }
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        Spacer()
                    }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 0)
                    
                    // Main info
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        alignment: .center,
                        spacing: 10,
                    ){
                        Infocard(title: "Current", value1: "6 mmol/L", value2: nil, altValue: "108 mg/dL", systemImages: ["chart.bar.fill", "", "arrow.up.circle.fill"])
                        Infocard(title: "Average", value1: "8 mmol/L", value2: nil, altValue: "144 mg/dL", systemImages: ["chart.bar.fill"])
                        Infocard(title: "Time in Range", value1: "89%", value2: nil, altValue: nil, systemImages: ["chart.bar.fill"])
                        Infocard(title: "Time Out of Range", value1: "5%", value2: "6%", altValue: nil, systemImages: ["chart.bar.fill", "arrow.up.circle.fill", "", "arrow.down.circle.fill"])
                    }
                    .padding(.top, 0)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Glyco Dashboard") // Title of the page
            // TIME RANGE PICKER
            .sheet(isPresented: $isShowingRangePicker) {
                VStack(spacing: 24) {
                    Text("Range Picker Placeholder")
                        .font(.headline)
                    Text("Like wheel picker something like when u make an alarm yk.")
                        .foregroundStyle(.secondary)
                    TimePicker(weeks: $weeks, days: $days, hours: $hours)
                    HStack(spacing: 16) {
                        Button("Cancel") { isShowingRangePicker = false }
                        Button("Done") { isShowingRangePicker = false }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .presentationDetents([.fraction(0.45), .medium])
            }
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


// MARK: - Infocard
struct Infocard: View {
    let title: String
    let value1: String
    let value2: String?
    let altValue: String?
    let systemImages: [String]?
    
    init(title: String = "Name", value1: String = "Value", value2: String? = nil, altValue: String? = nil, systemImages: [String]? = nil) {
        self.title = title
        self.value1 = value1
        self.value2 = value2
        self.altValue = altValue
        self.systemImages = systemImages
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                if let systemImages, let first = systemImages.first, !first.isEmpty {
                    Image(systemName: first).foregroundColor(.accentColor)
                }
                Text(title)
                    .font(.system(size: 12, weight: .regular))

            }
            
            HStack{
                if let systemImages, systemImages.indices.contains(1), !systemImages[1].isEmpty {
                    Image(systemName: systemImages[1]).foregroundColor(.accentColor)

                }

                Text(value1)
                    .font(.system(size: 24, weight: .semibold))
                
                if let systemImages, systemImages.indices.contains(2), !systemImages[2].isEmpty {
                    Image(systemName: systemImages[2]).foregroundColor(.accentColor)

                }

            }
            
            HStack{
                if let systemImages, systemImages.indices.contains(3), !systemImages[3].isEmpty {
                    Image(systemName: systemImages[3]).foregroundColor(.accentColor)

                }
                if let value2, !value2.isEmpty {
                    Text(value2)
                        .font(.system(size: 24, weight: .semibold))
                }
                if let systemImages, systemImages.indices.contains(4), !systemImages[4].isEmpty {
                    Image(systemName: systemImages[4]).foregroundColor(.accentColor)

                }
            }
            

            if let altValue, !altValue.isEmpty {
                Text(altValue)
                    .font(.system(size: 12, weight: .semibold))
            }

            Spacer()
        }
        .padding(8)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Wheel picker

struct TimePicker: View {
    var style: AnyShapeStyle = .init(.bar)
    @Binding var weeks: Int
    @Binding var days: Int
    @Binding var hours: Int
    var body: some View{
        HStack(spacing: 0){
            CustomView("hours", 0...23, $hours)
            CustomView("days", 0...6, $days)
            CustomView("weeks", 0...4, $weeks)
        }
        .offset(x: -25)
        .background{
            RoundedRectangle(cornerRadius: 20)
                .fill(style)
                .frame(height:35)
        }
        
    }
    
    @ViewBuilder
    private func CustomView(_ title: String, _ range: ClosedRange<Int>, _ selection: Binding<Int>) -> some View {
        PickerViewWithoutIndicator(selection:selection){
            ForEach(range, id: \.self){ value in
                Text("\(value)")
                    .frame(width: 35, alignment: .trailing)
                    .tag(value)
            }
        }
        .overlay{
            Text(title)
                .font(.callout)
                .frame(width: 50, alignment: .leading)
                .lineLimit(1)
                .offset(x: 50)
        }
    }
}
struct PickerViewWithoutIndicator<Content: View, Selection: Hashable>: View{
    @Binding var selection: Selection
    @ViewBuilder var content: Content
    @State private var isHidden: Bool = false
    var body: some View{
        Picker("", selection: $selection){
            if !isHidden {
                RemovePickerIndicator {
                    isHidden = true
                }
            } else{
                content
            }
            
        }
        .pickerStyle(.wheel)
    }
}

// Remove background
fileprivate
struct RemovePickerIndicator: UIViewRepresentable {
    var result: () -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let pickerView = view.pickerView{
                if pickerView.subviews.count >= 2 {
                    pickerView.subviews[1].backgroundColor = .clear
                }
                result()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

fileprivate
extension UIView{
    var pickerView: UIPickerView? {
        if let view = superview as? UIPickerView {
            return view
        }
        return superview?.pickerView
    }
}
