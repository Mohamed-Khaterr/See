//
//  MoviesCollectionView.swift
//  See
//
//  Created by Khater on 3/24/23.
//

import UIKit


protocol MoviesCollectionViewDelegate: AnyObject {
    func moviesCollectionView(didSelectMovie id: Int)
    func moviesCollectionView(showAlertWith title: String, message: String)
}


final class MoviesCollectionView: UICollectionView {
    
    // MARK: - Variables
    public weak var moviesDelegate: MoviesCollectionViewDelegate?
    private let viewModel = MoviesCollectionViewViewModel()
    
    
    // MARK: - LifeCycle
    init() {
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        // Register Views & Resources
        register(ShowCollectionViewCell.nib(), forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyFooter")
        delegate = self
        dataSource = self
        
        // Appearnce & Interactions
        keyboardDismissMode = .onDrag
        
        // ViewModel
        viewModel.delegate = self
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    public func applyFilter(with filter: Filter?) {
        viewModel.applyFilter(with: filter)
    }
}



// MARK: - DataSource
extension MoviesCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.moviesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCollectionViewCell.identifier, for: indexPath) as! ShowCollectionViewCell
        let movie = viewModel.getMovieData(at: indexPath.row)
        
        cell.setData(cellID: movie.identifier,
                     title: movie.safeTitle,
                     genre: movie.genreString)
        
        
        viewModel.getPosterImage(forMovieAt: indexPath.row) { posterImage in
            // Check if the current cell is the correct cell
            if cell.representedIdentifier != movie.identifier { return }
            
            // Display Poster Image
            cell.setPosterImage(with: posterImage)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyFooter", for: indexPath)
        let loadingIndicator = UIActivityIndicatorView(frame: view.bounds)
        loadingIndicator.color = .label
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.addSubview(loadingIndicator)
        return view
    }
}



// MARK: - Delegate
extension MoviesCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.getMovieData(at: indexPath.row)
        moviesDelegate?.moviesCollectionView(didSelectMovie: movie.id)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        // Paging
        if elementKind == UICollectionView.elementKindSectionFooter {
            viewModel.collectionViewReachEnd()
        }
    }
}




// MARK: - FlowLayout
extension MoviesCollectionView: UICollectionViewDelegateFlowLayout {
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



// MARK: - ViewModel
extension MoviesCollectionView: MoviesCollectionViewViewModelDelegat {
    func moviesCollectionViewViewModel(didReceiveError title: String, message: String) {
        moviesDelegate?.moviesCollectionView(showAlertWith: title, message: message)
    }
    
    func moviesCollectionViewViewModel(shouldReloadData success: Bool) {
        reloadData()
    }
}



// MARK: - UISearchBar Delegate
extension MoviesCollectionView: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(for: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
