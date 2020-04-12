//
//  DetailViewController.swift
//  PhotoViewer
//
//  Created by Kirill Shteffen on 08.04.2020.
//  Copyright © 2020 Kirill Shteffen. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    
    // MARK: - Public variables
    var photos: [UnsplashPhoto] = []
    var initialPhotoIndex: Int?
    var initialScrollNeeded = true
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "UnsplashPhotoCell", bundle: nil), forCellWithReuseIdentifier: "UnsplashPhotoCell")
        
        let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(animatedlySelfDismiss))
        slideDown.direction = .down
        view.addGestureRecognizer(slideDown)
    }
    
    override func viewDidLayoutSubviews() {
        if initialScrollNeeded {
            guard let currentIndex = self.initialPhotoIndex else { return }
            collectionView.scrollToItem(at: [0, currentIndex], at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialScrollNeeded = false
    }
    
    fileprivate func getPageFromScrollView(_ scrollView: UIScrollView) -> Int {
        let width: CGFloat = collectionView.frame.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        return Int(page)
    }
    
    @objc private func animatedlySelfDismiss() {
        let searchController = presentingViewController as? SearchViewController
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.alpha = 0
            searchController?.viewWillAppear(true)
        }) {(isFinished) in
            if isFinished {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnsplashPhotoCell.reuseIdentifier, for: indexPath)
             
        guard let unsplashCell = cell as? UnsplashPhotoCell else {
            assertionFailure()
            return cell
        }
        
        unsplashCell.configure(with: photos[indexPath.row], quality: .regular)
        unsplashCell.imageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}
