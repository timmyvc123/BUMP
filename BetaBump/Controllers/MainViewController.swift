//
//  TestViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/23/21.
//

import UIKit
import Shuffle_iOS
import Spartan
import Kingfisher
import PTCardTabBar

class MainViewController: UIViewController, ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    //MARK: - Vars
    
    //cardLayout in CardLayoutProvider.swift
    //card height line 55 SwipCardStack.swift
    //tab bar positioning in PTCardTabBarController.swift
    //
    @IBOutlet weak var filterSlideUpContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var tableView: UIView!
    let height: CGFloat = 475
    var transparentView = UIView()
    
    private let cardStack = SwipeCardStack()
    var simplifiedTrack: SimpleTrack!
    
    private let buttonStackView = ButtonStackView()
    
    let imageView = UIImageView()
    let testImage = UIImage()
    let soundButton = UIButton(type: .custom)
    
    private let api = APIClient(configuration: .default)
    let player = AudioPlayer.shared.player
    var search: SearchTracks!
    var searchType: SpotifyType!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let token = (UserDefaults.standard.string(forKey: "token"))
    
    var cardModels: [CardModel] = []
    
    var listId: Any?
    
    var counter = 0
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bringSubviewToFront(undoButton)
        Spartan.authorizationToken = token
        
        cardStack.cardStackInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        cardStack.delegate = self
        cardStack.dataSource = self
        buttonStackView.delegate = self
        
        fetchAndConfigureSearch()
