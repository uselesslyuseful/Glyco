//
//  DataManagementView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct DataManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var ivm: InsightsViewModel

    
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
                Spacer()
            }
            .padding()
            
            // Confirmation Popup
            .alert("Confirm Delete", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm", role: .destructive) {
                    Task{
                        await deleteAllGlucoseEntries(with: viewContext)
                        await MainActor.run{
                            ivm.loadStats(context: viewContext)
                        }
                    }
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
