//
//  CreatePlaylist.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 3/8/21.
//

import Foundation

private let client = APIClient(configuration: URLSessionConfiguration.default)

var user: UserModel!

var userID = ""

let token = (UserDefaults.standard.string(forKey: "token"))

private func fetchUserInfo() {
    
    client.call(request: .getUserInfo(token: token!, completion: { (result) in
        
        switch result {
        case .failure(let error):
            print("this is the error", error)
        case .success(let currUser):
            DispatchQueue.main.async {
                
                userID = currUser.id
                print("Current user: ", currUser)
                print("This is the username:", user.displayName)
            }
        }
    }))
}


func createPlaylist() {
    
    var name = "Test"
    var description = "Description Test"
    
//    client.call(request: .createPlaylist(token: token!, id: user.id, name: name, public: true, description: description, completions: { (result) in
//        switch result {
//        case .failure(let error):
//            print("this is the error", error)
//        case .success:
//            print("Create Playlist")
//        }
//        
//    }))
}

