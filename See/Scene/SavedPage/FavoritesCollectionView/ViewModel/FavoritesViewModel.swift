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
    
    // MARK: - UI Update
    var reloadeCollectionView: (() -> Void)?
    var isNoLoginLabelHidden: ((Bool) -> Void)?
    
    
    
    // MARK: - Variables
    weak var delegate: FavoritesViewModelDelegate?
    private let tmdbUserService = TMDBUserService()
    private let tmdbImageService = TMDBImageService()
    private var favorites: [Show] = []
    
    public var numberOfItems: Int {
        favorites.count
    }
    
    init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(userDidLoggedIn),
                                       name: Notification.Name(User.loginNotificationKey),
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(userDidLoggedOut),
                                       name: Notification.Name(User.logoutNotificationKey),
                                       object: nil)
    }
    
    public func viewDidLoad() {
        fetchFavorites()
    }
    
    
    public func dataForItem(at indexPath: IndexPath) -> (cellID: String, title: String, genre: String) {
        let favorite = favorites[indexPath.row]
        return (favorite.identifier, favorite.safeTitle, favorite.genreString)
    }
    
    public func getPosterImageForItem(at indexPath: IndexPath, compeletion: @escaping (String, UIImage?)->Void) {
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
    
    public func didSelectItem(at indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let type: ShowType = (favorite.title != nil) ? .movie : .tv
        let detailsVC = DetailsOfTheShowViewController.storyboardInstance(showID: favorite.id, andType: type)
        delegate?.favoritesViewModel(goToViewController: detailsVC)
    }
    
    
    public func fetchFavorites() {
        guard User.shared.isLoggedIn else { return }
        
        isNoLoginLabelHidden?(true)
        
        Task {
            do {
                let account = try await tmdbUserService.getAccountInfo(withUserSessionID: User.shared.sessionID)
                async let favoriteMovies = tmdbUserService.getFavorite(.movie, forUserSessionID: User.shared.sessionID, accountID: account.id)
                async let favoriteTVShows = tmdbUserService.getFavorite(.tv, forUserSessionID: User.shared.sessionID, accountID: account.id)
                let result = try await (favoriteMovies + favoriteTVShows)
                self.favorites = result
                
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
