
//
//  EditTagView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI
import CoreData

struct EditTagView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    var tag: TagEntry
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)]
    ) private var tags: FetchedResults<Tag>

    @State private var selectedTag: Tag?
    @State private var creatingNewTag = false
    @State private var newTagTitle = ""

    @State private var tagTitle: String = ""
    @State private var detail: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tag")) {
                    Picker("Select Tag", selection: $selectedTag) {
                        ForEach(tags) { t in
                            Text(t.wrappedTitle).tag(Optional(t))
                        }
                        Text("+ New Tag").tag(nil as Tag?)
                    }
                    .onChange(of: selectedTag) { value in
                        creatingNewTag = (value == nil)
                    }

                    if creatingNewTag {
                        TextField("New tag name", text: $newTagTitle)
                    } else {
                        TextField("Rename tag", text: $tagTitle)
                    }
                }

                Section(header: Text("Details")) {
                    TextField("Detail", text: $detail)
                }

                Section(header: Text("Time")) {
                    DatePicker("Start", selection: $start)
                    DatePicker("End", selection: $end)
                }

                Section {
                    Button("Save Changes") {
                        saveChanges()
                        dismiss()
                    }

                    Button("Delete Tag", role: .destructive) {
                        deleteTag()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Tag")
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        selectedTag = tag.tag
        creatingNewTag = false

        tagTitle = tag.tag?.wrappedTitle ?? ""
        detail = tag.wrappedDetail
        start = tag.wrappedStart
        end = tag.wrappedEnd
    }

    private func saveChanges() {
        let tagToUse: Tag

        if creatingNewTag {
            guard !newTagTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            let newTag = Tag(context: context)
            newTag.id = UUID()
            newTag.title = newTagTitle
            newTag.colorHex = "#4CAF50"
            tagToUse = newTag

        } else if let selectedTag {
            tagToUse = selectedTag

            // Rename existing tag (affects all entries using it)
            tagToUse.title = tagTitle

        } else {
            return
        }

        tag.tag = tagToUse
        tag.detail = detail
        tag.startDate = start
        tag.endDate = end

        try? context.save()
    }

    private func deleteTag() {
        context.delete(tag)
        try? context.save()
    }
}
