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
        
        // Favorites
        favoritesCollectionView.viewModelDelegate = self
        favoritesCollectionView.viewDidLoad()
        
        // Watch list
        watchlistCollectionView.viewModelDelegate = self
        watchlistCollectionView.viewDidLoad()
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


// MARK: - FavoritesViewModelDelegatye
extension SavedViewController: FavoritesViewModelDelegate {
    func favoritesViewModel(errorTitle title: String?, message: String) {
        Alert.show(to: self, title: title, message: message)
    }
    
    func favoritesViewModel(goToViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - WatchlistViewModelDelegate
extension SavedViewController: WatchlistViewModelDelegate {
    func watchlistViewModel(errorTitle: String?, message: String) {
        Alert.show(to: self, title: title, message: message)
    }
    
    func watchlistViewModel(goToViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
