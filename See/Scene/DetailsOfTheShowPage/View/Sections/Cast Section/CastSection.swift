//
//  CastSection.swift
//  See
//
//  Created by Khater on 3/22/23.
//

import UIKit


protocol CastSectionDelegate: AnyObject {
    func castSection(didSelect cast: Cast)
}


class CastSection: NSObject, CollectionViewSection {
    var reloadData: (() -> Void)?
    var reloadItem: (([IndexPath]) -> Void)?
    
    
    // MARK: - Variable
    weak var delegate: CastSectionDelegate?
    private var cast: [Cast] = []
    private let tmdbImageService = TMDBImageService()
    
    
    // MARK: - Functions
    func updateCollectionViewData(with data: Any) {
        self.cast = data as! [Cast]
        reloadData?()
    }
}



// MARK: - Comositional Layout Delegate
extension CastSection {
    func sectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(0.35))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}



// MARK: - UICollectionView DataSource
extension CastSection {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
        headerView.setTitle("Cast & Crew")
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.identifier, for: indexPath) as! CastCollectionViewCell
        
        let person = cast[indexPath.row]
        cell.setData(cellID: person.identifier,
                     name: person.name,
                     knownAs: person.character ?? "Unknown")
        
        if let profileImagePath = person.profilePath {
            Task{
                // Download Image
                let profileImage = await tmdbImageService.getCastProfileImage(withPath: profileImagePath, inHeighQuailty: false)

                DispatchQueue.main.async {
                    // Check if it's the correct cell
                    if cell.represendIdentifier != person.identifier { return }

                    // Show Image in the Cell
                    cell.setProfileImage(profileImage)
                }
            }
        } else {
            cell.setProfileImage(nil)
        }
        
        return cell
    }
}



// MARK: - UICollectionView Delegate
extension CastSection {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.castSection(didSelect: cast[indexPath.row])
    }
}
