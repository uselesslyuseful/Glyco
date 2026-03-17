//
//  WheelPickerView.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-03-02.
//

import SwiftUI
import CoreData
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
            CustomView("weeks", 0...52, $weeks)
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

struct WeeksInputView: View {
    @Binding var weeks: Int
    @State private var text: String = ""
    var body: some View {
        HStack(spacing: 8) {
            Text("weeks")
                .font(.callout)
            TextField("weeks", text: $text)
                .keyboardType(.numberPad)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
                .onChange(of: text) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue { text = filtered }
                    if let value = Int(filtered) {
                        weeks = value
                    }
                }
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

extension TimePicker {
    static func rangeToString(weeks: Int, days: Int, hours: Int) -> String {
        var parts: [String] = []
        if weeks > 0 {
            parts.append("\(weeks) week\(weeks == 1 ? "" : "s")")
        }
        if days > 0 {
            parts.append("\(days) day\(days == 1 ? "" : "s")")
        }
        if hours > 0 {
            parts.append("\(hours) hour\(hours == 1 ? "" : "s")")
        }
        return parts.joined(separator: ", ")
    }
}

