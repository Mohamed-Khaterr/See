//
//  CatalogeViewController.swift
//  See
//
//  Created by Khater on 3/24/23.
//

import UIKit

class CatalogeViewController: UIViewController {
    
    
    // MARK: - Variables
    private var filter: Filter?
    
    
    
    // MARK: - UI Components
    @IBOutlet var searchBar: UISearchBar! 
    
    @IBOutlet weak var pagingCollectionView: UIPagingCollectionView! {
        didSet {
            pagingCollectionView.pagingDataSource = self
            pagingCollectionView.pagingDelegate = self
            tvShowsCollectionView.tvDelegate = self
        }
    }
    
    private let moviesCollectionView = MoviesCollectionView()
    private let tvShowsCollectionView = TVShowsCollectionView()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        moviesCollectionView.moviesDelegate = self
        // The searchBar delegate pointer will change in UIPagingCollectionView Delegate
        searchBar.delegate = moviesCollectionView
    }
    
    
    
    // MARK: - Functions
    private func setupNavigationBar() {
        navigationItem.titleView = searchBar
        let filterButton = UIBarButtonItem(image: Constant.settingImage, style: .done, target: self, action: #selector(filterButtonPressed))
        navigationItem.rightBarButtonItem = filterButton
    }
    
    
    
    // MARK: - Button Actions
    @objc private func filterButtonPressed() {
        let filterVC = FilterViewController.storyboardInstance(with: filter)
        filterVC.delegate = self
        navigationController?.pushViewController(filterVC, animated: true)
    }
}




// MARK: - UIPagingCollectionView - Delegate & DataSource
extension CatalogeViewController: UIPagingCollectionViewDataSource, UIPagingCollectionViewDelegate {
    
    func pagingCollectionView(titleForHeaderButtons pagingCollectionView: UIPagingCollectionView) -> [String] {
        return ["Movies", "TV Shows"]
    }
    
    func pagingCollectionView(subCollectionViews pagingCollectionView: UIPagingCollectionView) -> [UICollectionView] {
        return [moviesCollectionView, tvShowsCollectionView]
    }
    
    func pagingCollectionView(didScrollToCollectionViewAt index: Int) {
        switch index {
        case 0: // Movie
            searchBar.delegate = moviesCollectionView
            
        case 1: // TV Show
            searchBar.delegate = tvShowsCollectionView
            
        default:
            searchBar.delegate = nil
        }
    }
}



// MARK: - MoviesCollectionView Delegate
extension CatalogeViewController: MoviesCollectionViewDelegate {
    func moviesCollectionView(showAlertWith title: String, message: String) {
        Alert.show(to: self, title: title, message: message)
    }
    
    func moviesCollectionView(didSelectMovie id: Int) {
        let detailsOfTheShowVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: .movie)
        navigationController?.pushViewController(detailsOfTheShowVC, animated: true)
    }
}




// MARK: - TV Shows CollectionView Delegate
extension CatalogeViewController: TVShowsCollectionViewDelegate {
    func tvShowsCollectionView(showAlertWith title: String, message: String) {
        Alert.show(to: self, title: title, message: message)
    }
    
    func tvShowsCollectionView(didSelectTV id: Int) {
        let detailsOfTheShowVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: .tv)
        navigationController?.pushViewController(detailsOfTheShowVC, animated: true)
    }
}





// MARK: - FilterViewController Delegate
extension CatalogeViewController: FilterViewControllerDelegate {
    func filterViewController(didSelectFilter filter: Filter?) {
        self.filter = filter
        moviesCollectionView.applyFilter(with: filter)
    }
}
