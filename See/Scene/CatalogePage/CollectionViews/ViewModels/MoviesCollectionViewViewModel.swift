//
//  MoviesCollectionViewViewModel.swift
//  See
//
//  Created by Khater on 3/30/23.
//

import Foundation
import UIKit


protocol MoviesCollectionViewViewModelDelegat: AnyObject {
    func moviesCollectionViewViewModel(didReceiveError title: String, message: String)
    func moviesCollectionViewViewModel(shouldReloadData success: Bool)
}


final class MoviesCollectionViewViewModel {
    
    
    // MARK: - Variable
    public weak var delegate: MoviesCollectionViewViewModelDelegat?
    private let tmdbService = TMDBService()
    private let tmdbImageService = TMDBImageService()
    private var movies: [Show] = []
    private var currentPage: Int = 0
    private var searchStatus: SearchStatus?
    private var filter: Filter?
    private var isFilterApplied = false
    
    // MARK: - Getter
    public func moviesCount() -> Int {
        return movies.count
    }
    
    public func getMovieData(at index: Int) -> Show {
        return movies[index]
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
        fetchMovies()
    }
    
    
    private func fetchMovies() {
        Task {
            do {
                let movies = try await tmdbService.getDiscover(.movie, page: currentPage)
                self.movies += movies
                
                DispatchQueue.main.async {
                    self.delegate?.moviesCollectionViewViewModel(shouldReloadData: true)
                }
                
            } catch {
                delegate?.moviesCollectionViewViewModel(didReceiveError: "Movies", message: error.localizedDescription)
            }
        }
    }
    
    
    public func getPosterImage(forMovieAt index: Int, completionHandler: @escaping (UIImage?) -> Void) {
        // Check if Movie has poster path
        guard let posterImagePath = movies[index].posterPath else {
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
    
    
    public func search(for title: String) {
        guard let searchStatus = searchStatus else {
            // Search Did Begin
            self.searchStatus = SearchStatus(temp: movies)
            movies = []
            search(for: title)
            return
        }
        
        
        if title.isEmpty {
            // Search Did End
            movies = searchStatus.temp
            self.searchStatus = nil
            DispatchQueue.main.async {
                self.delegate?.moviesCollectionViewViewModel(shouldReloadData: true)
            }
            return
        } else {
            self.searchStatus!.lastSearchText = title
        }
        
        
        // Cancel old request that is not needed any more
        searchStatus.taskRequest?.cancel()
        
        // Fetching Search Results
        self.searchStatus?.taskRequest = Task {
            do {
                let result = try await tmdbService.search(title, in: .movie, page: searchStatus.currentPage)
                
                // if user scroll to bottom then the currentPage will change for example the user go to currentPage = 3
                // then the user return to search then it will fetch page 3 instad of page 1 of the search result
                // this if statment prevent that from happning
                if result.isEmpty {
                    self.searchStatus?.currentPage = 1
                    return
                }
                
                
                searchStatus.isFirstSearch ? (movies = result) : (movies += result)
                
                DispatchQueue.main.async {
                    self.delegate?.moviesCollectionViewViewModel(shouldReloadData: true)
                }
                
            } catch {
                delegate?.moviesCollectionViewViewModel(didReceiveError: "Movie Search", message: error.localizedDescription)
            }
        }
    }
    
    
    public func applyFilter(with filter: Filter?) {
        self.filter = filter
        guard let filter = filter else {
            
            if isFilterApplied {
                isFilterApplied = false
                movies = []
                fetchMovies()
            }
            
            return
        }
        
        isFilterApplied = true
        
        Task {
            let result = try await tmdbService.getDiscover(.movie,
                                                           page: 1,
                                                           sortBy: filter.sort,
                                                           year: filter.releaseYear,
                                                           genreIDs: filter.genresID,
                                                           rating: filter.rate)
            
            self.movies = result
            
            DispatchQueue.main.async {
                self.delegate?.moviesCollectionViewViewModel(shouldReloadData: true)
            }
        }
    }
}
