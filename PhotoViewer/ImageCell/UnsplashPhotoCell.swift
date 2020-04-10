//
//  UnsplashPhotoCell.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

protocol UnsplashPhotoCellDelegate: AnyObject {
    func cellHasDoubleTapped(at index: Int)
}

class UnsplashPhotoCell: UICollectionViewCell {
    
    //MARK: - Public variables
    var delegate: UnsplashPhotoCellDelegate?
    var index: Int?
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK: - Public constants
    static let reuseIdentifier = "UnsplashPhotoCell"
    
    // MARK: - Private constants
    private let cache = ImageCache.cache
    
    //MARK: - Private variables
    private var imageUrlString: String?
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let spinner = self.spinner {
            spinner.startAnimating()
        }
    }
    
    // MARK: - Public methods
    func configure(with photo: UnsplashPhoto, quality: PhotoQualityEnum) {
        
        switch quality {
        case .raw:
            imageUrlString = photo.urls.raw
        case .full:
            imageUrlString = photo.urls.full
        case .regular:
            imageUrlString = photo.urls.regular
        case .small:
            imageUrlString = photo.urls.small
        case .thumb:
            imageUrlString = photo.urls.thumb
        }
        
        imageView.image = nil
        if let imageString = self.imageUrlString, let url = URL(string: imageString) {
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

        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, let response = response, error == nil else { return }

            let cachedResponse = CachedURLResponse(response: response, data: data)
            self.cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            
            DispatchQueue.main.async() {
                if self.imageUrlString == url.absoluteString {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @objc private func handleDoubleTap(_ tapGesture: UITapGestureRecognizer) {
        guard let index = self.index else { return }
        delegate?.cellHasDoubleTapped(at: index)
    }
}
