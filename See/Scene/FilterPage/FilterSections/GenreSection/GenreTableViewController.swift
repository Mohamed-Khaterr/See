//
//  GenreTableViewController.swift
//  See
//
//  Created by Khater on 4/4/23.
//

import UIKit



protocol GenreTableViewControllerDelegate: AnyObject {
    func genreTableViewController(UpdateGenres genres: [GenreSection.Genre])
}


class GenreTableViewController: UITableViewController {
    
    
    // MARK: - Variables
    public weak var delegate: GenreTableViewControllerDelegate?
    private var genres: [GenreSection.Genre] = []
    private let genreSectionTableView: UITableView?
    
    
    // MARK: - Life Cycel
    init(genres: [GenreSection.Genre], tableViewThatWillReloaded genreSectionTableView: UITableView) {
        self.genreSectionTableView = genreSectionTableView
        super.init(nibName: nil, bundle: nil)
        self.genres = genres
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("GenreTableViewController deinit")
    }
    
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
        delegate?.genreTableViewController(UpdateGenres: genres)
        genreSectionTableView?.reloadData()
    }
    
    
    
    // MARK: - Buttons Actions
    @objc private func resetButtonPressed() {
        for index in 0..<genres.count {
            genres[index].isSelected = false
        }
        tableView.reloadData()
    }
    
    
    

    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        
        // Change the value
        
    }
}
