//
//  LinkDeviceView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct LinkDeviceButton: View {
    
    let label: String
    
    var body: some View {
        
        Text(label)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.black)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal, 40)
    }
}

struct LinkDeviceView: View {
    @EnvironmentObject var dexcom: DexcomClient
    @EnvironmentObject var vm: InsightsViewModel
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Divider()
        VStack {
            VStack(alignment: .leading) {
                Text("Blood Glucose Monitor")
                    .padding(10)
                    .bold()
                Text("          Current Device")
                
                //CHANGE DESTINATION TO POP-UP TO LINK DEVICES
                
                Button {
                    Task {
                        if dexcom.isAuthenticated {
                            await dexcom.fetchEGVs()
                            await dexcom.importEGVsIntoCoreData(context: viewContext)
                            await MainActor.run {
                                vm.loadStats(context: viewContext)
                            }
                        } else {
                            dexcom.login()
                        }
                    }
                } label: {
                    LinkDeviceButton(label: dexcom.isAuthenticated ? "Sync Dexcom Data" : "Connect Dexcom")
                }
                .padding(10)
                Spacer().frame(height: 60)
            }
            .padding(20)
            Spacer()
        }
        .padding()
        .navigationTitle("Link Device")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LinkDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LinkDeviceView()
        }
    }
}
