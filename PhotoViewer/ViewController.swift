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
    private var currentSearchQuery = ""
    private var currentLoadedPage = 1
    private var requestTask: URLSessionDataTask?
    
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
        currentSearchQuery = request
        searchTextField.resignFirstResponder()
        getSearchResult(for: request, page: currentLoadedPage)
    }
    
    // MARK: - Public methods
    // MARK: - Private methods
    private func getSearchResult(for request: String, page: Int) {
        if let url = URL.with(string: "search/photos?page=\(page)&per_page=30&query=\(request)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Client-ID \(unsplashAccessKey)", forHTTPHeaderField: "Authorization")
            
            guard requestTask?.state != .running else { return }
            self.requestTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    do {
                        let searchResult = try JSONDecoder().decode(SearchRequestResult.self, from: data)
                        self.photos.append(contentsOf: searchResult.results)
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
            
            requestTask?.resume()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard requestTask?.state == .completed else { return }
        let scrollIsCloseToNextPage: Bool = scrollView.contentOffset.y > scrollView.contentSize.height - (scrollView.frame.height * 2)
        
        if scrollIsCloseToNextPage, scrollView.contentSize.height > 0 {
            currentLoadedPage += 1
            getSearchResult(for: currentSearchQuery, page: currentLoadedPage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
