struct TrackerView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        predicate: NSPredicate(format: "isSystem == YES")
    ) private var trackers: FetchedResults<Tag>

    var body: some View {
        NavigationStack {
            List {
                ForEach(trackers) { tag in
                    NavigationLink {
                        TrackerDetailView(tag: tag)
                    } label: {
                        HStack {
                            Circle()
                                .fill(Color(hex: tag.wrappedColorHex))
                                .frame(width: 10, height: 10)

                            Text(tag.wrappedTitle)
                        }
                    }
                }
            }
            .navigationTitle("Trackers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}