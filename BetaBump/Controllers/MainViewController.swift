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
    let height: CGFloat = 600
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
    
    func fetchAndConfigureSearch() {
        
        let randomOffset = Int.random(in: 0..<1000)
        
        api.call(request: .search(token: token!, q: getRandomSearch(), type: .track, market: "US", limit: 1, offset: randomOffset) { [self] result in
            
            let tracks = result as? Result<SearchTracks, Error>
            
            switch tracks {
            
            case .success(let something):
                
                let oldModelsCount = self.cardModels.count
                
                for track in something.tracks.items {
                    
                    let newTrack = SimpleTrack(artistName: track.album.artists.first?.name,
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
                        
                        print("PREVIEW URL: ", songModel.previewURL)
                        
                        if songModel.previewURL == nil {
                            AudioPlayer.shared.player?.stop()
                        } else {
                            AudioPlayer.shared.downloadFileFromURL(url: songModel.previewURL!)
                        }
                        
                        
                        
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
        
        let name = "BMP"
        
        //get current user
        _ = Spartan.getMe { (user) in
            
            //create playlist
            _ = Spartan.createPlaylist(userId: user.id as! String, name: name, isPublic: true) { (playlist) in
                
                let playlistId = playlist.id
                
                let defaults = UserDefaults.standard
                defaults.setValue(playlistId, forKey: "playlistId")
                //                defaults.synchronize()
                
                //                print("Playlsit: \(playlist.name), \(playlistId), \(playlist.description)" )
                
            } failure: { (error) in
                print("Error creating playlist: ", error)
            }
            
        } failure: { (error) in
            print("Getting User Info Error: ", error)
        }
    }
    
    func displayPlaylistCreationMessage() {
        let message = "BMP would like to create a playlist on your Spotify account so your liked songs can be autmatically added to it."
        
        let alert = UIAlertController(title: "BMP Playlist", message: message, preferredStyle: .alert)
        
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
    
    //MARK: Helpers
    
    //    func createSoundButton() {
    //        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
    //        if let image = UIImage(named: "soundOn") {
    //            soundButton.setImage(image, for: .normal)
    //            soundButton.imageView?.contentMode = .scaleAspectFit
    //            soundButton.frame = CGRect(x: 325, y: 100, width: 37, height: 37)
    //            soundButton.imageEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
    //        }
    //        view.addSubview(soundButton)
    //        UIWindow.key?.addSubview(soundButton)
    //    }
    
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
        card.content?.widthAnchor
        card.footerHeight = 100
        
        card.swipeDirections = [.left, .up, .right]
        for direction in card.swipeDirections {
            card.setOverlay(CardOverlay(direction: direction), forDirection: direction)
        }
        
        let model = cardModels[index]
        
        card.content = CardContentView(withImageURL: model.imageURL)
        
        card.footer = CardFooterView(withTitle: "\(model.songName)", subtitle: model.artistName)
        return card
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        print("numberOfCards...", cardModels.count)
        return cardModels.count
    }
    
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        fetchAndConfigureSearch()
        
        print("Swiped all cards!")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(cardModels[index].songName)")
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
        print("Swiped \(direction) on \(cardModels[index].songName)")
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: "playlistId")
        
        AudioPlayer.shared.player?.stop()
        
        let trackUri = self.cardModels[index].URI
        
        if direction == .right || direction == .up {
            
            _ = Spartan.getMe(success: { (user) in
                
                _ = Spartan.addTracksToPlaylist(userId: user.id as! String, playlistId: id!, trackUri: trackUri, success: { (snapshot) in
                    
                    print("Song added to playlist")
                    
                }, failure: { (error) in
                    print("Error adding track to playlist: ", error)
                })
                
            }, failure: { (error) in
                print("failed to get user: ", error)
            })
        }
        
        
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
