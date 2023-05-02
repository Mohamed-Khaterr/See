//
//  CatalogeViewModel.swift
//  See
//
//  Created by Khater on 3/30/23.
//

import Foundation
import UIKit


protocol CatalogeViewModelDelegate: AnyObject {
    func catalogeViewModel(didReceiveError title: String, message: String)
}


final class CatalogeViewModel {
    
    
    // MARK: - UI Updates
    public var reloadCollectionView: (() -> Void)?
    public var insertToCollectionView: (([IndexPath]) -> Void)?
    
    
    // MARK: - Variable
    weak var delegate: CatalogeViewModelDelegate?
    private let showType: ShowType
    private let tmdbService = TMDBService()
    private let tmdbImageService = TMDBImageService()
    
    // Show
    private var shows: [Show] = []
    private var currentPage: Int = 0
    private var temp: (shows: [Show], page: Int)?
    
    // Search
    private var currentSearchTask: Task<(), Never>?
    private var currentSearchText: String?
    public private(set) var isSearching = false
    
    // Filter
    public private(set) var currentFilter: Filter?
    private var isFilterApplied = false
    
    
    public var numberOfItems: Int {
        shows.count
    }
    
    
    // MARK: - init
    init(showType: ShowType) {
        self.showType = showType
        currentPage += 1
        fetchShow(page: currentPage)
    }
    
    
    
    // MARK: - Functions
    public func dataForItem(at indexPath: IndexPath) -> (cellID: String, title: String, genre: String) {
        let show = shows[indexPath.row]
        return (show.identifier, show.safeTitle, show.genreString)
    }
    
    public func getPosterImage(forItemAt indexPath: IndexPath, completionHandler: @escaping (UIImage?) -> Void) {
        // Check if Show has poster path
        guard let posterImagePath = shows[indexPath.row].posterPath else {
            completionHandler(nil)
            return
        }
        
        Task {
            // Get Poster Image
            let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
            
            // Send Image back
            DispatchQueue.main.async {
                completionHandler(posterImage)
            }
        }
    }
    
    public func showId(at indexPath: IndexPath) -> Int {
        return shows[indexPath.row].id
    }
    
    
    
    public func collectionViewFooterAppears() {
        // Paging
        guard !shows.isEmpty else { return }
        
        currentPage += 1
        
        if isSearching {
            fetchSearch(for: currentSearchText ?? "", page: currentPage)
            
        }else if isFilterApplied {
            guard let filter = currentFilter else { return }
            fetchFilter(with: filter, page: currentPage)
            
        } else {
            fetchShow(page: currentPage)
        }
    }
    
    private func addTemp(_ setTemp: Bool) {
        if setTemp {
            guard temp == nil else { return }
            temp = (shows, currentPage)
            shows = []
            currentPage = 1
            
        } else {
            guard let temp = temp else { return }
            shows = temp.shows
            currentPage = temp.page
            self.temp = nil
        }
        
        reloadCollectionView?()
    }
    
    private func updateShows(with newShows: [Show]) {
        DispatchQueue.main.async {
            if self.shows.isEmpty {
                self.shows = newShows
                self.reloadCollectionView?()
                
            } else {
                let fromItemAt = self.shows.count
                let toItemAt = (self.shows.count - 1) + newShows.count
                self.shows += newShows
                let indexPaths = Array(fromItemAt...toItemAt).map({ IndexPath(item: $0, section: 0)})
                self.insertToCollectionView?(indexPaths)
            }
        }
    }
    
    
    
    // MARK: - Fetching Movies
    private func fetchShow(page: Int) {
        Task {
            do {
                let resultShows = try await tmdbService.getDiscover(showType, page: page)
                updateShows(with: resultShows)
                
            } catch {
                delegate?.catalogeViewModel(didReceiveError: "Movies", message: error.localizedDescription)
            }
        }
    }
    
    
    
    
    // MARK: - Searching
    public func startSearching() {
        isSearching = true
        addTemp(true)
    }
    
    public func searching(text: String) {
        shows = []
        currentSearchText = text
        fetchSearch(for: text, page: currentPage)
    }
    
    public func endSearching() {
        isSearching = false
        addTemp(false)
        currentSearchTask = nil
        currentSearchText = nil
    }
    
    private func fetchSearch(for text: String, page: Int) {
        // Cancel old request that is not needed any more
        currentSearchTask?.cancel()
        
        currentSearchTask = Task {
            do {
                let searchResult = try await tmdbService.search(text, in: showType, page: page)
                updateShows(with: searchResult)
                
            } catch {
                delegate?.catalogeViewModel(didReceiveError: "Movie Search", message: error.localizedDescription)
            }
        }
    }
    
    
    
    // MARK: - Filtering
    public func applyFilter(with filter: Filter?) {
        if let filter = filter {
            isFilterApplied = true
            currentFilter = filter
            addTemp(true)
            shows = []
            fetchFilter(with: filter, page: currentPage)
            
        } else {
            isFilterApplied = false
            currentFilter = nil
            addTemp(false)
        }
    }
    
    private func fetchFilter(with filter: Filter, page: Int) {
        Task {
            do {
                let filterResult = try await tmdbService.getDiscover(showType, page: page, sortBy: filter.sort, year: filter.releaseYear, genreIDs: filter.genresID, rating: filter.rate)
                updateShows(with: filterResult)
                
            } catch {
                delegate?.catalogeViewModel(didReceiveError: "Filter", message: error.localizedDescription)
            }
        }
    }
}
