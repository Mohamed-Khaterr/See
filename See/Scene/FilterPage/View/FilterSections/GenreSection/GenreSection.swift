//
//  GenreSection.swift
//  See
//
//  Created by Khater on 3/31/23.
//

import UIKit

protocol GenreSectionDelegate: AnyObject {
    func genreSection(goToGenreVC genreVC: GenreTableViewController)
    func genreSection(didSelectGenres genresIDs: [Int])
}


class GenreSection: NSObject, TableViewSection {
    
    
    // MARK: - Variables
    public weak var delegate: GenreSectionDelegate?
    private var selectedGenresID: [Int] = []
    private var selectedGenresString: String = "All"
    
    
    // MARK: - Life Cycel
    init(selectedGenresID: [Int]?){
        super.init()
        guard let selectedGenresID = selectedGenresID else { return }
        self.selectedGenresID = selectedGenresID
        updateSelectedGenreString()
    }
    
    
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Genre"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = selectedGenresString
        return cell
    }
    
    
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genreVC = GenreTableViewController(genreIDs: selectedGenresID)
        genreVC.delegate = self
        delegate?.genreSection(goToGenreVC: genreVC)
    }
    
    
    
    // MARK: - Functions
    private func updateSelectedGenreString() {
        if selectedGenresID.isEmpty {
            selectedGenresString = "All"
            return
        } else {
            let genresStringArray = TMDB.genres.filter({ tmdbGenre in selectedGenresID.contains(tmdbGenre.id) }).compactMap({$0.name})
            selectedGenresString = genresStringArray.joined(separator: ", ")
        }
    }
}





// MARK: - GenreTableViewContorller Delegate
extension GenreSection: GenreTableViewControllerDelegate {
    func genreTableViewController(didSelectGenres id: [Int]) {
        selectedGenresID = id
        updateSelectedGenreString()
        delegate?.genreSection(didSelectGenres: selectedGenresID)
    }
}
