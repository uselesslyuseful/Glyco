//
//  TermsView.swift
//  GlycoPersonal
//
//

import SwiftUI

struct TermsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack {
            
            // Top bar
            HStack {
                Spacer()
                
                Button("✕") {
                    dismiss()
                }
            }
            .padding()
            
            
            ScrollView {
                Text("""
                1. This Blood Glucose Tracker App is intended for personal, informational use only and is not a medical device. It does not provide medical advice, diagnosis, or treatment.
                
                2. All data entered is for tracking purposes and should not be used as a substitute for professional healthcare guidance.
                
                3. Users are responsible for how they use the app, and the developer is not liable for any decisions or outcomes resulting from its use.
                """)
                .padding()
            }
            
            Button("Accept") {
                dismiss()
            }
            .padding()
        }
    }
}

struct TermsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsView()
    }
}
