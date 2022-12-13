//
//  APIKeys.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import Foundation

enum APIKeys {
    // TODO: Move keys elsewhere
    static private let SpotifyClientID = ""
    static private let SpotifyAPISecretKey = ""
    static let SpotifyAuthKey = "Basic \((SpotifyClientID + ":" + SpotifyAPISecretKey).data(using: .utf8)!.base64EncodedString())"
}
