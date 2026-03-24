//
//  DataManagementView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct DataManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showConfirm = false
    @State private var autoBackup = false
    @State private var backupHours: Double = 3
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(alignment: .leading, spacing: 25) {
                
                // Clear History
                Text("Clear History:")
                
                Button("Clear data") {
                    showConfirm = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(25)
                .foregroundColor(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.black, lineWidth: 1)
                )
                // iCloud Section
                Text("Connect iCloud")
                
                Text("Current iCloud status: Connected")
                    .font(.caption)
                
                Button("Connect") {}
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.black, lineWidth: 1)
                    )
                // Backup Section
                Text("Backup data:")
                
                Button("Manual Backup") {}
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.black, lineWidth: 1)
                    )
                // Toggle
                Toggle("Automatic Cloud Backup", isOn: $autoBackup)
                // Slider + Label
                VStack {
                    Text("Backup period: \(backupHours, specifier: "%.1f") hours")
                        .font(.caption)
                    Slider(
                        value: $backupHours,
                        in: 0.5...24,
                        step: 1.5
                    )
                }
                
                Spacer()
            }
            .padding()
            
            // Confirmation Popup
            .alert("Confirm Delete", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    deleteAllGlucoseEntries(with: viewContext)
                }
            } message: {
                Text("Are you sure you want to clear all data?")
            }
        }
        .padding()
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataManagementView_Previews: PreviewProvider {
    static var previews: some View {
        DataManagementView()
    }
}
