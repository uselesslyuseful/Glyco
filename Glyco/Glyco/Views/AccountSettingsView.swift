//
//  AccountSettingsView.swift
//  GlycoPersonal
//
//

import SwiftUI

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
    
    @State private var showTerms = false
    @State private var showImagePicker = false
    var body: some View {
        VStack(spacing: 20) {
            
            Divider()
            
            // Profile
            Button {
                showImagePicker = true
            } label: {
                if let image = userData.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 120, height: 120)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $userData.profileImage)
            }
            
            // Fields
            Group {
                CustomField(title: "Name", text: $userData.name)
                CustomField(title: "Age", text: $userData.age)
                CustomField(title: "Email", text: $userData.email)
                CustomField(title: "Phone Number", text: $userData.phone)
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
