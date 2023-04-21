//
//  UIPagingCollectionView.swift
//
//  Created by Khater on 3/22/23.
//

import UIKit
import OSLog


// MARK: - UIPagingCollectionView DataSource
protocol UIPagingCollectionViewDataSource: AnyObject {
    
    /// Ask your datasource object for the titles in the header
    /// - Returns: Array of titles string
    func pagingCollectionView(titleForHeaderButtons pagingCollectionView: UIPagingCollectionView) -> [String]
    
    /// Ask your datasource object for the UICollectionViews to imbed in the pagingCollectionView
    /// - Returns: UICollectionViews
    func pagingCollectionView(subCollectionViews pagingCollectionView: UIPagingCollectionView) -> [UICollectionView]
}



// MARK: - UIPagingCollectionView Delegate
protocol UIPagingCollectionViewDelegate: AnyObject {
    
    /// Tell the delegate that user scroll to index in array of UICollectionViews
    func pagingCollectionView(didScrollToCollectionViewAt index: Int)
}

extension UIPagingCollectionViewDelegate {
    func pagingCollectionView(didScrollToCollectionViewAt index: Int) {}
}



// MARK: - UIPagingCollectionView
final class UIPagingCollectionView: UICollectionView {
    
    // MARK: Variables
    private var sectionHeaderHeight: CGFloat = 55
    private var previousSelectedIndex = 0
    private weak var sectionHeader: UIPagingHeaderCollectionReusableView?
    public weak var pagingDelegate: UIPagingCollectionViewDelegate?
    public weak var pagingDataSource: UIPagingCollectionViewDataSource?
    
    
    // MARK: LifeCycle
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionViewConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewConfig()
    }
    
    
    
    // MARK: Setup UIPagingCollectionView
    private func collectionViewConfig() {
        collectionViewInteraction()
        collectionViewLayout = compositionalLayout()
        
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PagingCollectionViewCell")
        register(UIPagingHeaderCollectionReusableView.self,
                 forSupplementaryViewOfKind: UIPagingHeaderCollectionReusableView.kind,
                 withReuseIdentifier: UIPagingHeaderCollectionReusableView.identifier)
        
        dataSource = self
    }
    
    private func collectionViewInteraction() {
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    
    // MARK: Layout
    private func compositionalLayout() -> UICollectionViewCompositionalLayout {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        // SupplemntaryItem
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(sectionHeaderHeight))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
         header.pinToVisibleBounds = true
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .paging
        
        
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, point, env) -> Void in
            guard
                let self = self,
                let sectionHeader = self.sectionHeader
            else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let index = visibleItems.last?.indexPath.row else { return }
                sectionHeader.scrollToButton(at: point)
                // sectionHeader.didSelectButton(at: index)
                guard self?.previousSelectedIndex != index else { return }
                self?.previousSelectedIndex = index
                self?.pagingDelegate?.pagingCollectionView(didScrollToCollectionViewAt: index)
            }
         }
        
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    // MARK: Developer Debug & Error Handler
    private func developer(isError: Bool, message: String) {
        if #available(iOS 14.0, *) {
            let customLog = Logger(subsystem: "com.mohamedKhater.uipagingcollectionview", category: "UIPagingCollectionView")
            if isError {
                customLog.error("An error occurred!")
                customLog.error("\(message)")
            } else {
                customLog.debug("Debug!")
                customLog.debug("\(message)")
            }
            
        } else {
            let customLog = OSLog(subsystem: "com.mohamedKhater.uipagingcollectionview", category: "UIPagingCollectionView")
            if isError {
                os_log("An error occurred!", log: customLog, type: .error, message)
            } else {
                os_log("Debug!", log: customLog, type: .debug, message)
            }
        }
    }
}



// MARK: - DataSource
extension UIPagingCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UIPagingHeaderCollectionReusableView.identifier, for: indexPath) as! UIPagingHeaderCollectionReusableView
        
        guard
            let titleForHeaderButton = pagingDataSource?.pagingCollectionView(titleForHeaderButtons: self)
        else {
            return header
        }
        
        // Set Title For Button
        header.addButtonsTitle(titleForHeaderButton)
        
        // Set delegate for button action
        header.delegate = self
        
        // Set Header for Section
        sectionHeader = header
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pagingDataSource?.pagingCollectionView(subCollectionViews: self).count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagingCollectionViewCell", for: indexPath)
        
        guard
            let pagingDataSource = pagingDataSource,
            // Check if subCollectionViews count equal to headerButtonTitles count
            pagingDataSource.pagingCollectionView(subCollectionViews: self).count == pagingDataSource.pagingCollectionView(titleForHeaderButtons: self).count
        else {
            developer(isError: true, message: "Sub CollectionViews length must be equal Header Buttons Titles length")
            return cell
        }
        
        let subCollectionViews = pagingDataSource.pagingCollectionView(subCollectionViews: self)
        let subCollectionView = subCollectionViews[indexPath.row]
        
        // Set sub collectionView frame
        subCollectionView.frame = cell.bounds
        
        
        // SubCollectionView height will be greater than the Main CollectionView height (the last cell will appear half of it)
        // because i added height for section header
        // so to prevent this height issue:
        // subtract the section header height from the cell height
        subCollectionView.frame.size.height -= sectionHeaderHeight
        
        // Add Sub CollectionView to the cell
        cell.addSubview(subCollectionView)
        
        
        return cell
    }
}



// MARK: - Section Header Delegate
extension UIPagingCollectionView: UIPagingHeaderCollectionReusableViewDelegate {
    func pagingHeaderCollectionReusableView(didPressedButtonAt index: Int) {
        guard
            let subCollectionViews = pagingDataSource?.pagingCollectionView(subCollectionViews: self),
            subCollectionViews.count > index
        else {
            developer(isError: false, message: "Selected index is not found in the subCollectionViews")
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        reloadData()
    }
}
