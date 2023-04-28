//
//  DetailsOfTheShowViewModel.swift
//  See
//
//  Created by Khater on 3/25/23.
//

import Foundation
import UIKit



protocol DetailsOfTheShowViewModelDelegate: AnyObject {
    func detailsOfTheShowViewModel(showErrorMessage title: String, message: String)
    func detailsOfTheShowViewModel(showSuccessMessage message: String)
    func detailsOfTheShowViewModel(UpdateDetailsOfTheShow details: Details)
    func detailsOfTheShowViewModel(UpdateBackdrop image: UIImage?)
    func detailsOfTheShowViewModel(UpdateTrailerWebViewWith request: URLRequest?)
    func detailsOfTheShowViewModel(updateCastSectionWith cast: [Cast])
    func detailsOfTheShowViewModel(updateSimilarShowsSectionWith shows: [Show])
    func detailsOfTheShowViewModel(goToViewController vc: UIViewController)
    func detailsOfTheShowViewModel(shareButtonPressed shareSheetVC: UIActivityViewController)
    
    // New
    func detailsOfTheShowViewModel(accountStatesDidUpdate states: (isFavorite: Bool?, isInWatchlist: Bool?, isRated: Bool?))
}


final class DetailsOfTheShowViewModel {
    
    // MARK: - Variables
    weak var delegate: DetailsOfTheShowViewModelDelegate?
    private let tmdbService = TMDBService()
    private let tmdbImageService = TMDBImageService()
    private let tmdbUserService = TMDBUserService()
    private let showID: Int
    private let showType: ShowType
    private var details: Details?
    private var accountStates: AccountStates
    public var hideEpisodeSeasonsLabel: ((Bool) -> Void)?
    
    
    // MARK: - init
    init(showType type: ShowType, andID id: Int) {
        self.showID = id
        self.showType = type
        self.accountStates = AccountStates()
    }
    
    
    // MARK: - ViewController Life Cycle
    public func viewDidLoad() {
        let isTVShow = (showType == .tv)
        hideEpisodeSeasonsLabel?(!isTVShow)
        
        Task {
            // Parallel Requests
            await withTaskGroup(of: Void.self, body: { [weak self] group in
                guard let self = self else { return }
                group.addTask { await self.fetchAccountStatus() }
                group.addTask { await self.fetchDetails() }
                group.addTask { await self.fetchTrailerVideosPaths() }
                group.addTask { await self.fetchCast() }
                group.addTask { await self.fetchSimilarShow() }
            })
        }
    }
    
    
    // MARK: - Buttons Actions
    public func shareButtonPressed() {
        guard let details = details else { return }
        
        let showTitle = details.safeTitle.lowercased()
        
        // Remove Special Characters From ShowName
        let titlWithoutSpecialCahracters = showTitle.replacingOccurrences(of: "[^A-Za-z0-9]", with: "-", options: .regularExpression, range: nil)
        let showURL = URL(string: "https://www.themoviedb.org/\(showType.rawValue)/\(showID)-\(titlWithoutSpecialCahracters)")!
        let shareSheetVC = UIActivityViewController(activityItems: [showURL], applicationActivities: nil)
        delegate?.detailsOfTheShowViewModel(shareButtonPressed: shareSheetVC)
    }
    
    
    public func watchlistButtonPressed() {
        guard User.shared.isLoggedIn else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Login", message: "You need to login to add this \(showType.rawValue) to your favorites")
            return
        }
        
        let markAsWatchlist = !accountStates.watchlist
        
        Task {
            do {
                try await tmdbUserService.markAsWatchlist(markAsWatchlist, type: showType, id: showID, forUserSessionID: User.shared.sessionID, accountID: User.shared.accountID)
                
                DispatchQueue.main.async {
                    let message = markAsWatchlist ? "added successfuly to Watchlist" : "removed from watchlist successfully"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(self.showType.rawValue) is \(message)")
                    self.delegate?.detailsOfTheShowViewModel(accountStatesDidUpdate: (nil, markAsWatchlist, nil))
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Watchlist", message: error.localizedDescription)
            }
        }
    }
    
    
    public func favoriteButtonPressed() {
        guard User.shared.isLoggedIn else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Login", message: "You need to login to add this \(showType.rawValue) to your favorites")
            return
        }
        
        let markAsFavorite = !accountStates.favorite
        
        Task {
            do {
                try await tmdbUserService.markAsFavorites(markAsFavorite, type: showType, id: showID, forUserSessionID: User.shared.sessionID, accountID: User.shared.accountID)
                
                DispatchQueue.main.async {
                    let message = markAsFavorite ? "added to" : "removed from"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(self.showType.rawValue) is \(message) Favorites successfully")
                    self.delegate?.detailsOfTheShowViewModel(accountStatesDidUpdate: (markAsFavorite, nil, nil))
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Favorite", message: error.localizedDescription)
            }
        }
    }
    
    
    public func rateButtonPressed() {
        guard User.shared.isLoggedIn else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Login", message: "You need to login to rate this \(showType.rawValue)")
            return
        }
        
