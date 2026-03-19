//
//  WheelPickerView.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-03-02.
//

import SwiftUI
import CoreData
// MARK: - Wheel picker

enum Unit: String, CaseIterable, Hashable {
    case minutes
    case hours
    case days
    case weeks
    
    var title: String {rawValue.capitalized}
    var range: ClosedRange<Int>{
        switch self {
        case .minutes: return 0...59
        case .hours: return 0...23
        case .days: return 0...6
        case .weeks: return 0...52
        }
    }
}
struct TimePicker: View {
    var style: AnyShapeStyle = .init(.bar)
    @Binding var minutes: Int
    @Binding var weeks: Int
    @Binding var days: Int
    @Binding var hours: Int
    var units: [Unit] = [.hours, .days, .weeks]

      private func binding(for unit: Unit) -> Binding<Int> {
          switch unit {
          case .minutes: return $minutes
          case .hours: return $hours
          case .days: return $days
          case .weeks: return $weeks
          }
      }
    
    init(style: AnyShapeStyle = .init(.bar), weeks: Binding<Int>, days: Binding<Int>, hours: Binding<Int>) {
        self.style = style
        self.units = [.hours, .days, .weeks]
        self._weeks = weeks
        self._days = days
        self._hours = hours
        self._minutes = .constant(0)
    }

    init(style: AnyShapeStyle = .init(.bar), minutes: Binding<Int>, hours: Binding<Int>, days: Binding<Int>) {
        self.style = style
        self.units = [.minutes, .hours, .days]
        self._minutes = minutes
        self._hours = hours
        self._days = days
        self._weeks = .constant(0)
    }
    
    var body: some View{
        HStack(spacing: 0){
            ForEach(units, id:\.self) { unit in
                CustomView(unit.title, unit.range, binding(for: unit))
            }
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

extension TimePicker {
    static func rangeToString(weeks: Int, days: Int, hours: Int) -> String {
        return format(parts: [
            (value: weeks, singular: "week"),
            (value: days, singular: "day"),
            (value: hours, singular: "hour")
        ])
    }

    static func rangeToString(minutes: Int, hours: Int, days: Int) -> String {
        return format(parts: [
            (value: days, singular: "day"),
            (value: hours, singular: "hour"),
            (value: minutes, singular: "minute")
        ])
    }

    private static func format(parts: [(value: Int, singular: String)]) -> String {
        var out: [String] = []
        for part in parts where part.value > 0 {
            let s = part.value == 1 ? part.singular : part.singular + "s"
            out.append("\(part.value) \(s)")
        }
        return out.joined(separator: ", ")
    }
}

