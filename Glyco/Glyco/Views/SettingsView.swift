//
//  SettingsView .swift
//  GlycoPersonal
//
//

import SwiftUI

struct SettingsButton: View {
    
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

struct SettingsView: View {
    
    var body: some View {
        
        VStack(spacing: 25) {
            
            Divider()
            // Profile Section
            HStack(spacing: 20) {
            
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                
                VStack(alignment: .leading) {
                    Text("Name: ___")
                    Text("Age: ___")
                }
            }
            .padding(.top, 20)
            
            
            // Buttons
            
            NavigationLink(destination: GeneralView()) {
                SettingsButton(label: "General")
            }
            
            NavigationLink(destination: AccountSettingsView()) {
                SettingsButton(label: "Account Settings")
            }
            
            NavigationLink(destination: DataManagementView()) {
                SettingsButton(label: "Data Management")
            }
            
            NavigationLink(destination: LinkDeviceView()) {
                SettingsButton(label: "Link a Device")
            }
            
            Spacer()
            
            
            // Logout
            
            Text("Log out")
                .foregroundColor(.red)
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