        let markAsRate = !accountStates.rated
        
        Task {
            do {
                try await tmdbService.rate(showType, id: showID, markAsRate: markAsRate, forUserSessionID: User.shared.sessionID, accountID: User.shared.accountID)
                
                DispatchQueue.main.async {
                    let message = markAsRate ? "rated" : "unrated"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(self.showType.rawValue) is \(message) successfully")
                    self.delegate?.detailsOfTheShowViewModel(accountStatesDidUpdate: (nil, nil, markAsRate))
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Rating", message: error.localizedDescription)
            }
        }
    }
    
    
    
    
    
    // MARK: - Fetching Data
    private func fetchAccountStatus() async {
        guard User.shared.isLoggedIn else { return }
        
        do {
            let states = try await tmdbService.getAccountStates(showType, id: showID, forUserSessionID: User.shared.sessionID)
            self.accountStates = states
            
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(accountStatesDidUpdate: (states.favorite, states.watchlist, states.rated))
            }

        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Account States", message: error.localizedDescription)
        }
    }
    
    private func fetchDetails() async {
        do {
            let details = try await tmdbService.getDetailsOfTheShow(id: showID, type: showType)
            self.details = details
            
            DispatchQueue.main.async {
                // Update UI with new data
                // self.updateShowDetails()
                self.delegate?.detailsOfTheShowViewModel(UpdateDetailsOfTheShow: details)
            }
            
            await getBackdropImage()
            
        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Details", message: error.localizedDescription)
        }
    }
    
    private func getBackdropImage() async {
        guard let details = details else { return }
        
        // Get Backdrop Image if exists
        if let backdropImagePath = details.backdropPath {
            let backdropImage = await tmdbImageService.getBackdropImage(withPath: backdropImagePath, inHeighQuality: true)
            
            DispatchQueue.main.async {
                // Update UI with new data
                self.delegate?.detailsOfTheShowViewModel(UpdateBackdrop: backdropImage)
            }
            
            return
        }
        
        // Get Poster Image if Backdrop Image is not exists
        if let posterImagePath = details.posterPath {
            let posterImage = await tmdbImageService.getPosterImage(withPath: posterImagePath, inHeighQulity: true)
            
            DispatchQueue.main.async {
                // Update UI with new data
                self.delegate?.detailsOfTheShowViewModel(UpdateBackdrop: posterImage)
            }
            
            return
        }
        
        // if no Poster or Backdrop Image present defualt Image
        DispatchQueue.main.async {
            // Update UI with new data
            self.delegate?.detailsOfTheShowViewModel(UpdateBackdrop: nil)
        }
    }
    
    
    private func fetchTrailerVideosPaths() async {
        do {
            let videos = try await tmdbService.getTrailerVideoPaths(forID: showID, andType: showType)
            
            // Search For Trailer
            if let video = videos.first(where: { $0.type == "Trailer" }) {
                let url: URL!
                switch video.site {
                case .youTube:
                    url = URL(string: "https://www.youtube.com/embed/\(video.key)")
                case .vimeo:
                    url = URL(string: "https://vimeo.com/\(video.key)")
                }
                
                DispatchQueue.main.async {
                    // Show Trailler
                    self.delegate?.detailsOfTheShowViewModel(UpdateTrailerWebViewWith: URLRequest(url: url))
                }
                
            } else {
                DispatchQueue.main.async {
                    // No Trailer
                    self.delegate?.detailsOfTheShowViewModel(UpdateTrailerWebViewWith: nil)
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(showErrorMessage: "Trailer Video", message: error.localizedDescription)
            }
        }
    }
    
    private func fetchCast() async {
        
        do {
            let cast = try await tmdbService.getCast(forShowID: showID, type: showType)
            
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(updateCastSectionWith: cast)
            }
            
        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Cast", message: error.localizedDescription)
        }
    }
    
    
    private func fetchSimilarShow() async {
        do {
            let similarShows = try await tmdbService.getSimilarShows(forID: showID, type: showType)
            
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(updateSimilarShowsSectionWith: similarShows)
            }
            
        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Similar Shows", message: error.localizedDescription)
        }
    }
}




// MARK: - CastSectionDelegate
extension DetailsOfTheShowViewModel: CastSectionDelegate {
    func castSection(didSelect cast: Cast) {
        print("Cast Section Delegate")
    }
}



// MARK: - SimilarShowsSectionsDelegate
extension DetailsOfTheShowViewModel: SimilarShowSectionDelegate {
    func similarShowSection(didSelectSimilar show: Show) {
        // The Type of similar show is the same as current show
        let type = showType
        let id = show.id
        let newDetailsOfTheShowVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: type)
        delegate?.detailsOfTheShowViewModel(goToViewController: newDetailsOfTheShowVC)
    }
}
