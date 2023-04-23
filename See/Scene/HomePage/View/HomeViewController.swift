//
//  ViewController.swift
//  See
//
//  Created by Khater on 10/18/22.
//

import UIKit


class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            setupCollectionViewSections()
            collectionView.register(TrendingShowsCollectionViewCell.nib, forCellWithReuseIdentifier: TrendingShowsCollectionViewCell.identifier)
            collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: HeaderCollectionReusableView.kind, withReuseIdentifier: HeaderCollectionReusableView.identifier)
            collectionView.register(ShowCollectionViewCell.nib(), forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] index, layoutEnvironment in
                return self?.sections[index].sectionLayout()
            }
        }
    }
    
    
    // MARK: - Variables
    private let trendingSection = TrendingShowsSection()
    private let discoverSection = DiscoverMoviesSection()
    private var sections: [CollectionViewSection] = []
    private let viewModel = HomeViewModel()
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    
    // MARK: - Functions
    private func setupCollectionViewSections() {
        trendingSection.delegate = self
        discoverSection.delegate = self
        sections = [trendingSection, discoverSection]
    }
    
    
    private func setupViewModel() {
        viewModel.viewDidLoad()
        viewModel.delegate = self
    }
    
    
    private func presentDetailsOfTheShow(id: Int, type: ShowType) {
        // Navigate to DetailsOfTheShow ViewController
        let detailsOfTheShowVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: type)
        self.navigationController?.pushViewController(detailsOfTheShowVC, animated: true)
    }
}



// MARK: - UICollectionView
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sections[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    // MARK: Delegate
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return sections[indexPath.section].collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}


// MARK: - TrendingShowsSectionDelegate
extension HomeViewController: TrendingShowsSectionDelegate {
    func didSelectTrendingShow(_ show: Show) {
        presentDetailsOfTheShow(id: show.id, type: show.type!)
    }
}


// MARK: - DiscoverMoviesSectionDelegate
extension HomeViewController: DiscoverMoviesSectionDelegate {
    func moreButtonPressed() {
        print("Discover More")
    }
    
    func didSelectDiscoverMovie(_ movie: Show) {
        presentDetailsOfTheShow(id: movie.id, type: .movie)
    }
}



// MARK: - ViewModel Delegate
extension HomeViewController: HomeViewModelDelegate {
    func homeViewModel(didReceiveError title: String, message: String) {
        Alert.show(to: self, title: title, message: message, compeltionHandler: nil)
    }
    
    func homeViewModel(UpdateTrendingSection shows: [Show]) {
        trendingSection.updateShows(shows)
        collectionView.reloadData()
    }
    
    func homeViewModel(updateDicoverSection movies: [Show]) {
        discoverSection.updateShows(movies)
        collectionView.reloadData()
    }
}
