//
//  ImageCacheManager.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 05.11.2023.
//

import UIKit

protocol ImageCacheManagerProtocol {
    func setImage(_ image: UIImage, forKey key: String)
    func image(forKey key: String) -> UIImage?
}

final class ImageCacheManager: ImageCacheManagerProtocol {
    private let cache = NSCache<NSString, UIImage>()

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
