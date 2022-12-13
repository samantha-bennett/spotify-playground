//
//  SpotifyImage.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/12/22.
//

import Foundation
import UIKit

struct SpotifyImage {
    let height: Int
    let width: Int
    let url: URL
}
extension SpotifyImage: Decodable {}
extension SpotifyImage: Hashable {}

extension SpotifyImage {
    var image: UIImage? {
        get async {
            let image = await ImageManager.shared.image(url: url)
            return image
        }
    }
}
