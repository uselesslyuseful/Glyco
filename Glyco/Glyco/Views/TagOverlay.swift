import SwiftUI

struct TagOverlay: View {

    let tag: TagEntry
    let hourHeight: CGFloat
    let width: CGFloat

    @State private var showEdit = false

    var body: some View {

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let startMin = minutes(from: startOfDay, to: tag.wrappedStart)
        let endMin = minutes(from: startOfDay, to: tag.wrappedEnd)

        let top = CGFloat(startMin) / 60 * hourHeight
        let height = max(CGFloat(endMin - startMin) / 60 * hourHeight, 22)

        return tagView
            .frame(width: width - 60, height: height, alignment: .topLeading)
            .position(x: (width - 60) / 2 + 60, y: top + height / 2)
            .onTapGesture(count: 2) {
                showEdit = true
            }
            .sheet(isPresented: $showEdit) {
                EditTagView(tag: tag)
            }
    }

    private var tagView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(tag.wrappedTitle)
                    .font(.caption)
                    .bold()

                if !tag.wrappedDetail.isEmpty {
                    Text(tag.wrappedDetail)
                        .font(.caption2)
                }
            }

            Spacer()
        }
        .padding(6)
        .background(Color(hex: tag.wrappedColorHex).opacity(0.4))
        .cornerRadius(8)
    }

    private func minutes(from start: Date, to end: Date) -> Int {
        Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0
    }
}