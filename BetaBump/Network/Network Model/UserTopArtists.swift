//
//  UserTopArtists.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 3/24/21.
//

import Foundation
import UIKit

struct UserTopArtists: Model {
    let items: [ArtistItem]
}

struct ArtistItem: Model {
    let id: String
    let name: String
    let images: [ArtistImage]
}

struct ArtistImage: Model {
    let height: Int
    let url: URL
}

struct TopArtists {
    let name: String
    let imageURL: URL
}
