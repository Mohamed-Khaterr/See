//
//  DiscoverMoviesSection.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import UIKit


protocol DiscoverMoviesSectionDelegate: AnyObject {
    func moreButtonPressed()
    func didSelectDiscoverMovie(_ movie: Show)
}



final class DiscoverMoviesSection: NSObject, CollectionViewSection {
    
    var reloadData: (() -> Void)?
    var reloadItem: (([IndexPath]) -> Void)?
    
    
    // MARK: - Variables
    weak var delegate: DiscoverMoviesSectionDelegate?
    private var movies: [Show] = []
    private let tmdbImageService = TMDBImageService()
    
    
    func updateCollectionViewData(with data: Any) {
        self.movies = data as! [Show]
        reloadData?()
    }
}


// MARK: - Comositional Layout Delegate
extension DiscoverMoviesSection {
    func sectionLayout() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.43), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        // Supplementary Header View
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        // Section
        let secion = NSCollectionLayoutSection(group: group)
        secion.orthogonalScrollingBehavior = .continuous
        secion.boundarySupplementaryItems = [header]
        
        return secion
    }
}



// MARK: - UICollectionView DataSource
extension DiscoverMoviesSection {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCollectionViewCell.identifier, for: indexPath) as! ShowCollectionViewCell
        
        let discoverMovie = movies[indexPath.row]
        
        cell.setData(cellID: discoverMovie.identifier,
                     title: discoverMovie.title ?? discoverMovie.name ?? "Error!",
                     genre: discoverMovie.genreString)
        
        // Check if Movie has poster path
        if let posterImagePath = discoverMovie.posterPath {
            Task {
                
                // Download Poster Image
                let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
                
                DispatchQueue.main.async {
                    // Check if the current cell is the correct cell
                    if cell.representedIdentifier != discoverMovie.identifier { return }
                    
                    // Display Poster Image
                    cell.setPosterImage(with: posterImage)
                }
            }
            
        } else {
            // Movie has no poster image
            cell.setPosterImage(with: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
        headerView.setTitle("Discover")
        headerView.setButton(nil, image: Constant.chevronRightImage)
        headerView.delegate = self
        return headerView
    }
}



// MARK: - UICollectionView Delegate
extension DiscoverMoviesSection {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectDiscoverMovie(movies[indexPath.row])
    }
}


// MARK: - HeaderCollectionReusableViewDelegate
extension DiscoverMoviesSection: HeaderCollectionReusableViewDelegate {
    func headerCollectionViewButtonPressed() {
        delegate?.moreButtonPressed()
    }
}
