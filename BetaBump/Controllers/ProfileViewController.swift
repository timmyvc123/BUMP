//
//  MainViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import UIKit
import Kingfisher
import Spartan

class ProfileViewController: UIViewController {
    
    private let client = APIClient(configuration: URLSessionConfiguration.default)
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var likedSongsLabel: UILabel!
    @IBOutlet weak var superLikedSongsLabel: UILabel!
    
    let token = (UserDefaults.standard.string(forKey: "token"))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spartan.authorizationToken = token
        likedSongsLabel.isHidden = true
        superLikedSongsLabel.isHidden = true
//        fetchUserInfo()
        getUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AudioPlayer.shared.player?.pause()

    }
    
    func getUser() {
        _ = Spartan.getMe { (user) in
            self.displaynameLabel.text = user.displayName
            self.usernameLabel.text = user.id as? String
            let followers = user.followers!.total!
            self.followersLabel.text = "\(followers) \n Followers"
            
            let profilePicURL = URL(string: (user.images?.first?.url)!)
            
            self.profileImageView.kf.setImage(with: profilePicURL) { (result) in
                switch result {
                case .failure(let error):
                    print("Image Error: ", error)
                case .success(let value):
                    DispatchQueue.main.async {
                        self.profileImageView.image = value.image.circleMasked
                        
                    }
                }
            }
            
            let defaults = UserDefaults.standard
            let id = defaults.string(forKey: "playlistId")
            
//
//            _ = Spartan.getUsersPlaylist(userId: user.id, playlistId: id,  success: { (playlist) in
//
//
//
//            }, failure: { (error) in
//                print("Error getting Playlist in profile view: ", error)
//            })

            
        } failure: { (error) in
            print("Error getting user's Info ", error)
        }
    }
    

    
    private func fetchUserInfo() {
        var user: UserModel!
        
        client.call(request: .getUserInfo(token: token!, completion: { (result) in
            
            switch result {
            case .failure(let error):
                print("this is the error", error)
            case .success(let currUser):
                DispatchQueue.main.async {
                    
                    print("Current user: ", currUser)
                    user = currUser
                    self.displaynameLabel.text = user.displayName
                    print("This is the username:", user.displayName)

                }
            }
        }))
    }

}

extension UIImage {
    
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }
    
    var circleMasked: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
