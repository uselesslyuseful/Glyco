
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

    @State private var title = ""
    @State private var detail = ""
    @State private var start = Date()
    @State private var end = Date().addingTimeInterval(3600)

    var body: some View {
        NavigationStack {
            Form {
                TextField("Tag name", text: $title)
                TextField("Detail (optional)", text: $detail)

                DatePicker("Start", selection: $start)
                DatePicker("End", selection: $end)

                Button("Save") {
                    saveTag()
                    dismiss()
                }
            }
            .navigationTitle("New Tag")
        }
    }

    private func saveTag() {
        let newTag = TagEntry(context: viewContext)
        newTag.id = UUID()
        newTag.title = title
        newTag.detail = detail
        newTag.startDate = start
        newTag.endDate = end
        newTag.colorHex = "#4CAF50"

        try? viewContext.save()
    }
}
