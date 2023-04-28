//
//  TrendingShowsSection.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import UIKit


protocol TrendingShowsSectionDelegate: AnyObject {
    func didSelectTrendingShow(_ show: Show)
}


final class TrendingShowsSection: NSObject, CollectionViewSection {
    
    var reloadData: (() -> Void)?
    var reloadItem: (([IndexPath]) -> Void)?
    
    
    // MARK: - Variables
    weak var delegate: TrendingShowsSectionDelegate?
    private var shows: [Show] = []
    private let tmdbImageService = TMDBImageService()
    
    
    // MARK: - Functions
    func updateCollectionViewData(with data: Any) {
        self.shows = data as! [Show]
        reloadData?()
    }
}

// MARK: - Comositional Layout Delegate
extension TrendingShowsSection {
    func sectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}



// MARK: - UICollectionView DataSource
extension TrendingShowsSection {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingShowsCollectionViewCell.identifier, for: indexPath) as! TrendingShowsCollectionViewCell
        
        let trendingShow = shows[indexPath.row]
        
        cell.setData(cellID: trendingShow.identifier,
                     title: trendingShow.title ?? trendingShow.name ?? "Error",
                     type: trendingShow.safeTypeString,
                     year: trendingShow.releaseYear,
                     genre: trendingShow.genreString,
                     popularity: trendingShow.popularity,
                     rate: trendingShow.rate)
        
        // Get Trending Show Backdrop Image
        if let backdropImagePath = trendingShow.backdropPath {
            Task {
                // Download Image
                let backdropImage = await tmdbImageService.getBackdropImage(withPath: backdropImagePath, inHeighQuality: true)
                
                DispatchQueue.main.async {
                    // Check if it's the correct cell
                    if cell.representedIdentifier != trendingShow.identifier { return }
                    
                    // Show Image in the Cell
                    cell.setBackdropImage(with: backdropImage)
                }
            }
        } else {
            // NO Image for This Show
            cell.setBackdropImage(with: nil)
        }
        
        return cell
    }
}



// MARK: - UICollectionView Delegate
extension TrendingShowsSection {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectTrendingShow(shows[indexPath.row])
    }
}
