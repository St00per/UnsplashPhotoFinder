//
//  UnsplashPhotoCell.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class UnsplashPhotoCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Private constants
    private let cache = ImageCache.cache
    private var imageLoadingTask: URLSessionDataTask?
    // MARK: - Public methods
    func configure(with photo: UnsplashPhoto) {
        if let url = URL(string: photo.urls.small) {
            if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)),
                let image = UIImage(data: cachedResponse.data) {
                imageView.image = image
            } else {
                downloadImage(from: url)
            }
        }
    }
    
    // MARK: - Private methods
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        imageLoadingTask?.cancel()
        imageLoadingTask = URLSession.shared.dataTask(with: url, completionHandler: completion)
        imageLoadingTask?.resume()
    }
    
    private func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, let response = response, error == nil else { return }
            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
}
