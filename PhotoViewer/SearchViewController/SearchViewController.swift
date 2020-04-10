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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var snackBarView: UIView!
    
    // MARK: - Private constants
    private let spaceBetweenCell: CGFloat = 8
    private let itemPerRow: CGFloat = 4
    private let unsplashAccessKey = "iZnFTNJfLHt3QyzUQSihOuxjmEYpXO96ZPaQquA8S7M"
    
    // MARK: - Private variables
    private var photos: [UnsplashPhoto] = []
    private var currentSearchQuery = ""
    private var currentLoadedPage = 1
    private var photosPerPage = 30
    private var requestTask: URLSessionDataTask?
    private var urlRequest: URLRequest? {
        get {
           makeURLRequest()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        noPhotosLabel.isHidden = true
        searchButton.roundCorners(cornerRadius: 6)
        snackBarView.isHidden = true
        
        searchTextField.delegate = self
        searchTextField.keyboardType = .asciiCapable
        searchTextField.returnKeyType = .search
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "UnsplashPhotoCell", bundle: nil), forCellWithReuseIdentifier: "UnsplashPhotoCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.alpha = 1
        self.headerView.alpha = 1
    }
    
    // MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        startSearchRequest()
    }
    
    // MARK: - Private methods
    private func makeURLRequest() -> URLRequest? {
        if let url = URL.with(string: "search/photos?page=\(currentLoadedPage)&per_page=\(photosPerPage)&query=\(currentSearchQuery)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Client-ID \(unsplashAccessKey)", forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        return nil
    }
    
    private func getSearchResult(isFirstLoad: Bool) {
        
        guard let urlRequest = self.urlRequest, requestTask?.state != .running else { return }
        
        self.requestTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                do {
                    let searchResult = try JSONDecoder().decode(SearchRequestResult.self, from: data)
                    
                    if searchResult.results.count == 0, isFirstLoad {
                        DispatchQueue.main.async {
                            self.noPhotosLabel.isHidden = false
                            self.spinner.isHidden = true
                        }
                        return
                    }
                    
                    self.photos.append(contentsOf: searchResult.results)
                    self.updateCollectionView(with: searchResult.results, isFirstLoad: isFirstLoad)
                } catch let error {
                    print(error)
                    DispatchQueue.main.async {
                        self.showSnackBar()
                    }
                }
            }
        }
        requestTask?.resume()
    }
    
    private func startSearchRequest() {
        noPhotosLabel.isHidden = true
        guard let request = searchTextField.text?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "+"),
            request != currentSearchQuery else {
                return
            }
        photos = []
        currentSearchQuery = request
        currentLoadedPage = 1
        
        collectionView.reloadData()
        
        spinner.isHidden = false
        searchTextField.resignFirstResponder()
        getSearchResult(isFirstLoad: true)
    }
    
    private func downloadMorePhotos() {
        currentLoadedPage += 1
        getSearchResult(isFirstLoad: false)
    }
    
    private func updateCollectionView(with newPhotos: [UnsplashPhoto], isFirstLoad: Bool) {
        DispatchQueue.main.async {
            var newIndexPaths: [IndexPath] = []
            for (index, _) in newPhotos.enumerated() {
                var addedIndex: Int
                if isFirstLoad {
                    addedIndex = index
                } else {
                    addedIndex = index + (self.photos.count - newPhotos.count)
                }
                
                let indexPath = IndexPath(item: addedIndex, section: 0)
                newIndexPaths.append(indexPath)
            }
            self.spinner.isHidden = true
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: newIndexPaths)
            }) {(isFinished) in
                if isFinished, isFirstLoad {
                    self.downloadMorePhotos()
                }
            }
        }
    }
    
    private func showSnackBar() {
        guard self.snackBarView.isHidden == true else { return }
        spinner.isHidden = true
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
    
    func customSnapShotFrom(view:UIView) -> UIView {

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let cellImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageView = UIImageView(image: cellImage)
        return imageView
    }
    
    private func showDetailViewControllerAnimatedly(fromCellAt index: Int) {
        
        guard let cell = collectionView.cellForItem(at: [0,index]),
              let cellAttributes = collectionView.layoutAttributesForItem(at: [0,index]) else {
                return
        }
        let snapshot = customSnapShotFrom(view: cell)
        print(snapshot)
        
        let cellFrameInSuperview = collectionView.convert(cellAttributes.frame, to: collectionView.superview)
        snapshot.frame = cellFrameInSuperview
        snapshot.contentMode = .scaleAspectFit
        
        
        self.view.addSubview(snapshot)
        
        snapshot.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: snapshot,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      relatedBy: NSLayoutConstraint.Relation.equal,
                                                      toItem: view,
                                                      attribute: NSLayoutConstraint.Attribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: snapshot,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: view,
                                                    attribute: NSLayoutConstraint.Attribute.centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        let widthConstraint = NSLayoutConstraint(item: snapshot,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1,
                                                 constant: collectionView.frame.width)
        let heightConstraint = NSLayoutConstraint(item: snapshot,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: collectionView.frame.height)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 0.3
            self.headerView.alpha = 0.3
        }) {(isFinished) in
            if isFinished {
                
                let photoDetailViewController = PhotoDetailViewController()
                photoDetailViewController.photos = self.photos
                photoDetailViewController.initialPhotoIndex = index
                photoDetailViewController.modalPresentationStyle = .overCurrentContext
                self.present(photoDetailViewController, animated: false, completion: {
                    snapshot.removeFromSuperview()
                })
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnsplashPhotoCell.reuseIdentifier, for: indexPath)
             
        guard let unsplashCell = cell as? UnsplashPhotoCell else {
            assertionFailure()
            return cell
        }
        
        unsplashCell.configure(with: photos[indexPath.row], quality: .small)
        unsplashCell.delegate = self
        unsplashCell.index = indexPath.row
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
            downloadMorePhotos()
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        noPhotosLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startSearchRequest()
        self.view.endEditing(true)
        return false
    }
}

extension SearchViewController: UnsplashPhotoCellDelegate {
    
    func cellHasDoubleTapped(at index: Int) {
        showDetailViewControllerAnimatedly(fromCellAt: index)
    }
}

