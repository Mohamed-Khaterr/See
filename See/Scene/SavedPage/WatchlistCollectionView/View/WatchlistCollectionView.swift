//
//  WatchlistCollectionView.swift
//  See
//
//  Created by Khater on 3/27/23.
//

import UIKit

class WatchlistCollectionView: UICollectionView {
    
    // MARK: - UIComponents
    private let noLoginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login to see your Watchlist."
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont(name: "Inter-Medium", size: 17)
        label.numberOfLines = 1
        return label
    }()
    
    
    // MARK: - Variables
    private let viewModel = WatchlistViewModel()
    weak var viewModelDelegate: WatchlistViewModelDelegate? {
        didSet {
            viewModel.delegate = viewModelDelegate
        }
    }
    
    
    // MARK: - LifeCycle
    init() {
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        // Config
        register(WatchlistCollectionViewCell.nib(), forCellWithReuseIdentifier: WatchlistCollectionViewCell.identifier)
        delegate = self
        dataSource = self
        
        // Label
        addSubview(noLoginLabel)
        noLoginLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        noLoginLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        // Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        
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
    
    
    public func viewDidLoad(){
        viewModel.viewDidLoad()
    }
    
    
    // MARK: - Functions
    @objc private func refresh() {
        viewModel.fetchWatchlist()
    }
}



// MARK: - UICollectionView DataSource
extension WatchlistCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getWatchlistCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: WatchlistCollectionViewCell.identifier, for: indexPath) as! WatchlistCollectionViewCell
        
        let (cellID, title, genre) = viewModel.getWatchlistShow(at: indexPath)
        cell.setData(cellID: cellID, title: title, genre: genre)
        
        viewModel.getWatchlistShowPosterImage(at: indexPath) { cellID, posterImage in
            guard cell.getID() == cellID else { return }
            cell.setPosterImage(with: posterImage)
        }
        
        return cell
    }
}



// MARK: - UICollectionView Delegate
extension WatchlistCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectWatchlistShow(at: indexPath)
    }
}



// MARK: - FlowLayout
extension WatchlistCollectionView: UICollectionViewDelegateFlowLayout {
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
