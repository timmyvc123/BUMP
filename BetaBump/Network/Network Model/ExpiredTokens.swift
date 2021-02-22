//
//  ExpiredTokens.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 2/15/21.
//

import Foundation

struct ExpireToken: Model {
    let error: ErrorMessage
   
}

struct ErrorMessage: Model {
    let status: Int?
    let message: String?
}

