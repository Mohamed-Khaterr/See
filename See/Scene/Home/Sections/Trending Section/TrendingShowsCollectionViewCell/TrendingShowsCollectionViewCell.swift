//
//  HeaderMovieCollectionViewCell.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import UIKit

class TrendingShowsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Cell Config
    static let identifier = "TrendingShowsCollectionViewCell"
    
    static let nib: UINib = {
        return UINib(nibName: identifier, bundle: nil)
    }()
    
    // MARK: - UI Components
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var typeOfShowLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearAndGenreLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    
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
        makeLabelsTextEmpty()
        
        // Add Gradient Layer to imageView
        imageView.addGradientLayer(withHeightRatio: 0.4)
        
        imageView.image = Constant.defualtImage
        loadingIndicator.startAnimating()
    }
    
    private func makeLabelsTextEmpty(){
        [titleLabel, typeOfShowLabel, yearAndGenreLabel, popularityLabel, rateLabel].forEach { label in
            label.text = ""
        }
    }
    
    
    // MARK: - Helper Functions
    public func setData(cellID: String, title: String, type: String, year: String, genre: String, popularity: Double, rate: Double) {
        representedIdentifier = cellID
        titleLabel.text = title
        typeOfShowLabel.text = type
        yearAndGenreLabel.text = "\(genre), \(year)"
        popularityLabel.text = "Popularity \(String(format: "%.0f", popularity))"
        rateLabel.text = "Rate \(String(format: "%.1f", rate))"
    }
    
    public func setBackdropImage(with image: UIImage?) {
        loadingIndicator.stopAnimating()
        
        if let image = image {
            imageView.image = image
            
        } else {
            // Show that there is No Backdrop Image
        }
        
        layoutIfNeeded()
    }
}
