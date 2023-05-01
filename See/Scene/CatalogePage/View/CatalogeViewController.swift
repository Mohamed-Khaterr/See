//
//  CatalogeViewController.swift
//  See
//
//  Created by Khater on 3/24/23.
//

import UIKit


class CatalogeViewController: UIViewController {
    
    // MARK: - Variable
    private var selectedCollectionView: ShowType = .movie
    
    
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
        switch selectedCollectionView {
        case .movie:
            moviesCollectionView.filterButtonPressed()
            
        case .tv:
            tvShowsCollectionView.filterButtonPressed()
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
        switch index {
        case 0: // Movie
            searchBar.delegate = moviesCollectionView
            selectedCollectionView = .movie
            
        case 1: // TV Show
            searchBar.delegate = tvShowsCollectionView
            selectedCollectionView = .tv
            
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
    
    func moviesCollectionView(goToViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}




// MARK: - TV Shows CollectionView Delegate
extension CatalogeViewController: TVShowsCollectionViewDelegate {
    func tvShowsCollectionView(showAlertWith title: String, message: String) {
        Alert.show(to: self, title: title, message: message)
    }
    
    func tvShowsCollectionView(goToViewController vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
