//
//  FavoriteCollectionView.swift
//  See
//
//  Created by Khater on 3/27/23.
//

import UIKit

class FavoritesCollectionView: UICollectionView {
    
    // MARK: - Variables
    private let viewModel = FavoritesViewModel()
    weak var viewModelDelegate: FavoritesViewModelDelegate? {
        didSet {
            viewModel.delegate = viewModelDelegate
        }
    }
    
    
    // MARK: - UIComponents
    private let noLoginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login to see your Favorites."
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont(name: "Inter-Medium", size: 17)
        label.numberOfLines = 1
        return label
    }()
    
    
    // MARK: - LifeCycle
    init() {
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        // Config
        register(FavoritesCollectionViewCell.nib(), forCellWithReuseIdentifier: FavoritesCollectionViewCell.identifier)
        delegate = self
        dataSource = self
        
        // Label
        addSubview(noLoginLabel)
        noLoginLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        noLoginLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        
        // ViewModel
        viewModel.reloadeCollectionView = { [weak self] in
            self?.refreshControl?.endRefreshing()
            self?.reloadData()
        }
        
        viewModel.isNoLoginLabelHidden = { [weak self] isHidden in
            self?.noLoginLabel.isHidden = isHidden
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func viewDidLoad() {
        viewModel.viewDidLoad()
    }
    
    
    @objc private func refresh(sender: UIRefreshControl){
        viewModel.fetchFavorites()
    }
}



// MARK: - UICollectionView DataSource
extension FavoritesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getFavoritesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier, for: indexPath) as! FavoritesCollectionViewCell
        let (cellID, title, genre) = viewModel.getFavoriteShowData(at: indexPath)
        
        cell.setData(cellID: cellID,
                     title: title,
                     genre: genre)
        
        viewModel.getFavoriteShowPosterImage(at: indexPath) { cellID, posterImage in
            guard cell.getID() == cellID else { return  }
            cell.setPosterImage(with: posterImage)
        }
        
        return cell
    }
}



// MARK: - UICollectionView Delegate
extension FavoritesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectFavoriteShow(at: indexPath)
    }
}


// MARK: - FlowLayout
extension FavoritesCollectionView: UICollectionViewDelegateFlowLayout {
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
