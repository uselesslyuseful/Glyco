//
//  AccountSettingsView.swift
//  GlycoPersonal
//
//

import SwiftUI
import UIKit

enum ActiveSheet: Identifiable {
    case imagePicker
    case terms
    
    var id: Int { hashValue }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            picker.dismiss(animated: true)
        }
    }
}

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
    @EnvironmentObject var userData: UserData
    
    @State private var activeSheet: ActiveSheet?
    var body: some View {
        VStack(spacing: 20) {
            
            Divider()
            
            // Profile
            Button {
                activeSheet = .imagePicker
            } label: {
                if let image = userData.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    
                    ZStack {
                        Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(Color.gray.opacity(0.6))

                            }
                }
            }
            
            
            // Fields
            Group {
                CustomField(title: "Name", text: $userData.name)
                    .onChange(of: userData.name) { newValue in
                        
                        // Allow only letters + spaces
                        var filtered = newValue.filter { $0.isLetter || $0 == " " }
                        
                        // Ensure only ONE space exists
                        let parts = filtered.split(separator: " ")
                        if parts.count > 2 {
                            filtered = parts.prefix(2).joined(separator: " ")
                        }
                        
                        userData.name = filtered
                    }
                CustomField(title: "Age", text: $userData.age)
                    .onChange(of: userData.age) { newValue in
                        userData.age = newValue.filter { $0.isNumber }
                    }
                VStack(alignment: .leading) {
                    CustomField(title: "Email", text: $userData.email)
                    
                    if !userData.email.isEmpty && !isValidEmail(userData.email) {
                        Text("Invalid email format")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                CustomField(title: "Phone Number", text: $userData.phone)
                    .onChange(of: userData.phone) { newValue in
                        userData.phone = formatPhone(newValue)
                    }
            }
            
            Spacer()
            
            // Terms & Conditions
            Button("Terms & Conditions") {
                activeSheet = .terms
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .imagePicker:
                ImagePicker(image: $userData.profileImage)
            case .terms:
                TermsView()
            }
        }
        }
    func isValidEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".com")
    }
    func formatPhone(_ input: String) -> String {
        let numbers = input.filter { $0.isNumber }
        let limited = String(numbers.prefix(10))
        
        var result = ""
        
        for (index, num) in limited.enumerated() {
            if index == 3 || index == 6 {
                result.append("-")
            }
            result.append(num)
        }
        
        return result
    }
    }
    
    struct AccountSettingsView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationStack {
                AccountSettingsView()
                    .environmentObject(UserData())
            }
        }
    }
