//
//  LikesViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 3/24/21.
//

import UIKit
import Spartan

class LikesViewController: UIViewController {
    
    @IBOutlet weak var likesTableView: UITableView!
    @IBOutlet weak var likesSegmentedOutlet: UISegmentedControl!
    
    var refreshControl = UIRefreshControl()
    
    private let client = APIClient(configuration: URLSessionConfiguration.default)
    private var simplifiedLikedTracks = [SimpleTrack]()
    private var simplifiedSuperLikedTracks = [SimpleTrack]()
    
    private var user: UserModel!
    let token = (UserDefaults.standard.string(forKey: "token"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spartan.authorizationToken = token
        
        likesSegmentedOutlet.selectedSegmentIndex = 1
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshLikes(refreshControl:)), for: .valueChanged)
        likesTableView.addSubview(refreshControl)
        
        likesTableView.backgroundColor = UIColor.clear
        likesTableView.refreshControl = refreshControl
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) 
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        simplifiedLikedTracks.removeAll()
        simplifiedSuperLikedTracks.removeAll()
        
        DispatchQueue.main.async {
            self.fetchAndConfigureLikes()
            self.fetchAndConfigureSuperLikes()
            print("Beep booooooooop")
        }
        refreshControl.endRefreshing()
    }
    
    @objc func refreshLikes(refreshControl: UIRefreshControl) {
        
        likesTableView.reloadData()
        refreshControl.endRefreshing()
    
    }
    
    private func fetchAndConfigureLikes() {
        print("Print One 1")
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: "likesPlaylistId")
        
        client.call(request: .getPlaylist(token: token!, playlistId: id!, completions: { (playlist) in
            
            switch playlist {
            case .failure(let error):
                print(error)
            case .success(let playlist):
                for track in playlist.tracks.items.reversed() {
                    let newTrack = SimpleTrack(artistName: track.track.artists.first?.name,
                                               id: track.track.id,
                                               title: track.track.name,
                                               previewURL: track.track.previewUrl,
                                               images: track.track.album!.images,
                                               albumName: track.track.album!.name)
                    
                    
                    self.simplifiedLikedTracks.append(newTrack)
//                    print("Three 1 ", newTrack)
                }
                
                DispatchQueue.main.async {
                    print("Print Two 1")
//                    self.navigationItem.title = playlist.name
                    self.configureTableView()
                }
            }
        }))
        
        configureNavBar()
    }
    
    private func fetchAndConfigureSuperLikes() {
            
            print("Print One 1")
        
        let defaults = UserDefaults.standard
        let id = defaults.string(forKey: "superLikesPlaylistId")
            
            client.call(request: .getPlaylist(token: token!, playlistId: id!, completions: { (playlist) in
                switch playlist {
                case .failure(let error):
                    print(error)
                case .success(let playlist):
                    
                    for track in playlist.tracks.items.reversed() {
                        let newTrack = SimpleTrack(artistName: track.track.artists.first?.name,
                                                   id: track.track.id,
                                                   title: track.track.name,
                                                   previewURL: track.track.previewUrl,
                                                   images: track.track.album!.images,
                                                   albumName: track.track.album!.name)
                        self.simplifiedSuperLikedTracks.append(newTrack)
//                        print("Three 2: ", newTrack)
                    }
                    
                    DispatchQueue.main.async {
                        print("Print Two 2")
                        self.configureTableView()
                    }
                }
            }))
        
        configureNavBar()
    }
    

    @IBAction func likesSegmentValueChanged(_ sender: Any) {
        likesTableView.reloadData()
        
//        if likesSegmentedOutlet.selectedSegmentIndex == 0 {
//            likesSegmentedOutlet.selectedSegmentIndex = 1
//        } else if likesSegmentedOutlet.selectedSegmentIndex == 1 {
//            likesSegmentedOutlet.selectedSegmentIndex = 0
//        }
    }
    
    
    //MARK: - Helpers
    
    func startingIndex() {
        
        print("srtartingIndex() Liked tracks count: \(simplifiedLikedTracks.count) \n Super Liked Tracks Countr: \(simplifiedSuperLikedTracks.count)")
        
//        if simplifiedLikedTracks.count > simplifiedSuperLikedTracks.count {
//            likesSegmentedOutlet.selectedSegmentIndex = 1
//        } else if simplifiedLikedTracks.count < simplifiedSuperLikedTracks.count {
//            likesSegmentedOutlet.selectedSegmentIndex = 1
//        }
    }
    
    private func configureNavBar() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "MY TOP TRACKS"
    }
    
    private func configureTableView() {
        self.view.addSubview(likesTableView)
        likesTableView.translatesAutoresizingMaskIntoConstraints = false
        likesTableView.register(LikesTableViewCell.self, forCellReuseIdentifier: String(describing: type(of: LikesTableViewCell.self)))
        likesTableView.dataSource = self
        likesTableView.delegate = self
        likesTableView.frame = self.view.bounds
        likesTableView.separatorStyle = .none
    }
    
}

// MARK: - UITableView
extension LikesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Liked tracks count: \(simplifiedLikedTracks.count) \n Super Liked Tracks Countr: \(simplifiedSuperLikedTracks.count)")
        startingIndex()
        
        return likesSegmentedOutlet.selectedSegmentIndex == 0 ? simplifiedLikedTracks.count : simplifiedSuperLikedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: type(of: LikesTableViewCell.self))) as! LikesTableViewCell
        
        let track = likesSegmentedOutlet.selectedSegmentIndex == 0 ? simplifiedLikedTracks[indexPath.row] : simplifiedSuperLikedTracks[indexPath.row]
        
        cell.setTrack(song: track, hideHeartButton: true)
        cell.simplifiedTrack = track
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let defaults = UserDefaults.standard
        let likesId = defaults.string(forKey: "likesPlaylistId")
        let superLikesId = defaults.string(forKey: "superLikesPlaylistId")
        
        if (editingStyle == .delete) {
            
            _ = Spartan.getMe(success: { [self] (user) in
                
                if likesSegmentedOutlet.selectedSegmentIndex == 0 {
                    
                    let removedTrackUri = "spotify:track:\(simplifiedLikedTracks[indexPath.row].id)"
                    
                    _ = Spartan.removeTracksFromPlaylist(userId: user.id as! String, playlistId: likesId!, trackUris: [removedTrackUri], success: { (snapshot) in
                        
                        simplifiedLikedTracks.remove(at: indexPath.row)
                        likesTableView.deleteRows(at: [indexPath], with: .automatic)
                        
                    }, failure: { (error) in
                        print("Error removing track from likes playlist: ", error)
                    })
                    
                    
                    
                } else if likesSegmentedOutlet.selectedSegmentIndex == 1 {
                    
                    let removedTrackUri = "spotify:track:\(simplifiedSuperLikedTracks[indexPath.row].id)"
                    
                    _ = Spartan.removeTracksFromPlaylist(userId: user.id as! String, playlistId: superLikesId!, trackUris: [removedTrackUri], success: { (snapshot) in
                        
                        simplifiedSuperLikedTracks.remove(at: indexPath.row)
                        likesTableView.deleteRows(at: [indexPath], with: .automatic)
                        
                    }, failure: { (error) in
                        print("Error removing track from likes playlist: ", error)
                    })

                }
                
            }, failure: { (error) in
                print("Error getting user in tbale view delete cell: ", error)
            })
        }
    }
    
}

