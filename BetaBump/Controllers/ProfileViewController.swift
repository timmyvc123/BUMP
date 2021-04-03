//
//  MainViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import UIKit
import Kingfisher
import Spartan

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    private let client = APIClient(configuration: URLSessionConfiguration.default)
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var likedSongsLabel: UILabel!
    @IBOutlet weak var superLikedSongsLabel: UILabel!
    @IBOutlet weak var topArtistsCollectionView: UICollectionView!
    @IBOutlet weak var topTracksCollectionView: UICollectionView!
    
    var topArtistsArray: [TopArtists] = []
    var topTracksArray: [TopTracks] = []
    
    let token = (UserDefaults.standard.string(forKey: "token"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTopArtists()
        fetchTopTracks()
        
        topArtistsCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        topTracksCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        
        Spartan.authorizationToken = token
        getUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AudioPlayer.shared.player?.pause()
        getUser()
    }
    
    //MARK: - get User's info
    
    
    func getUser() {
        _ = Spartan.getMe { (user) in
            self.displaynameLabel.text = user.displayName
            self.usernameLabel.text = user.id as? String
            let followers = user.followers!.total!
            self.followersLabel.text = "\(followers)\nFollowers"
            
            let profilePicURL = URL(string: (user.images?.first?.url)!)!
            
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
            let likesId = defaults.string(forKey: "likesPlaylistId")
            let superLikesId = defaults.string(forKey: "superLikesPlaylistId")
            
            _ = Spartan.getPlaylistTracks(userId: user.id as! String, playlistId: likesId!, success: { (pagingObject) in
                
                self.likedSongsLabel.text = "\(pagingObject.items.count)\nLikes"
                
            }, failure: { (error) in
                print("Error getting playlist tracks for liekd playlist: ", error)
            })
            
            _ = Spartan.getPlaylistTracks(userId: user.id as! String, playlistId: superLikesId!, success: { (pagingObject) in
                
                self.superLikedSongsLabel.text = "\(pagingObject.items.count)\nSuper Likes"
                
            }, failure: { (error) in
                print("Error getting playlist tracks for liekd playlist: ", error)
            })
            
        } failure: { (error) in
            print("Error getting user's Info ", error)
        }
    }
    
    //MARK: - User's Top Artists
    
    func fetchTopArtists() {
        
        client.call(request: .getUserTopArtists(token: token!, completions: { [self] (result) in
            switch result {
            case .failure(let error):
                print(error)
                print("got back completion; error")
            case .success(let topArtists):
                
                for artist in topArtists.items {
                    
                    let artistImageURL = artist.images[0].url
                    
                    let newArtist = TopArtists(name: artist.name,
                                          imageURL: artistImageURL)
                    
                    DispatchQueue.main.async {
                        self.topArtistsArray.append(newArtist)
                        self.topArtistsCollectionView.reloadData()
                        
                    }
                }
            }
        }))
    }
    
    //MARK: - User's top tracks
    
    func fetchTopTracks() {
        
        client.call(request: .getUserTopTracks(token: token!, completions: { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let tracks):
                
                for track in tracks.items {
                    
                    let trackImageURL = track.album?.images[0].url
                    
                    let newTrack = TopTracks(name: track.name,
                                        imageURL: trackImageURL!)
                    
                    DispatchQueue.main.async {
                        self.topTracksArray.append(newTrack)
                        self.topTracksCollectionView.reloadData()
                        
                    }
                }
                
            }
        }))
    }
    
    
    
    
    //MARK: CollectionView Delegate Funcs
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == topArtistsCollectionView {
            return topArtistsArray.count
        } else {
            return topTracksArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == topArtistsCollectionView {
            
            let artistCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopArtistsCollectionViewCell", for: indexPath) as! TopArtistsCollectionViewCell
            let url = topArtistsArray[indexPath.row].imageURL
            artistCell.artistImageView.kf.setImage(with: url)
            artistCell.artistLabel.text = topArtistsArray[indexPath.row].name
            
            artistCell.artistLabel.adjustsFontSizeToFitWidth = true
            artistCell.artistLabel.minimumScaleFactor = 0.2

            return artistCell
            
        } else {

            let trackCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopTracksCollectionViewCell", for: indexPath) as! TopTracksCollectionViewCell
            let url = topTracksArray[indexPath.row].imageURL
            trackCell.trackImageView.kf.setImage(with: url)
            trackCell.trackLabel.text = topTracksArray[indexPath.row].name
            
            trackCell.trackLabel.adjustsFontSizeToFitWidth = true
            trackCell.trackLabel.minimumScaleFactor = 0.2

            return trackCell
        }
        
    }
    
    //MARK: - Helpers
    
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
