//
//  Tokens.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

struct Tokens: Model {
    let accessToken: String
    let expiresIn: Int
    let scope: String?
    let refreshToken: String?
}
