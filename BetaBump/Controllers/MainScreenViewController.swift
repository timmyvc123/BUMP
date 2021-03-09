//
//  MainScreenViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import UIKit
import AVFoundation
import Kingfisher

class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    private let client = APIClient(configuration: .default)
    let player = AudioPlayer.shared.player
    var previewURL: URL? = nil
    var search: SearchTracks!
    var searchType: SpotifyType!
    
    let token = (UserDefaults.standard.string(forKey: "token"))
//    var user: UserModel!
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isHidden = true
        fetchUserInfo()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func musicButtonTapped(_ sender: Any) {
        fetchAndConfigureSearch()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        
        if ((player?.isPlaying) != nil) {
            print("playing")
        }
        player?.pause()
    }
    
    func fetchAndConfigureSearch() {
        
        let randomOffset = Int.random(in: 0..<1000)
        print("random NUmber is ", randomOffset)
        
//        let token = (UserDefaults.standard.string(forKey: "token"))

        client.call(request: .search(token: token!, q: getRandomSearch(), type: .track, market: "US", limit: 1, offset: randomOffset) { [self] result in
            
                let tracks = result as? Result<SearchTracks, Error>
                
                switch tracks {
                
                case .success(let something):
                    
//                    let newTrack = something
                    
                    
                    for track in something.tracks.items {
                        let newTrack = SimpleTrack(artistName: track.album.artists.first?.name,
                                                   id: track.id,
                                                   title: track.name,
                                                   previewURL: track.previewUrl,
                                                   images: track.album.images!,
                                                   albumName: track.album.name)
                        
                        self.songNameLabel.text = newTrack.title + " By: " + newTrack.artistName!
                        
                        let coverImageURL = newTrack.images[0].url
                        self.albumCoverImageView.kf.setImage(with: coverImageURL)
                        
                        previewURL = newTrack.previewUrl
                        
                        if previewURL == nil {
                            player?.pause()
                        } else {
                            AudioPlayer.shared.downloadFileFromURL(url: previewURL!)
                        }
                        
//                        if let previewURL = newTrack.previewUrl {
//                            AudioPlayer.shared.downloadFileFromURL(url: previewURL)
//                        }
                        
                        print("The new track is...", newTrack)
                    }

                case .failure(let error):
                    print("search query failed bc... ", error)
                case .none:
                    print("not decoding correctly")
                }
            })
    }
    
    private func fetchUserInfo() {
        
        var user: UserModel!
        
        client.call(request: .getUserInfo(token: token!, completion: { (result) in
            
            switch result {
            case .failure(let error):
                print("this is the error1", error)
            case .success(let currUser):
                DispatchQueue.main.async {
                    self.createPlaylist(user: currUser)
                    self.userID = currUser.id
                    user = currUser
                    print("Current user: ", currUser)
                  print("This is the username:", user.displayName)
                }
            }
            
        }))
    }


    func createPlaylist(user: UserModel) {
        
        let name = "Test"
        let description = "Description Test"
        print("AFTER REQUEST", user)
        
        client.call(request: .createPlaylist(token: token!, id: user.id, name: name, public: true, description: description, completions: { (result) in
            switch result {
            case .failure(let error):
                print("this is the error2", error)
            case .success(let playlist):
                
                
                print("Create Playlist")
            }

        }))
    }
    
    
    //MARK: Helpers
    
    
    
    func getRandomLetter(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func getRandomSearch() -> String {
        let randomChar = getRandomLetter(length: 1)
        var randomSearch = ""
        
        // Places the wildcard character at the beginning, or both beginning and end, randomly.
        randomSearch = randomChar + "%"

        print("random search = ", randomSearch)
        
        return randomSearch
    }
    
}
