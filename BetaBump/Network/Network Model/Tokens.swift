//
//  Tokens.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

//struct Tokens: Model {
//    let accessToken: String
//    let tokenExpiration: Int
//    let refreshToken: String?
//
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case tokenExpiration = "expires_in"
//        case refreshToken = "refresh_token"
//    }
//}


struct Tokens: Model {
    let accessToken: String
    let expiresIn: Int
    let scope: String?
    let refreshToken: String?
}
