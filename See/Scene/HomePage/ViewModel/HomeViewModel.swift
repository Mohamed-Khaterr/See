//
//  HomeViewModel.swift
//  See
//
//  Created by Khater on 3/26/23.
//

import Foundation


protocol HomeViewModelDelegate: AnyObject {
    func homeViewModel(didReceiveError title: String, message: String)
    func homeViewModel(UpdateTrendingSection shows: [Show])
    func homeViewModel(updateDicoverSection movies: [Show])
}

final class HomeViewModel {
    
    // MARK: - Variables
    public weak var delegate: HomeViewModelDelegate?
    private let tmdbService = TMDBService()
    
    
    
    // MARK: - LifeCycle
    public func viewDidLoad() {
        Task {
            // Parallel Requests
            await withTaskGroup(of: Void.self, body: { [weak self] group in
                guard let self = self else { return }
                group.addTask { await self.fetchTrendingShows() }
                group.addTask { await self.fetchDiscoverMovies() }
            })
        }
    }
    
    
    
    // MARK: - Fetching Data Functions
    private func fetchTrendingShows() async {
        do {
            let shows = try await tmdbService.getTrending([.movie, .tv], timeIn: .day)
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.homeViewModel(UpdateTrendingSection: shows)
            }
            
        } catch {
            delegate?.homeViewModel(didReceiveError: "Trending", message: error.localizedDescription)
        }
    }
    

    private func fetchDiscoverMovies() async {
        do {
            let movies = try await tmdbService.getDiscover(.movie, sortBy: .revenueDesc, year: Constant.currentYear)

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.homeViewModel(updateDicoverSection: movies)
            }
            
        } catch {
            delegate?.homeViewModel(didReceiveError: "Discover Movies", message: error.localizedDescription)
        }
    }
}
