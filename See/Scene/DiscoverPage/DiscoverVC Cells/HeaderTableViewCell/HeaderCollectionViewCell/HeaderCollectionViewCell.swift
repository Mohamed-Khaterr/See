//
//  HeaderCollectionViewCell.swift
//  See
//
//  Created by Khater on 11/15/22.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HeaderCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "HeaderCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
