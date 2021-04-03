//
//  UserTopTracks.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/17/21.
//

import Foundation

struct UserTopTracks: Model {
    let items: [Album]
}

struct TopTracks {
    let name: String
    let imageURL: URL
}
