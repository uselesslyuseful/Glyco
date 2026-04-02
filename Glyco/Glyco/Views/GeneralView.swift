//
//  GeneralView.swift
//  GlycoPersonal
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject var ivm: InsightsViewModel
    @EnvironmentObject var gvm: GraphViewModel
    @State private var lowGlucoseAlert = true
    @State private var rapidRiseAlert = true
    @State private var signalLossAlert = true
    
    @State private var silentMinutes: Double = 30

    @State private var selectedTimeFormat = "12-hour"
    let timeFormats = ["12-hour", "24-hour"]
    
    @AppStorage("preferredUnit") private var selectedUnit = "mmol/L"
    let units = ["mmol/L", "mg/dL"]
    
    @AppStorage("highLimit") var highLimit = 10.0
    @AppStorage("lowLimit") var lowLimit = 3.9
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: Notifications
                    Group {
                        Text("Notification Settings")
                            .font(.headline)
                        
                        Toggle("Low/High Glucose Levels", isOn: $lowGlucoseAlert)
                        Toggle("Rapid Rise/Fall", isOn: $rapidRiseAlert)
                        
                        Toggle("Signal Loss", isOn: $signalLossAlert)
                    }
                    
                    
                    // MARK: Silent Mode
                    Group {
                        Text("Silent Mode")
                            .font(.headline)
                        
                        VStack(alignment: .leading) {
                            Text("Silent for \(Int(silentMinutes)) minutes")
                                .font(.caption)
                            
                            Slider(value: $silentMinutes, in: 0...120, step: 5)
                        }
                    }
                    
                    
                    // MARK: Display Settings
                    Group {
                        Text("Display Settings")
                            .font(.headline)
                        
                        HStack {
                            Text("Time Format")
                            Spacer()
                            Picker("Time Format", selection: $selectedTimeFormat) {
                                ForEach(timeFormats, id: \.self) { format in
                                    Text(format)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
//                        HStack {
//                            Text("Preferred Units")
//                            Spacer()
//                            Picker("Preferred Units", selection: $selectedUnit) {
//                                ForEach(units, id: \.self) { unit in
//                                    Text(unit)
//                                }
//                            }
//                            .pickerStyle(.menu)
//                        }
                    }
                    
                    
                    // MARK: Medical Settings
                    Group {
                        Text("Medical Settings")
                            .font(.headline)
                        
                        VStack(alignment: .leading) {
                            Text("High Limit")
                                .font(.caption)
                            
                            TextField("Default", value: $highLimit, format: .number)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Low Limit")
                                .font(.caption)
                            
                            TextField("Default", value: $lowLimit, format: .number)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GeneralView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralView()
    }
}
