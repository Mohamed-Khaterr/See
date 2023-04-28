//
//  SimilarShowsSection.swift
//  See
//
//  Created by Khater on 3/22/23.
//

import UIKit

protocol SimilarShowSectionDelegate: AnyObject {
    func similarShowSection(didSelectSimilar show: Show)
}


class SimilarShowsSection: NSObject, CollectionViewSection {
    
    var reloadData: (() -> Void)?
    var reloadItem: (([IndexPath]) -> Void)?
    
    
    // MARK: - Variable
    weak var delegate: SimilarShowSectionDelegate?
    private var shows: [Show] = []
    private let tmdbImageService = TMDBImageService()
    
    
    // MARK: - Functions
    func updateCollectionViewData(with data: Any) {
        self.shows = data as! [Show]
        reloadData?()
    }
}


// MARK: - Comositional Layout Delegate
extension SimilarShowsSection {
    func sectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}



// MARK: - UICollectionView DataSource
extension SimilarShowsSection {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
        
        headerView.setTitle("Similar Shows")
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCollectionViewCell.identifier, for: indexPath) as! ShowCollectionViewCell
        
        let show = shows[indexPath.row]
        
        cell.setData(cellID: show.identifier,
                     title: show.title ?? show.name ?? "Error!",
                     genre: show.genreString)
        
        // Check if Movie has poster path
        if let posterImagePath = show.posterPath {
            Task {
                // Download Poster Image
                let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
                
                DispatchQueue.main.async {
                    // Check if the current cell is the correct cell
                    if cell.representedIdentifier != show.identifier { return }
                    
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
}



// MARK: - UICollectionView Delegate
extension SimilarShowsSection {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.similarShowSection(didSelectSimilar: shows[indexPath.row])
    }
}
