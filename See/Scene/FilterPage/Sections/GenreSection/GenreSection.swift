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
    
    
    struct Genre {
        let id: Int
        let value: String
        var isSelected: Bool
    }
    
    
    // MARK: - Variables
    public weak var delegate: GenreSectionDelegate?
    private var genres: [Genre] = []
    
    
    // MARK: - Life Cycel
    init(selectedGenresID: [Int]){
        for genre in TMDB.genres {
            genres.append(Genre(id: genre.id, value: genre.name, isSelected: false))
        }
        
        
        guard !selectedGenresID.isEmpty else { return }
        for index in 0..<genres.count where selectedGenresID.contains(genres[index].id) {
            genres[index].isSelected = true
        }
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
        cell.textLabel?.text = getGenreString()
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genreVC = GenreTableViewController(genres: genres, tableViewThatWillReloaded: tableView)
        genreVC.delegate = self
        delegate?.genreSection(goToGenreVC: genreVC)
    }
    
    
    
    // MARK: - Functions
    private func getGenreString() -> String {
        let selectedGenres = genres.filter({ $0.isSelected })
        let genresValues = selectedGenres.compactMap({ $0.value })
        let genresValueString = genresValues.joined(separator: ", ")
        return selectedGenres.isEmpty ? "All" : genresValueString
    }
}





// MARK: - GenreTableViewContorller Delegate
extension GenreSection: GenreTableViewControllerDelegate {
    func genreTableViewController(UpdateGenres genres: [GenreSection.Genre]) {
        self.genres = genres
        let selectedGenresID = genres.filter({ $0.isSelected }).compactMap({ $0.id })
        delegate?.genreSection(didSelectGenres: selectedGenresID)
    }
}
