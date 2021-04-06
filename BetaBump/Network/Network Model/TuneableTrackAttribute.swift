//
//  TuneableTrackAttribute.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 4/4/21.
//

import Foundation

public enum TuneableTrackAttribute: String, Model {
    case acousticness = "acousticness"
    case danceability = "danceability"
    case durationMs = "duration_ms"
    case energy = "energy"
    case instrumentalness = "instrumentalness"
    case key = "key"
    case liveness = "liveness"
    case loudness = "loudness"
    case mode = "mode"
    case popularity = "popularity"
    case speechiness = "speechiness"
    case tempo = "tempo"
    case timeSignature = "time_signature"
    case valence = "valence"
}
