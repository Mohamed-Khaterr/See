//
//  WatchlistViewModel.swift
//  See
//
//  Created by Khater on 4/24/23.
//

import Foundation
import UIKit

protocol WatchlistViewModelDelegate: AnyObject {
    func watchlistViewModel(errorTitle: String?, message: String)
    func watchlistViewModel(goToViewController vc: UIViewController)
}

class WatchlistViewModel {
    
    // MARK: - Variables
    weak var delegate: WatchlistViewModelDelegate?
    private let tmdbImageService = TMDBImageService()
    private let tmdbUserServcie = TMDBUserService()
    private var watchlist: [Show] = []
    var reloadeCollectionView: (() -> Void)?
    var isNoLoginLabelHidden: ((Bool) -> Void)?
    private let notificationCenter = NotificationCenter.default
    
    
    public func viewDidLoad() {
        notificationCenter.addObserver(self,
                                       selector: #selector(userDidLoggedIn),
                                       name: Notification.Name(User.loginNotificationKey),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(userDidLoggedOut),
                                       name: Notification.Name(User.logoutNotificationKey),
                                       object: nil)
        
        fetchWatchlist()
    }
    
    
    public func getWatchlistCount() -> Int {
        return watchlist.count
    }
    
    public func getWatchlistShow(at indexPath: IndexPath) -> (cellID: String, title: String, genre: String) {
        let watchlistShow = watchlist[indexPath.row]
        return (watchlistShow.identifier, watchlistShow.safeTitle, watchlistShow.genreString)
    }
    
    
    public func didSelectWatchlistShow(at indexPath: IndexPath) {
        let watchlistShow = watchlist[indexPath.row]
        let type: ShowType = (watchlistShow.title != nil) ? .movie : .tv
        let detailsVC = DetailsOfTheShowViewController.storyboardInstance(showID: watchlistShow.id, andType: type)
        delegate?.watchlistViewModel(goToViewController: detailsVC)
    }
    
    
    public func getWatchlistShowPosterImage(at indexPath: IndexPath, completion: @escaping (String, UIImage?) -> Void) {
        let watchlistShow = watchlist[indexPath.row]
        guard let posterImagePath = watchlistShow.posterPath else {
            completion(watchlistShow.identifier, Constant.defualtImage)
            return
        }
        
        Task {
            let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
            
            DispatchQueue.main.async {
                completion(watchlistShow.identifier, posterImage)
            }
        }
    }
    
    public func fetchWatchlist() {
        guard User.shared.isLogin(), let sessionID = User.shared.getSessionID() else { return }
        isNoLoginLabelHidden?(true)
        
        Task {
            do {
                let account = try await tmdbUserServcie.getAccountInfo(withUserSessionID: sessionID)
                
                async let watchlistMovies = tmdbUserServcie.getWatchlist(.movie, sessionID: sessionID, accountID: account.id)
                async let watchlistTVShows = tmdbUserServcie.getWatchlist(.tv, sessionID: sessionID, accountID: account.id)
                
                let result = try await (watchlistMovies, watchlistTVShows)
                self.watchlist = result.0 + result.1
                
                DispatchQueue.main.async {
                    self.reloadeCollectionView?()
                }
                
            } catch {
                delegate?.watchlistViewModel(errorTitle: "Watchlist", message: error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Notification Center Observer
    @objc private func userDidLoggedIn() {
        isNoLoginLabelHidden?(true)
        fetchWatchlist()
    }
    
    @objc private func userDidLoggedOut() {
        watchlist = []

        DispatchQueue.main.async {
            self.isNoLoginLabelHidden?(false)
            self.reloadeCollectionView?()
        }
    }
}
