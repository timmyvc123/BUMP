//
//  MainViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let client = APIClient(configuration: URLSessionConfiguration.default)
    
    var user: UserModel!

    @IBOutlet weak var usernameDisplayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        usernameDisplayLabel.isHidden = true
        fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        let token = (UserDefaults.standard.string(forKey: "token"))
        
        client.call(request: .getUserInfo(token: token!, completion: { (result) in
            
            switch result {
            case .failure(let error):
                print("this is the error", error)
            case .success(let currUser):
                DispatchQueue.main.async {
                    
                    print("Current user: ", currUser)
                    self.user = currUser
                    self.usernameDisplayLabel.text = self.user.displayName
                    print("This is the username:", self.user.displayName)

                }
            }
        }))
    }
    

    

}
