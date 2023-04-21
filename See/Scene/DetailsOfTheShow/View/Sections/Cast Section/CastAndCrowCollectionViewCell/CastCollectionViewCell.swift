//
//  CastCollectionViewCell.swift
//  See
//
//  Created by Khater on 3/22/23.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CastCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    

    // MARK: - UI Components
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var knownAsLabel: UILabel!
    
    
    // MARK: - Variables
    public var represendIdentifier = ""
    
    
    // MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()
        config()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        config()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        profileImageView.layer.cornerRadius = (profileImageView.frame.size.width) / 2
    }
    
    private func config() {
        profileImageView.image = Constant.defualtImage
        loadingIndicator.startAnimating()
        nameLabel.text = "Name"
        knownAsLabel.text = "Type"
    }
    
    
    // MARK: - Helper Functions
    func setData(cellID: String, name: String, knownAs nickName: String) {
        represendIdentifier = cellID
        nameLabel.text = name
        knownAsLabel.text = nickName
    }
    
    func setProfileImage(_ image: UIImage?) {
        loadingIndicator.stopAnimating()
        
        if let image = image {
            profileImageView.image = image
            
        } else {
            // Show that there is No Backdrop Image
            profileImageView.image = Constant.profileImage
        }
        
        layoutIfNeeded()
    }
}
