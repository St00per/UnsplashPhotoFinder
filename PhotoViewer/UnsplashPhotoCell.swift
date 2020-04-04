//
//  UnsplashPhotoCell.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class UnsplashPhotoCell: UICollectionViewCell {

    // MARK: - Public constants
    // MARK: - Public variables
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    // MARK: - Private constants
    // MARK: - Private variables
    
    // MARK: - Lifecycle
    // MARK: - IBActions
    
    // MARK: - Public methods
    func configure(with photo: UnsplashPhoto) {
        if let url = URL(string: photo.urls.small) {
            //downloadPhoto(from: url)
            imageView.downloaded(from: url)
        }
    }
    // MARK: - Private methods
    
    private func downloadPhoto(from url: URL) {
        let imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            
            guard let data = data, let response = response, let image = UIImage(data: data), error == nil else { return }
            
            UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                strongSelf.imageView.image = image
            }, completion: nil)
            
            //        let cachedResponse = CachedURLResponse(response: response, data: data)
            //        strongSelf.cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            
            //        DispatchQueue.main.async {
            //            completion(image, false)
            //        }
        }
    }
    
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
