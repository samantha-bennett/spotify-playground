//
//  ImageManager.swift
//  SpotifyTestApp
//
//  Created by Samantha Bennett on 12/11/22.
//

import Foundation
import UIKit.UIImage

class ImageManager {
    typealias CacheType = NSCache<NSURL, UIImage>

    public static var shared: ImageManager = {
        ImageManager()
    }()

    private var cache: CacheType

    private init() {
        cache = CacheType()
        cache.countLimit = 100
    }

    public func image(url: URL) async -> UIImage? {
        let url = url as NSURL
        if let image = cache.object(forKey: url) {
            return image
        }

        guard let image = await NetworkManager.shared.loadImage(url: url as URL) else { return nil }
        cache.setObject(image, forKey: url)
        return image
    }
}