//        testTrack()
        
        configureNavigationBar()
        //        layoutButtonStackView()
        layoutCardStackView()
        configureBackgroundGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AudioPlayer.shared.player?.play()
        
        if (!appDelegate.hasAlreadyLaunched) {
            appDelegate.sethasAlreadyLaunched()
            displayPlaylistCreationMessage()
        }
    }
    
    
    //MARK: - Configuration
    
    private func configureNavigationBar() {
        let backButton = UIBarButtonItem(title: "Back",
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleShift))
        backButton.tag = 1
        backButton.tintColor = .lightGray
        navigationItem.leftBarButtonItem = backButton
        
        let forwardButton = UIBarButtonItem(title: "Forward",
                                            style: .plain,
                                            target: self,
                                            action: #selector(handleShift))
        forwardButton.tag = 2
        forwardButton.tintColor = .lightGray
        navigationItem.rightBarButtonItem = forwardButton
        
        navigationController?.navigationBar.layer.zPosition = -1
    }
    
    private func configureBackgroundGradient() {
        let backgroundGray = UIColor(red: 244 / 255, green: 247 / 255, blue: 250 / 255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Button Stack View
    
    //    private func layoutButtonStackView() {
    //        view.addSubview(buttonStackView)
    //        buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
    //                               bottom: view.safeAreaLayoutGuide.bottomAnchor,
    //                               right: view.safeAreaLayoutGuide.rightAnchor,
    //                               paddingLeft: 24,
    //                               paddingBottom: 12,
    //                               paddingRight: 24)
    //    }
    
    //MARK: - Card Stack View
    
    private func layoutCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.safeAreaLayoutGuide.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.safeAreaLayoutGuide.rightAnchor)
        view.bringSubviewToFront(headerView)
        view.sendSubviewToBack(cardStack)
        view.sendSubviewToBack(backgroundImage)
    }
    
    //MARK: - Actions
    
    @objc
    private func handleShift(_ sender: UIButton) {
        cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
    }
    
    @objc func soundButtonTapped() {
        //        if ((soundButton.imageView?.image = UIImage(named: "soundOn")) != nil) {
        //            soundButton.setImage(UIImage(named: "soundOff"), for: .normal)
        //        }
        print("Souund button tapped")
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        print("undo tapped")
        self.counter += 1
        
        cardStack.undoLastSwipe(animated: true)
        AudioPlayer.shared.player?.stop()
        
        let undoIndex = cardModels[cardStack.topCardIndex!]
        
        DispatchQueue.main.async {
            
            if undoIndex.previewURL != nil {
                AudioPlayer.shared.downloadFileFromURL(url: undoIndex.previewURL!)
            } else {
                AudioPlayer.shared.player?.stop()
            }
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        print("filter tapped")
        
        //        view.sendSubviewToBack()
        
        let window = UIWindow.key
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        transparentView.frame = self.view.frame
        window?.addSubview(transparentView)
        window?.addSubview(filterSlideUpContainerView)
        //        window?.bringSubviewToFront(filterSlideUpContainerView)
        
        let screenSize = UIScreen.main.bounds.size
        filterSlideUpContainerView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: height)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.9
            self.filterSlideUpContainerView.frame = CGRect(x: 0, y: screenSize.height - self.height, width: screenSize.width, height: self.height)
        }, completion: nil)
    }
    
    
    @objc func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.filterSlideUpContainerView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: nil)
    }
    
    
    //MARK: API Request
    
    func testTrack() {
        print("Testtrack()........")
        
        //        let comeDown = "0ceIFiPqnnK1v4AF76hUPf"
        //        let andersonPaak = "3jK9MiCrA42lLAdMGUZpwa"
        
        let minAttributes: [(TuneableTrackAttribute, Float)]? = [(.energy, 0.4),(.popularity, 30)]
        let maxAttributes: [(TuneableTrackAttribute, Float)]? = [(.energy, 0.8),(.popularity, 70)]
        
        let targetAttributes: [(TuneableTrackAttribute, Float)]? = [(.energy, 0.6),(.popularity, 50)]
        
        let oldModelsCount = self.cardModels.count
        
        _ = Spartan.search(query: getRandomSearch(), type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
            // Get the tracks via pagingObject.items
            
            for track in pagingObject.items {
                
                _ = Spartan.getTrack(id: track.id as! String, market: .us, success: { (track) in
                    // Do something with the track
                    //                    print("\(track.id) Popularity: ", track.popularity)
                    
                    let seedTracks = [pagingObject.items[0].id]
                    
                    _ = Spartan.getRecommendations(limit: 2, market: .us, minAttributes: [(.energy, 0.4),(.popularity, 30)], maxAttributes: [(.energy, 0.8),(.popularity, 70)], targetAttributes: [(.energy, 0.6),(.popularity, 50)], seedTracks: seedTracks as? [String], success: { (recomendationsObject) in
                        
                        //                        print("recomneded object: ", recomendationsObject.tracks.toJSON())
                        for track in recomendationsObject.tracks {
                            
                            let tempURL = URL(string: "https://i.scdn.co/image/ab67616d0000b2731e439ac0ed08d612808f7122")
                            let trackModel = CardModel(songName: track.name, artistName: track.artists[0].name, imageURL: tempURL, URI: track.uri, previewURL: URL(string: (track.previewUrl)!))
                            
                            self.cardModels.append(trackModel)
                            print("Current card models array count in request: ", self.cardModels.count)
                            
                            print("Current card models array: ", self.cardModels)
                            
                            DispatchQueue.main.async {
                                
                                if trackModel.previewURL == nil {
                                    AudioPlayer.shared.player?.stop()
                                } else {
                                    AudioPlayer.shared.downloadFileFromURL(url: trackModel.previewURL!)
                                }
                            }
                            
                            
                        }
                        
                        
                    }, failure: { (error) in
                        print("Error getting recomendations: ", error)
                    })
                    
                }, failure: { (error) in
                    print("Get Track Error: ", error)
                })
                
            }
            
            let newModelsCount = self.cardModels.count
            let newIndices = Array(oldModelsCount..<newModelsCount)
            
            DispatchQueue.main.async {
                self.cardStack.appendCards(atIndices: newIndices)
                //                print("Card stack count: ", self.cardStack)
            }
        }, failure: { (error) in
            print("Spartan search track error: ",error)
        })
        
        //        _ = Spartan.getRecommendations(limit: 5, market: .us, minAttributes: minAttributes, maxAttributes: maxAttributes, targetAttributes: targetAttributes, seedTracks: [comeDown], success: { (recomendationsObject) in
        //
        //            print("reccomneded object: ", recomendationsObject.tracks.toJSON())
        //
        //        }, failure: { (error) in
        //            print("Error getting recomendations: ", error)
        //        })
        
        //        _ = Spartan.getTrack(id: comeDown, market: .us, success: { (track) in
        //            // Do something with the track
        //            print("\(track.name) Popularity: ", track.popularity)
        //        }, failure: { (error) in
        //            print("Get Track Error: ", error)
        //        })
        
        //        _ = Spartan.getAudioAnaylsis(trackId: comeDown, success: { (audiAnalysis) in
        //            // Do something with the audio analysis
        //            print("Audio Analysis for track: Loudness - ", audiAnalysis.track.loudness)
        //        }, failure: { (error) in
        //            print("AUdio Analysis error: ", error)
        //        })
        //
        //        _ = Spartan.getAudioFeatures(trackId: comeDown, success: { (audioFeaturesObject) in
        //            // Do something with the audio features object
        //            print("Audio Features for track: Dancability - ", audioFeaturesObject.danceability)
        //        }, failure: { (error) in
        //            print("Error for audio features: ", error)
        //        })
        
    }
    
    func fetchAndConfigureSearch() {
        
        let randomOffset = Int.random(in: 0..<1000)
        
        api.call(request: .search(token: token!, q: getRandomSearch(), type: .track, market: "US", limit: 1, offset: randomOffset) { [self] result in
            
            let tracks = result as? Result<SearchTracks, Error>
            
            switch tracks {
            
            case .success(let something):
                
                let oldModelsCount = self.cardModels.count
                
                for track in something.tracks.items {
                    
                    let newTrack = SimpleTrack(artistName: track.album.artists[0].name,
                                               id: track.id,
                                               title: track.name,
                                               previewURL: track.previewUrl,
                                               images: track.album.images!,
                                               albumName: track.album.name)
                    
                    let coverImageURL = newTrack.images[0].url
                    imageView.contentMode = .scaleAspectFill
                    let newURI = "spotify:track:\(newTrack.id)"
                    let songModel = CardModel(songName: newTrack.title, artistName: newTrack.artistName, imageURL: coverImageURL, URI: newURI, previewURL: newTrack.previewUrl)
                    self.cardModels.append(songModel)
                    
                    DispatchQueue.main.async {
                        
                        print("MAge URL: ", songModel.imageURL)
                        
                        if songModel.previewURL == nil {
                            AudioPlayer.shared.player?.stop()
                        } else {
                            AudioPlayer.shared.downloadFileFromURL(url: songModel.previewURL!)
                        }
                        
                        _ = Spartan.getTrack(id: newTrack.id, market: .us, success: { (track) in
                            // Do something with the track
                            print("\(track.name) Popularity: ", track.popularity)
                        }, failure: { (error) in
                            print("Get Track Error: ", error)
                        })
                    }
                }
                
                let newModelsCount = self.cardModels.count
                let newIndices = Array(oldModelsCount..<newModelsCount)
                
                DispatchQueue.main.async {
                    self.cardStack.appendCards(atIndices: newIndices)
                }
                
            case .failure(let error):
                print("search query failed bc... ", error)
            case .none:
                print("not decoding correctly")
            }
        })
    }
    
    func createPlaylist() {
        
        let likesName = "BUMP"
        let superLikesName = "BUMP SUPER LIKES"
        
        //get current user
        _ = Spartan.getMe { (user) in
            
            //create likes playlist
            _ = Spartan.createPlaylist(userId: user.id as! String, name: likesName, isPublic: true) { (playlist) in
                
                let playlistId = playlist.id
                
                let defaults = UserDefaults.standard
                defaults.setValue(playlistId, forKey: "likesPlaylistId")
                
                
            } failure: { (error) in
                print("Error creating likes playlist: ", error)
            }
            
            //create super likes playlist
            _ = Spartan.createPlaylist(userId: user.id as! String, name:superLikesName, isPublic: true) { (playlist) in
                
                let playlistId = playlist.id
                
                let defaults = UserDefaults.standard
                defaults.setValue(playlistId, forKey: "superLikesPlaylistId")
                
                
            } failure: { (error) in
                print("Error creating super likes playlist: ", error)
            }
            
            
            
        } failure: { (error) in
            print("Getting User Info Error: ", error)
        }
    }
    
    //MARK: Helpers
    
    func displayPlaylistCreationMessage() {
        let message = "Bump would like to create 2 playlists on your Spotify account so your liked/super liked songs can be autmatically added to it."
        
        let alert = UIAlertController(title: "Bump Playlists", message: message, preferredStyle: .alert)
        
        let declineAction = UIAlertAction(title: "Decline", style: .destructive) { (action) in
            print("Declined")
        }
        
        let acceptAction = UIAlertAction(title: "Create", style: .default) { (action) in
            self.createPlaylist()
            print("Accepted")
        }
        
        alert.addAction(declineAction)
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    //MARK: - Shuffle Functions
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.footerHeight = 100
        
        card.swipeDirections = [.left, .up, .right]
        for direction in card.swipeDirections {
            card.setOverlay(CardOverlay(direction: direction), forDirection: direction)
        }
        
        let model = cardModels[index]
        
        print("Current card models array count in cardstack: ", self.cardModels.count)
        
        
        card.content = CardContentView(withImageURL: model.imageURL)
        
        card.footer = CardFooterView(withTitle: "\(model.songName)", subtitle: model.artistName)
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        //        testTrack()
        print("numberOfCards...", cardModels.count)
        return cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        fetchAndConfigureSearch()
        //        testTrack()
        
        print("Swiped all cards!")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cardModels[index].songName)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        print("Swiped \(direction) on \(cardModels[index].songName)")
        
        let defaults = UserDefaults.standard
        let likesId = defaults.string(forKey: "likesPlaylistId")
        let superLikesId = defaults.string(forKey: "superLikesPlaylistId")
        
        AudioPlayer.shared.player?.stop()
        
        let trackUri = self.cardModels[index].URI
        
        _ = Spartan.getMe(success: { (user) in
            
            if direction == .right {
                
                _ = Spartan.addTracksToPlaylist(userId: user.id as! String, playlistId: likesId!, trackUri: trackUri, success: { (snapshot) in
                    
                    print("Song added to likes")
                    
                }, failure: { (error) in
                    print("Error adding track to likes playlist: ", error)
                })
            } else if direction == .up {
                
                _ = Spartan.addTracksToPlaylist(userId: user.id as! String, playlistId: superLikesId!, trackUri: trackUri, success: { (snapshot) in
                    
                    print("Song added to super likes")
                    
                }, failure: { (error) in
                    print("Error adding track to super likes playlist: ", error)
                })
            }
            
        }, failure: { (error) in
            print("failed to get user: ", error)
        })
        
        
        
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
        
        var topCard = cardModels[cardStack.topCardIndex!]
        
        DispatchQueue.main.async {
            
            if topCard.previewURL != nil {
                
                if AudioPlayer.shared.player.isPlaying {
                    AudioPlayer.shared.player.pause()
                } else {
                    //                    AudioPlayer.shared.player.play()
                    AudioPlayer.shared.downloadFileFromURL(url: topCard.previewURL!)
                }
                
            } else {
                AudioPlayer.shared.player?.stop()
            }
            
        }
    }
    
    func didTapButton(button: Button) {
        switch button.tag {
        case 1:
            cardStack.undoLastSwipe(animated: true)
        case 2:
            cardStack.swipe(.left, animated: true)
        case 3:
            cardStack.swipe(.up, animated: true)
            
        case 4:
            cardStack.swipe(.right, animated: true)
        case 5:
            cardStack.reloadData()
        default:
            break
        }
    }
}
