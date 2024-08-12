//
//  RegisterViewModel.swift
//  TodoApp
//
//  Created by Berat Yükselen on 17.04.2024.
//

import UIKit

struct RegisterViewModel{
    var emailText: String?
    var passwordText: String?
    var nameText: String?
    var usernameText: String?
    
    var status: Bool{
        return emailText?.isEmpty == false && passwordText?.isEmpty == false && nameText?.isEmpty == false && usernameText?.isEmpty == false
    }
}
