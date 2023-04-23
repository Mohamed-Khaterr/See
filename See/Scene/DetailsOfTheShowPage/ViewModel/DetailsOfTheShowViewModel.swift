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
    func detailsOfTheShowViewModel(updateAccountStatus status: Status)
    func detailsOfTheShowViewModel(UpdateDetailsOfTheShow details: Details)
    func detailsOfTheShowViewModel(UpdateBackdrop image: UIImage?)
    func detailsOfTheShowViewModel(UpdateTrailerWebViewWith request: URLRequest?)
    func detailsOfTheShowViewModel(updateCastSectionWith cast: [Cast])
    func detailsOfTheShowViewModel(updateSimilarShowsSectionWith shows: [Show])
    func detailsOfTheShowViewModel(goTo detailsVC: DetailsOfTheShowViewController)
    func detailsOfTheShowViewModel(shareButtonPressed shareSheetVC: UIActivityViewController)
}


final class DetailsOfTheShowViewModel {
    
    // MARK: - Variables
    public weak var delegate: DetailsOfTheShowViewModelDelegate?
    private let tmdbService = TMDBService()
    private let tmdbImageService = TMDBImageService()
    private let tmdbUserService = TMDBUserService()
    private var showID: Int?
    private var showType: ShowType?
    private var details: Details?
    private var status: Status?
    public var hideEpisodeSeasonsLabel: ((Bool) -> Void)?
    
    
    // MARK: - LifeCycle
    init(showID: Int, showType: ShowType) {
        self.showID = showID
        self.showType = showType
    }
    
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
        guard
            let details = details,
            let type = showType
        else { return }
        
        let showTitle = details.safeTitle.lowercased()
        let id = details.id
        
        // Remove Special Characters From ShowName
        let titlWithoutSpecialCahracters = showTitle.replacingOccurrences(of: "[^A-Za-z0-9]", with: "-", options: .regularExpression, range: nil)
        let showURL = URL(string: "https://www.themoviedb.org/\(type)/\(id)-\(titlWithoutSpecialCahracters)")!
        let shareSheetVC = UIActivityViewController(activityItems: [showURL], applicationActivities: nil)
        delegate?.detailsOfTheShowViewModel(shareButtonPressed: shareSheetVC)
    }
    
    
    public func watchlistButtonPressed() {
        guard User.shared.isLogin() else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Favorte", message: "You need to login to add this \(showType!.rawValue) to your favorites")
            return
        }
        
        guard let id = showID,
              let type = showType,
              let status = status
        else { return }
        
        Task {
            do {
                let _ = try await tmdbUserService.markAsWatchlist(!status.watchlist, type: type, id: id)
                await fetchAccountStatus()
                DispatchQueue.main.async {
                    let message = !status.watchlist ? "added successfuly to Watchlist" : "removed from watchlist successfully"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(type.rawValue) is \(message)")
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Watchlist", message: error.localizedDescription)
            }
        }
    }
    
    
    public func favoriteButtonPressed() {
        guard User.shared.isLogin() else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Favorte", message: "You need to login to add this \(showType!.rawValue) to your favorites")
            return
        }
        
        guard let id = showID,
              let type = showType,
              let status = status
        else { return }
        
        Task {
            do {
                let _ = try await tmdbUserService.markAsFavorites(!status.favorite, type: type, id: id)
                await fetchAccountStatus()
                DispatchQueue.main.async {
                    let message = !status.favorite ? "added to" : "removed from"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(type.rawValue) is \(message) Favorites successfully")
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Favorite", message: error.localizedDescription)
            }
        }
    }
    
    
    public func rateButtonPressed() {
        guard User.shared.isLogin() else {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Rate", message: "You need to login to add your rate to this \(showType!.rawValue)")
            return
        }
        
        guard let id = showID,
              let type = showType,
              let status = status
        else { return }
        
        Task {
            do {
                let _  = try await tmdbUserService.rate(type, id: id, isRating: !status.rated)
                await fetchAccountStatus()
                DispatchQueue.main.async {
                    let message = !status.rated ? "rated" : "unrated"
                    self.delegate?.detailsOfTheShowViewModel(showSuccessMessage: "The \(type.rawValue) is \(message) successfully")
                }
                
            } catch {
                delegate?.detailsOfTheShowViewModel(showErrorMessage: "Rate", message: error.localizedDescription)
            }
        }
    }
    
    
    
    
    
    // MARK: - Fetching Data
    private func fetchAccountStatus() async {
        guard let id = showID,
              let type = showType,
              User.shared.isLogin()
        else { return }
        
        do {
            let status = try await tmdbUserService.getStatus(type, id: id)
            self.status = status
            
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(updateAccountStatus: status)
            }
            
        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Status", message: error.localizedDescription)
        }
    }
    
    private func fetchDetails() async {
        guard
            let id = showID,
            let type = showType
        else { return }
        do {
            let details = try await tmdbService.getDetailsOfTheShow(id: id, type: type)
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
        guard
            let id = showID,
            let type = showType
        else { return }
        
        do {
            let videos = try await tmdbService.getTrailerVideoPaths(forID: id, andType: type)
            
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
        guard
            let id = showID,
            let type = showType
        else { return }
        
        do {
            let cast = try await tmdbService.getCast(forShowID: id, type: type)
            
            DispatchQueue.main.async {
                self.delegate?.detailsOfTheShowViewModel(updateCastSectionWith: cast)
            }
            
        } catch {
            delegate?.detailsOfTheShowViewModel(showErrorMessage: "Cast", message: error.localizedDescription)
        }
    }
    
    
    private func fetchSimilarShow() async {
        guard
            let id = showID,
            let type = showType
        else { return }
        
        do {
            let similarShows = try await tmdbService.getSimilarShows(forID: id, type: type)
            
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
        guard let type = showType else { return }
        let id = show.id
        let newDetailsOfTheShowVC = DetailsOfTheShowViewController.storyboardInstance(showID: id, andType: type)
        delegate?.detailsOfTheShowViewModel(goTo: newDetailsOfTheShowVC)
    }
}
