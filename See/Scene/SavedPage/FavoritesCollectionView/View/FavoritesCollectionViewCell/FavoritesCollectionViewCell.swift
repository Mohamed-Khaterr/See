//
//  FavoritesCollectionViewCell.swift
//  See
//
//  Created by Khater on 4/24/23.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Statics
    public static let identifier = "FavoritesCollectionViewCell"
    public static func nib() -> UINib {
        return UINib(nibName: "FavoritesCollectionViewCell", bundle: nil)
    }
    
    
    // MARK: - Variables
    private var id = ""
    
    
    // MARK: - UIComponents
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    
    // MARK: - IB Actions
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
    }
    
    
    // MARK: - Public Functions
    public func setData(cellID: String,title: String, genre: String) {
        id = cellID
        titleLabel.text = title
        genreLabel.text = genre
    }
    
    public func setPosterImage(with image: UIImage?) {
        posterImageView.image = image
        layoutIfNeeded()
    }
    
    public func getID() -> String {
        return id
    }
}
