struct TagFilterView: View {
    @Environment(\.dismiss) private var dismiss

    var tags: FetchedResults<Tag>
    @Binding var selectedTags: Set<Tag>

    var body: some View {
        NavigationStack {
            List {
                ForEach(tags) { tag in
                    Button {
                        toggle(tag)
                    } label: {
                        HStack {
                            Text(tag.wrappedTitle)
                            Spacer()
                            if selectedTags.contains(tag) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Section {
                    Button("Clear All") {
                        selectedTags.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filter Tags")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggle(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}