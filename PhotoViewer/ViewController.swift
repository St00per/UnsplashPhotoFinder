//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    // MARK: - Private constants
    private let spaceBetweenCell: CGFloat = 8
    private let itemPerRow: CGFloat = 4
    private let unsplashAccessKey = "iZnFTNJfLHt3QyzUQSihOuxjmEYpXO96ZPaQquA8S7M"
    // MARK: - Private variables
    private var photos: [UnsplashPhoto] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "UnsplashPhotoCell", bundle: nil), forCellWithReuseIdentifier: "UnsplashPhotoCell")
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        guard let request = searchTextField.text else { return }
        getSearchResult(for: request)
    }
    
    // MARK: - Public methods
    // MARK: - Private methods
    private func getSearchResult(for request: String) {
        if let url = URL.with(string: "search/photos?page=1&count=50&query=balls") {
           var urlRequest = URLRequest(url: url)
           urlRequest.setValue("Client-ID \(unsplashAccessKey)", forHTTPHeaderField: "Authorization")
           
           URLSession.shared.dataTask(with: urlRequest) { data, response, error in
              if let data = data {
                 do {
                    let searchResult = try JSONDecoder().decode(SearchRequestResult.self, from: data)
                    self.photos = searchResult.results
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                 } catch let error {
                    print(error)
                 }
              }
           }.resume()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnsplashPhotoCell", for: indexPath) as? UnsplashPhotoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = spaceBetweenCell * (itemPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spaceBetweenCell, left: spaceBetweenCell, bottom: spaceBetweenCell, right: spaceBetweenCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceBetweenCell
    }
}

extension ViewController: UITextFieldDelegate {
    
}
