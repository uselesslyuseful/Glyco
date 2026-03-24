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
                LOTS OF TERMS AND CONDITIONS TEXT HERE
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
