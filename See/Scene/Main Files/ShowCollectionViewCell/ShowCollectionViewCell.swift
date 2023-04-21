//
//  ShowCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import UIKit

class ShowCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    // MARK: - Cell Configuration
    static let identifier = "ShowCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    // MARK: - Variables
    public var representedIdentifier: String = ""
    
    
    
    // MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        setupCellUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellUI()
    }
    
    
    // MARK: - Cell UI
    private func setupCellUI(){
        titleLabel.text = "Title"
        genreLabel.text = "Genre"
        
        loadingIndicator.startAnimating()
        posterImageView.image = Constant.defualtImage
    }
    
    
    // MARK: - Helper Functions
    public func setData(cellID: String, title: String, genre: String) {
        representedIdentifier = cellID
        titleLabel.text = title
        genreLabel.text = genre
    }
    
    
    public func setPosterImage(with image: UIImage?) {
        
        loadingIndicator.stopAnimating()
        
        if let image = image {
            // Set Image
            posterImageView.image = image
            
        } else {
            // Show that there is no Poster Image
        }
        
        layoutIfNeeded()
    }
}
