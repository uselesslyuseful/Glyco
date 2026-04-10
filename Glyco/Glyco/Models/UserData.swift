//
//  UserData.swift
//  GlycoPersonal
//

import SwiftUI
import Combine

class UserData: ObservableObject {
    
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    
    @Published var profileImage: UIImage? = nil
}
