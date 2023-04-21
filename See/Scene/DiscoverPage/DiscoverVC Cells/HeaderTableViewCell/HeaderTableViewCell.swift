//
//  HeaderTableViewCell.swift
//  See
//
//  Created by Khater on 11/15/22.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
    
    static let identifier = "HeaderTableViewCell"
    
    static func nib() -> UINib { return UINib(nibName: "HeaderTableViewCell", bundle: nil) }

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellModels: [(title: String, image: UIImage?)] = [
        (title: "Top Popular", image: UIImage(named: "backdrop (1)")),
        (title: "Top Revenue", image: UIImage(named: "backdrop (2)")),
        (title: "Top Primary", image: UIImage(named: "backdrop (3)")),
        (title: "Top Rated", image: UIImage(named: "backdrop (4)"))
    ]
    
    private var currentCellIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(HeaderCollectionViewCell.nib(), forCellWithReuseIdentifier: HeaderCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        loopThroughCollectionView()
    }
    
    private func loopThroughCollectionView(){
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            self.currentCellIndex += 1
            if self.currentCellIndex >= self.cellModels.count{
                self.currentCellIndex = 0
            }
            self.collectionView.scrollToItem(at: IndexPath(item: self.currentCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}


// MARK: - CollectionView DataSource
extension HeaderTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCollectionViewCell.identifier, for: indexPath) as! HeaderCollectionViewCell
        cell.titleLabel.text = cellModels[indexPath.row].title
        cell.imageView.image = cellModels[indexPath.row].image
        return cell
    }
}


// MARK: - CollectionView Delegate & FlowLayout
extension HeaderTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: frame.height - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
