//
//  WatchlistCollectionViewCell.swift
//  See
//
//  Created by Khater on 4/24/23.
//

import UIKit

class WatchlistCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Statics
    public static let identifier = "WatchlistCollectionViewCell"
    public static func nib() -> UINib {
        return UINib(nibName: "WatchlistCollectionViewCell", bundle: nil)
    }
    
    
    // MARK: - UIComponents
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var loadingIndicatore: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    
    
    // MARK: - Variable
    private var id = ""
    
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicatore.startAnimating()
    }
    
    
    // MARK: - Functions
    public func setData(cellID: String, title: String, genre: String){
        id = cellID
        titleLabel.text = title
        genreLabel.text = genre
    }
    
    public func setPosterImage(with image: UIImage?) {
        loadingIndicatore.stopAnimating()
        posterImageView.image = image
        layoutIfNeeded()
    }
    
    public func getID() -> String {
        return id
    }
}
