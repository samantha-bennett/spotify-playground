//
//  Album.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import Foundation

struct Album {

    let id: String
    let name: String
    let images: [SpotifyImage]
    let href: URL
    let artists: [Artist]
}

extension Album: Decodable {}

extension Album: Hashable {}
