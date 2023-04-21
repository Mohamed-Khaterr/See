//
//  WatchlistCollectionView.swift
//  See
//
//  Created by Khater on 3/27/23.
//

import UIKit

class WatchlistCollectionView: UICollectionView {
    
    // MARK: - Variables
    private let tmdbImageService = TMDBImageService()
    private var shows: [Show] = []
    
    
    
    // MARK: - LifeCycle
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        register(SavedCollectionViewCell.nib(), forCellWithReuseIdentifier: SavedCollectionViewCell.identifier)
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setShows(_ shows: [Show]) {
        self.shows = shows
        reloadData()
    }
}



// MARK: - UICollectionView DataSource
extension WatchlistCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: SavedCollectionViewCell.identifier, for: indexPath) as! SavedCollectionViewCell
        let show = shows[indexPath.row]
        
        cell.setData(cellID: show.identifier,
                     title: show.safeTitle,
                     genre: show.genreString,
                     isFavorite: false)
        
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
extension WatchlistCollectionView: UICollectionViewDelegate {
    
}



// MARK: - FlowLayout
extension WatchlistCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (frame.width / 2) - 16, height: frame.height / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}
