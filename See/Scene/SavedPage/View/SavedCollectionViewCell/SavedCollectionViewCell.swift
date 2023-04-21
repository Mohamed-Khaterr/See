//
//  SavedCollectionViewCell.swift
//  See
//
//  Created by Khater on 11/3/22.
//

import UIKit


protocol SavedCollectionViewCellDelegate: AnyObject {
    func savedCollectionViewCell(buttonPressed success: Bool)
}


class SavedCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SavedCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "SavedCollectionViewCell", bundle: nil)
    }
    
    
    // MARK: - UI Components
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    
    
    // MARK: - Variables
    public weak var delegate: SavedCollectionViewCellDelegate?
    public var representedIdentifier: String = ""
    
    
    // MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        setupUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    // MARK: - UI
    private func setupUI() {
        button.cornerRadius = button.frame.height / 2
        posterImageView.cornerRadius = 15
        loadingIndicator.startAnimating()
    }
    
    
    
    // MARK: - IB Actions
    @IBAction func buttonPressed(_ sender: UIButton) {
        delegate?.savedCollectionViewCell(buttonPressed: true)
    }
    
    
    
    // MARK: - Cell Setup
    public func setData(cellID: String, title: String, genre: String, isFavorite: Bool) {
        representedIdentifier = cellID
        titleLabel.text = title
        genreLabel.text = genre
        
        if isFavorite {
            // Set button image as Favortie Image
            button.setImage(Constant.favouriteFillImage, for: .normal)
            
        } else {
            // Set button image as Watchlist Image
            button.setImage(Constant.bookmarkFillImage, for: .normal)
        }
    }
    
    public func setPosterImage(with image: UIImage?) {
        loadingIndicator.stopAnimating()
        if let image = image {
            posterImageView.image = image
            
        } else {
            posterImageView.image = Constant.defualtImage
        }
        
        layoutIfNeeded()
    }
}
