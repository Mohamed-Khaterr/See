//
//  SortingTableViewCell.swift
//  See
//
//  Created by Khater on 10/29/22.
//
/*
    border and cornerRadius is added in xib file
*/
import UIKit

class SortingTableViewCell: UITableViewCell {
    
    // MARK: - Cell Idenifiter
    public static let identifiter = "SortingTableViewCell"
    public static func nib() -> UINib{
        return UINib(nibName: "SortingTableViewCell", bundle: nil)
    }
    
    
    // MARK: - UI Components
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var sortTitleLabel: UILabel!
    
    
    
    // MARK: - Variables
    
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    // MARK: - Functions
    public func config(sortTitle: String) {
        sortTitleLabel.text = sortTitle
    }
    
    public func checkBox(_ isChecked: Bool) {
        checkBoxView.backgroundColor = isChecked ? .label : .systemBackground
    }
}
