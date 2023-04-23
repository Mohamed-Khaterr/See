//
//  CatalogeViewController.swift
//  See
//
//  Created by Khater on 3/24/23.
//

import UIKit


class CatalogeViewController: UIViewController {
    
    // MARK: - Variable
    private var selectedCollectionViewIndex = 0
    
    
    // MARK: - UI Components
    @IBOutlet var searchBar: UISearchBar! 
    
    @IBOutlet weak var pagingCollectionView: UIPagingCollectionView! {
        didSet {
            pagingCollectionView.pagingDataSource = self
            pagingCollectionView.pagingDelegate = self
        }
    }
    
    private let moviesCollectionView = MoviesCollectionView()
    private let tvShowsCollectionView = TVShowsCollectionView()
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        moviesCollectionView.moviesDelegate = self
        tvShowsCollectionView.tvDelegate = self
        
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
        switch selectedCollectionViewIndex {
        case 0: // MoviesCollectionView is Selected
            moviesCollectionView.filterButtonPressed()
            
        case 1: // TVShowCollectionView is Selected
            tvShowsCollectionView.filterButtonPressed()
            
        default: break
        }
    }
}




// MARK: - UIPagingCollectionView
extension CatalogeViewController: UIPagingCollectionViewDataSource, UIPagingCollectionViewDelegate {
    // MARK: DataSource
    func pagingCollectionView(titleForHeaderButtons pagingCollectionView: UIPagingCollectionView) -> [String] {
        return ["Movies", "TV Shows"]
    }
    
    func pagingCollectionView(subCollectionViews pagingCollectionView: UIPagingCollectionView) -> [UICollectionView] {
        return [moviesCollectionView, tvShowsCollectionView]
    }
    
    
    // MARK: Delegate
    func pagingCollectionView(didScrollToCollectionViewAt index: Int) {
        selectedCollectionViewIndex = index
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
    
    func moviesCollectionView(presentViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
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
    
    func tvShowsCollectionView(presentViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
