//
//  SearchStatus.swift
//  See
//
//  Created by Khater on 3/30/23.
//

import Foundation


struct SearchStatus {
    let temp: [Show]
    var taskRequest: Task<(), Never>?
    var lastSearchText: String = ""
    var currentPage = 1
    var isFirstSearch: Bool {
        return currentPage <= 1
    }
}
