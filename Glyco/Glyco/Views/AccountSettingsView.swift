//
//  AccountSettingsView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct CustomField: View {
    
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            
            TextField("Enter \(title.lowercased())", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .frame(width: 300)
    }
}

struct AccountSettingsView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var showTerms = false
    var body: some View {
        VStack(spacing: 20) {
            
            Divider()
            
            // Profile
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 120, height: 120)
            
            // Fields
            Group {
                CustomField(title: "Name", text: $name)
                CustomField(title: "Age", text: $age)
                CustomField(title: "Email", text: $email)
                CustomField(title: "Phone Number", text: $phone)
            }
            
            Spacer()
            
            // Terms & Conditions
            Button("Terms & Conditions") {
                showTerms = true
            }
            .font(.footnote)
            
            // Delete Account
            Text("Delete Account")
                .underline()
                .foregroundColor(.red)
        }
        .padding()
        .navigationTitle("Account Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
    }
    
    struct AccountSettingsView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationStack {
                AccountSettingsView()
            }
        }
    }
}
