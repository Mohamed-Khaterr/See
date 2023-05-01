//
//  TVShowsCollectionView.swift
//  See
//
//  Created by Khater on 3/24/23.
//

import UIKit


protocol TVShowsCollectionViewDelegate: AnyObject {
    func tvShowsCollectionView(showAlertWith title: String, message: String)
    func tvShowsCollectionView(goToViewController vc: UIViewController)
}


final class TVShowsCollectionView: UICollectionView {
    
    // MARK: - Variables
    weak var tvDelegate: TVShowsCollectionViewDelegate?
    private let viewModel = CatalogeViewModel(showType: .tv)
    
    
    // MARK: - LifeCycle
    init() {
        // Layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        // Registeration & Resources
        register(ShowCollectionViewCell.nib(), forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyFooter")
        delegate = self
        dataSource = self
        
        // Appearance & Interaction
        keyboardDismissMode = .onDrag
        
        // ViewModel
        viewModel.delegate = self
        viewModel.reloadCollectionView = { [weak self] in
            self?.reloadData()
        }
        
        viewModel.insertToCollectionView = { [weak self] indexPaths in
            self?.performBatchUpdates({
                self?.insertItems(at: indexPaths)
            })
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Handle Buttons Action
    public func filterButtonPressed() {
        if viewModel.isSearching {
            tvDelegate?.tvShowsCollectionView(showAlertWith: "Filter", message: "Can not filter while searching.")
            return
        }
        
        let filterVC = FilterViewController.storyboardInstance(with: viewModel.currentFilter, delegate: self)
        tvDelegate?.tvShowsCollectionView(goToViewController: filterVC)
    }
}



// MARK: - DataSource
extension TVShowsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCollectionViewCell.identifier, for: indexPath) as! ShowCollectionViewCell
        
        let (cellID, title, genre) = viewModel.dataForItem(at: indexPath)
        cell.setData(cellID: cellID, title: title, genre: genre)
        
        viewModel.getPosterImage(forItemAt: indexPath) { posterImage in
            // Check if the current cell is the correct cell
            if cell.representedIdentifier != cellID { return }
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
        view.addSubview(loadingIndicator)
        return view
    }
}




// MARK: - Delegate
extension TVShowsCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = viewModel.showId(at: indexPath)
        let detailsVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: .tv)
        tvDelegate?.tvShowsCollectionView(goToViewController: detailsVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        // Paging
        if elementKind == UICollectionView.elementKindSectionFooter {
            viewModel.collectionViewFooterAppears()
        }
    }
}




// MARK: - FlowLayout
extension TVShowsCollectionView: UICollectionViewDelegateFlowLayout {
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




// MARK: - UISearchBar Delegate
extension TVShowsCollectionView: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        viewModel.startSearching()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searching(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        searchBar.text = nil
        viewModel.endSearching()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}




// MARK: - ViewModel
extension TVShowsCollectionView: CatalogeViewModelDelegate {
    func catalogeViewModel(didReceiveError title: String, message: String) {
        tvDelegate?.tvShowsCollectionView(showAlertWith: title, message: message)
    }
}




// MARK: - FilterViewControllerDelegate
extension TVShowsCollectionView: FilterViewControllerDelegate {
    func filterViewController(didSelectFilter filter: Filter?) {
        viewModel.applyFilter(with: filter)
    }
}
