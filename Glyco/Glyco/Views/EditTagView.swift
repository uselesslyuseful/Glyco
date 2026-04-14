
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

    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tag Info")) {
                    TextField("Title", text: $title)
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
        title = tag.wrappedTitle
        detail = tag.wrappedDetail
        start = tag.wrappedStart
        end = tag.wrappedEnd
    }

    private func saveChanges() {
        tag.title = title
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
