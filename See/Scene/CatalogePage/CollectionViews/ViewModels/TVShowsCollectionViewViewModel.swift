//
//  TVShowsCollectionViewViewModel.swift
//  See
//
//  Created by Khater on 3/30/23.
//

import Foundation
import UIKit


protocol TVShowsCollectionViewViewModelDelegate: AnyObject {
    func tvShowsCollectionViewViewModel(shouldReloadData success: Bool)
    func tvShowsCollectionViewViewModel(didReceiveError title: String, message: String)
}


final class TVShowsCollectionViewViewModel {
    
    // MARK: - Variable
    public weak var delegate: TVShowsCollectionViewViewModelDelegate?
    private let tmdbService = TMDBService()
    private let tmdbImageService = TMDBImageService()
    private var tvShows: [Show] = []
    private var currentPage: Int = 0
    private var searchStatus: SearchStatus?
    private var filter: Filter?
    private var isFilterApplied = false
    
    
    // MARK: - Getter
    public func tvCount() -> Int {
        return tvShows.count
    }
    
    
    public func getTVShow(at index: Int) -> Show {
        return tvShows[index]
    }
    
    public func getFilter() -> Filter? {
        return filter
    }
    
    
    // MARK: - Functions
    public func collectionViewReachEnd() {
        // Search Fetching
        if searchStatus != nil {
            searchStatus!.currentPage += 1
            search(for: searchStatus!.lastSearchText)
            return
        }
        
        // Normal Fetching
        currentPage += 1
        fetchTVShows()
    }
    
    
    public func fetchTVShows() {
        Task {
            do {
                let tvShows = try await tmdbService.getDiscover(.tv, page: currentPage)
                self.tvShows += tvShows
                
                DispatchQueue.main.async {
                    self.delegate?.tvShowsCollectionViewViewModel(shouldReloadData: true)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    public func getPosterImage(forTVShowAt index: Int, completionHandler: @escaping (UIImage?) -> Void) {
        // Check if Movie has poster path
        guard let posterImagePath = tvShows[index].posterPath else {
            completionHandler(nil)
            return
        }
        
        Task {
            // Download Poster Image
            let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
            
            
            // Send Image back
            DispatchQueue.main.async {
                completionHandler(posterImage)
            }
        }
    }
    
    
    public func search(for name: String) {
        guard let searchStatus = searchStatus else {
            // Search Did Begin
            self.searchStatus = SearchStatus(temp: tvShows)
            tvShows = []
            search(for: name)
            return
        }
        
        
        if name.isEmpty {
            // Search Did End
            tvShows = searchStatus.temp
            self.searchStatus = nil
            DispatchQueue.main.async {
                self.delegate?.tvShowsCollectionViewViewModel(shouldReloadData: true)
            }
            return
        } else {
            self.searchStatus!.lastSearchText = name
        }
        
        
        // Cancel old request that is not needed any more
        searchStatus.taskRequest?.cancel()
        
        // Fetching Search Results
        self.searchStatus?.taskRequest = Task {
            do {
                let result = try await tmdbService.search(name, in: .tv, page: searchStatus.currentPage)
                
                if result.isEmpty {
                    self.searchStatus?.currentPage = 1
                    return
                }
                
                searchStatus.isFirstSearch ? (tvShows = result) : (tvShows += result)
                
                DispatchQueue.main.async {
                    self.delegate?.tvShowsCollectionViewViewModel(shouldReloadData: true)
                }
                
            } catch {
                delegate?.tvShowsCollectionViewViewModel(didReceiveError: "Movie Search", message: error.localizedDescription)
            }
        }
    }
    
    
    public func applyFilter(with filter: Filter?) {
        self.filter = filter
        guard let filter = filter else {
            
            if isFilterApplied {
                isFilterApplied = false
                tvShows = []
                fetchTVShows()
            }
            
            return
        }
        
        isFilterApplied = true
        
        Task {
            let result = try await tmdbService.getDiscover(.tv,
                                                           page: 1,
                                                           sortBy: filter.sort,
                                                           year: filter.releaseYear,
                                                           genreIDs: filter.genresID,
                                                           rating: filter.rate)
            
            self.tvShows = result
            
            DispatchQueue.main.async {
                self.delegate?.tvShowsCollectionViewViewModel(shouldReloadData: true)
            }
        }
    }
}
