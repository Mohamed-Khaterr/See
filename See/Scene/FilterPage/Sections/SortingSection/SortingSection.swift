//
//  SortingSection.swift
//  See
//
//  Created by Khater on 3/31/23.
//

import UIKit

protocol SortingSectionDelegate: AnyObject {
    func sortingSection(sortBy sort: TMDB.Sort?)
}


final class SortingSection: NSObject, TableViewSection {
    
    struct Sort {
        let title: String
        let by: TMDB.Sort
        var isSelected: Bool
    }
    
    
    // MARK: - Variables
    public weak var delegate: SortingSectionDelegate?
    private var sorts: [Sort] = [
        Sort(title: "Popularity", by: .popularityDesc, isSelected: false),
        Sort(title: "Newest", by: .releaseDateDesc, isSelected: false),
        Sort(title: "Rating", by: .voteAverageDesc, isSelected: false)
    ]
    
    
    // MARK: - Life Cycle
    init(sortBy sort: TMDB.Sort?) {
        if sort == .popularityDesc {
            sorts[0].isSelected = true
        } else if sort == .releaseDateDesc {
            sorts[1].isSelected = true
        } else if sort == .voteAverageDesc {
            sorts[2].isSelected = true
        }
    }
    
    
    
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sort By"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sorts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SortingTableViewCell.identifiter, for: indexPath) as! SortingTableViewCell
        let sort = sorts[indexPath.row]
        cell.config(sortTitle: sort.title)
        cell.checkBox(sort.isSelected)
        return cell
    }
    
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sorts[indexPath.row].isSelected = !sorts[indexPath.row].isSelected
        
        for row in 0..<sorts.count where row != indexPath.row {
            sorts[row].isSelected = false
        }
        
        if sorts[indexPath.row].isSelected {
            delegate?.sortingSection(sortBy: sorts[indexPath.row].by)
        }else {
            delegate?.sortingSection(sortBy: nil)
        }
        
        
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }
}
