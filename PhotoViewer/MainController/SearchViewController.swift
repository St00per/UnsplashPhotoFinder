//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 02.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var snackBarView: UIView!
    
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
        spinner.isHidden = true
        searchButton.roundCorners(cornerRadius: 6)
        snackBarView.isHidden = true
        searchTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "UnsplashPhotoCell", bundle: nil), forCellWithReuseIdentifier: "UnsplashPhotoCell")
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        guard let request = searchTextField.text?.trimmingCharacters(in: .whitespaces), request != currentSearchQuery else { return }
        photos = []
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        spinner.isHidden = false
        currentSearchQuery = request
        currentLoadedPage = 1
        searchTextField.resignFirstResponder()
        getSearchResult(for: request, page: currentLoadedPage)
    }
    
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
                        
                        self.uploadMorePhotos()
                    } catch let error {
                        print(error)
                        DispatchQueue.main.async {
                            self.spinner.isHidden = true
                            guard self.snackBarView.isHidden == true else { return }
                            self.showSnackBar()
                        }
                    }
                }
            }
            requestTask?.resume()
        }
    }
    
    private func uploadMorePhotos() {
        currentLoadedPage += 1
        if let url = URL.with(string: "search/photos?page=\(currentLoadedPage)&per_page=30&query=\(currentSearchQuery)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Client-ID \(unsplashAccessKey)", forHTTPHeaderField: "Authorization")
            
            guard requestTask?.state != .running else { return }
            self.requestTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    do {
                        let searchResult = try JSONDecoder().decode(SearchRequestResult.self, from: data)
                        self.photos.append(contentsOf: searchResult.results)
                        
                        DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                self.spinner.isHidden = true
                                self.collectionView.reloadData()
                            }
                        }
                    } catch let error {
                        print(error)
                        DispatchQueue.main.async {
                            self.spinner.isHidden = true
                            guard self.snackBarView.isHidden == true else { return }
                            self.showSnackBar()
                        }
                    }
                }
            }
            requestTask?.resume()
        }
    }
    
    private func showSnackBar() {
        snackBarView.isHidden = false
        snackBarView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.snackBarView.alpha = 1
        }) {(isFinished) in
            if isFinished {
                self.hideSnackBar()
            }
        }
    }
    
    private func hideSnackBar() {
        let snackBarDisplayDuration: TimeInterval = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + snackBarDisplayDuration, execute: { [weak self] in
            UIView.animate(withDuration: 0.2, animations: {
                self?.snackBarView.alpha = 0
            }) {(isFinished) in
                if isFinished {
                    self?.snackBarView.isHidden = true
                }
            }
        })
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnsplashPhotoCell", for: indexPath) as? UnsplashPhotoCell else {
            return UICollectionViewCell()
        }
        cell.imageView.image = nil
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
            uploadMorePhotos()
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
