//
//  MainScreenViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import UIKit
import Kingfisher

class MainScreenViewController: UIViewController {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var musicButton: UIButton!
    
    private let api = APIClient(configuration: .default)
    var search: SearchTracks!
    var searchType: SpotifyType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func musicButtonTapped(_ sender: Any) {
        fetchAndConfigureSearch()
    }
    
    func fetchAndConfigureSearch() {
        
        let randomOffset = Int.random(in: 0..<1000)
        print("random NUmber is ", randomOffset)
        
        let token = (UserDefaults.standard.string(forKey: "token"))

        api.call(request: .search(token: token!, q: getRandomSearch(), type: .track, limit: 1, offset: randomOffset) { [self] result in
            
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
                        
                        print("The new track is...", newTrack)
                    }

                case .failure(let error):
                    print("search query failed bc... ", error)
                case .none:
                    print("not decoding correctly")
                }
            })
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
