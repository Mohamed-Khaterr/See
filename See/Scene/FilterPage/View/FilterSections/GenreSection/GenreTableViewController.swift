//
//  GenreTableViewController.swift
//  See
//
//  Created by Khater on 4/4/23.
//

import UIKit


protocol GenreTableViewControllerDelegate: AnyObject {
    func genreTableViewController(didSelectGenres id: [Int])
}


class GenreTableViewController: UITableViewController {
    
    private struct Genre {
        let id: Int
        let value: String
        var isSelected: Bool
    }
    
    
    // MARK: - Variables
    public weak var delegate: GenreTableViewControllerDelegate?
    private var genres: [Genre] = []
    
    
    
    // MARK: - init
    init(genreIDs: [Int]) {
        super.init(nibName: nil, bundle: nil)
        
        for tmdbGenre in TMDB.genres {
            if genreIDs.contains(tmdbGenre.id) {
                genres.append(Genre(id: tmdbGenre.id, value: tmdbGenre.name, isSelected: true))
            } else {
                genres.append(Genre(id: tmdbGenre.id, value: tmdbGenre.name, isSelected: false))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("GenreTableViewController deinit")
    }
    
    
    
    // MARK: - Life Cycel
    override func viewDidLoad() {
        super.viewDidLoad()
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonPressed))
        navigationItem.rightBarButtonItem = resetButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    
    
    // MARK: - Buttons Actions
    @objc private func resetButtonPressed() {
        for i in genres.indices where genres[i].isSelected {
            genres[i].isSelected = false
        }
        delegate?.genreTableViewController(didSelectGenres: [])
        tableView.reloadData()
    }
    
    
    

    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let genre = genres[indexPath.row]
        let cell = UITableViewCell()
        cell.tintColor = .label
        cell.textLabel?.text = genre.value
        cell.accessoryType = genre.isSelected ? .checkmark : .none
        return cell
    }
    
    
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        genres[indexPath.row].isSelected = !genres[indexPath.row].isSelected
        let animation: UITableView.RowAnimation = (genres[indexPath.row].isSelected) ? .top : .bottom
        tableView.reloadRows(at: [indexPath], with: animation)
        
        // Send Selected Genre ID
        let selectedGenresIDs = genres.filter( {$0.isSelected} ).compactMap( { $0.id } )
        delegate?.genreTableViewController(didSelectGenres: selectedGenresIDs)
    }
}
