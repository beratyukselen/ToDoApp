//
//  ProfileViewModel.swift
//  TodoApp
//
//  Created by Berat Yükselen on 21.04.2024.
//

import Foundation
import UIKit
struct ProfileViewModel{
    var user: User
    init(user: User) {
        self.user = user
    }
    var profileImageUrl: URL?{
        return URL(string: user.profileImageUrl)
    }
    var name: String?{
        return user.name
    }
    var username: String?{
        return user.username
    }
    var email: String?{
        return user.email
    }
}
