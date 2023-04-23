//
//  SavedViewController.swift
//  See
//
//  Created by Khater on 3/26/23.
//

import UIKit

class SavedViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var pagingCollectionView: UIPagingCollectionView! {
        didSet {
            pagingCollectionView.pagingDataSource = self
        }
    }
    
    private let favoritesCollectionView = FavoritesCollectionView()
    private let watchlistCollectionView = WatchlistCollectionView()
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


// MARK: - UIPagingCollectionView DataSource
extension SavedViewController: UIPagingCollectionViewDataSource {
    func pagingCollectionView(titleForHeaderButtons pagingCollectionView: UIPagingCollectionView) -> [String] {
        return ["Favorites", "Watch List"]
    }
    
    func pagingCollectionView(subCollectionViews pagingCollectionView: UIPagingCollectionView) -> [UICollectionView] {
        return [favoritesCollectionView, watchlistCollectionView]
    }
}
