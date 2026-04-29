
//
//  AddTagView.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-04-13.
//

import SwiftUI
import CoreData

struct AddTagView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var selectedDate: Date
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        predicate: NSPredicate(format: "isSystem == NO")
    ) private var tags: FetchedResults<Tag>

    @State private var selection: TagSelection?
    @State private var newTagTitle = ""
    
    @State private var detail = ""
    @State private var start: Date
    let preselectedTag: Tag?
    let lockTagSelection: Bool
    init(selectedDate: Date, preselectedTag: Tag? = nil, lockTagSelection: Bool = false) {
        self.selectedDate = selectedDate
        self.preselectedTag = preselectedTag
        self.lockTagSelection = lockTagSelection

        _start = State(initialValue: selectedDate)
        _end = State(initialValue: selectedDate.addingTimeInterval(3600))
    }
    @State private var end = Date().addingTimeInterval(3600)
    
    
    enum TagSelection: Hashable {
        case existing(Tag)
        case new
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tag")) {

                    if lockTagSelection, let tag = preselectedTag {
                        HStack {
                            Text(tag.wrappedTitle)
                            Spacer()
                            Text("Tracker Tag")
                                .foregroundColor(.secondary)
                        }

                    } else {
                        Picker("Select Tag", selection: $selection) {
                            ForEach(tags) { tag in
                                Text(tag.wrappedTitle).tag(TagSelection.existing(tag))
                            }
                            Text("+ New Tag").tag(TagSelection.new)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selection) { value in
                            if case .existing = value {
                                newTagTitle = ""
                            }
                        }

                        if case .new = selection {
                            TextField("New tag name", text: $newTagTitle)
                        }
                    }
                }

                Section(header: Text("Details")) {
                    TextField("Detail (optional)", text: $detail)
                }

                Section(header: Text("Time")) {
                    DatePicker("Start", selection: $start)
                    DatePicker("End", selection: $end)
                }

                Button("Save") {
                    saveTag()
                    dismiss()
                }
            }
            .navigationTitle("New Tag")
            .onAppear {
                if let tag = preselectedTag {
                    selection = .existing(tag)
                } else if selection == nil {
                    if let first = tags.first {
                        selection = .existing(first)
                    } else {
                        selection = .new
                    }
                }
            }
        }
    }

    private func saveTag() {
        let tagToUse: Tag

        switch selection {
        case .new:
            guard !newTagTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            let newTag = Tag(context: viewContext)
            newTag.id = UUID()
            newTag.title = newTagTitle
            newTag.colorHex = "#4CAF50"
            tagToUse = newTag

        case .existing(let tag):
            tagToUse = tag

        case .none:
            return
        }
        

        let newEntry = TagEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.startDate = start
        newEntry.endDate = end
        newEntry.tag = tagToUse
        newEntry.detail = detail

        try? viewContext.save()
    }
}
