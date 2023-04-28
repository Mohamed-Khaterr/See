//
//  CollectionViewSection.swift
//  See
//
//  Created by Khater on 3/31/23.
//

import UIKit


typealias CollectionViewSection = CompositionalLayout & UICollectionViewDelegate & UICollectionViewDataSource & CollectionViewSectionConfiguration


// MARK: - CollectionViewSectionModel
protocol CollectionViewSectionConfiguration {
    var reloadData: (() -> Void)? { get set }
    var reloadItem: (([IndexPath]) -> Void)? { get set }
    
    func updateCollectionViewData(with data: Any)
}

extension CollectionViewSectionConfiguration {
    func updateCollectionViewData(with data: Any) {}
}
