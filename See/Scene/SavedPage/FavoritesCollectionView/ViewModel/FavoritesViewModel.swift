//
//  FavoritesViewModel.swift
//  See
//
//  Created by Khater on 4/24/23.
//

import Foundation
import UIKit


protocol FavoritesViewModelDelegate: AnyObject {
    func favoritesViewModel(errorTitle title: String?, message: String)
    func favoritesViewModel(goToViewController vc: UIViewController)
}


class FavoritesViewModel {
    
    // MARK: - Variables
    weak var delegate: FavoritesViewModelDelegate?
    private let tmdbUserService = TMDBUserService()
    private let tmdbImageService = TMDBImageService()
    private var favorites: [Show] = []
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
        
        fetchFavorites()
    }
    
    
    
    public func getFavoritesCount() -> Int {
        return favorites.count
    }
    
    public func getFavoriteShowData(at indexPath: IndexPath) -> (cellID: String, title: String, genre: String) {
        let favorite = favorites[indexPath.row]
        return (favorite.identifier, favorite.safeTitle, favorite.genreString)
    }
    
    public func getFavoriteShowPosterImage(at indexPath: IndexPath, compeletion: @escaping (String, UIImage?)->Void) {
        let identifier = favorites[indexPath.row].identifier
        guard let posterImagePath = favorites[indexPath.row].posterPath else {
            compeletion(identifier, Constant.defualtImage)
            return
        }
        
        Task {
            let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: false)
            DispatchQueue.main.async {
                compeletion(identifier, posterImage)
            }
        }
    }
    
    public func didSelectFavoriteShow(at indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let type: ShowType = (favorite.title != nil) ? .movie : .tv
        let detailsVC = DetailsOfTheShowViewController.storyboardInstance(showID: favorite.id, andType: type)
        delegate?.favoritesViewModel(goToViewController: detailsVC)
    }
    
    
    public func fetchFavorites() {
        guard User.shared.isLogin(), let sessionID = User.shared.getSessionID() else { return }
        
        isNoLoginLabelHidden?(true)
        
        Task {
            do {
                let account = try await tmdbUserService.getAccountInfo(withUserSessionID: sessionID)
                async let favoriteMovies = tmdbUserService.getFavorite(.movie, sessionID: sessionID, accountID: account.id)
                async let favoriteTVShows = tmdbUserService.getFavorite(.tv, sessionID: sessionID, accountID: account.id)
                let result = try await (favoriteMovies, favoriteTVShows)
                favorites = result.0 + result.1
                
                DispatchQueue.main.async {
                    self.reloadeCollectionView?()
                }
                
            } catch {
                delegate?.favoritesViewModel(errorTitle: "Favorites", message: error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - Notification Center Observer
    @objc private func userDidLoggedIn() {
        isNoLoginLabelHidden?(false)
        fetchFavorites()
    }
    
    @objc private func userDidLoggedOut() {
        favorites = []

        DispatchQueue.main.async {
            self.isNoLoginLabelHidden?(false)
            self.reloadeCollectionView?()
        }
    }
}
