//
//  FilterViewController.swift
//  See
//
//  Created by Khater on 3/31/23.
//

import UIKit


typealias TableViewSection = UITableViewDelegate & UITableViewDataSource



protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(didSelectFilter filter: Filter?)
}


class FilterViewController: UIViewController {
    
    // MARK: - Storyboard  Refernce
    static func storyboardInstance(with filter: Filter?) -> FilterViewController {
        let restorationID = "FilterStoryboard"
        let storyboard = UIStoryboard(name: restorationID, bundle: nil).instantiateViewController(withIdentifier: restorationID) as! FilterViewController
        if let filter = filter {
            storyboard.filter = filter
        }
        return storyboard
    }

    
    // MARK: - UI Components
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Variables
    public weak var delegate: FilterViewControllerDelegate?
    private var filter: Filter?
    private var sections: [TableViewSection] = []
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewSections()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    deinit {
        print("FilterViewController deinit")
    }
    
    
    // MARK: - IB Buttons Actions
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        delegate?.filterViewController(didSelectFilter: filter)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        filter = nil
        setupTableViewSections()
        tableView.reloadData()
    }
    
    
    // MARK: - Functions
    private func setupTableView() {
        tableView.register(SortingTableViewCell.nib(), forCellReuseIdentifier: SortingTableViewCell.identifiter)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupTableViewSections() {
        let sortingSection = SortingSection(sortBy: filter?.sort)
        let genreSection = GenreSection(selectedGenresID: filter?.genresID ?? [])
        let ratingSection = RatingSection(selectedRate: filter?.rate)
        let releaseYearSection = ReleaseYearSection(selectedReleaseYear: filter?.releaseYear)
        
        sortingSection.delegate = self
        genreSection.delegate = self
        ratingSection.delegate = self
        releaseYearSection.delegate = self
        
        sections = [sortingSection, genreSection, ratingSection, releaseYearSection]
    }
    
    private func setFilterObject() {
        guard filter == nil else { return }
        filter = Filter()
    }
}




// MARK: - UITableView
extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].tableView?(tableView, titleForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }
    
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].tableView?(tableView, heightForRowAt: indexPath) ?? 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].tableView?(tableView, didSelectRowAt: indexPath)
    }
}



// MARK: - SortingSection Delegate
extension FilterViewController: SortingSectionDelegate {
    func sortingSection(sortBy sort: TMDB.Sort?) {
        setFilterObject()
        filter?.sort = sort
    }
}



// MARK: - GenreSectionDelegate
extension FilterViewController: GenreSectionDelegate {
    func genreSection(goToGenreVC genreVC: GenreTableViewController) {
        navigationController?.pushViewController(genreVC, animated: true)
    }
    
    func genreSection(didSelectGenres genresIDs: [Int]) {
        setFilterObject()
        filter?.genresID = genresIDs
    }
}



// MARK: - RatingSection Delegate
extension FilterViewController: RatingSectionDelegate {
    func ratingSection(didSelectRate rate: Double?) {
        setFilterObject()
        filter?.rate = rate
    }
}



// MARK: - ReleaseYearSection Delegate
extension FilterViewController: ReleaseYearSectionDelegate {
    func releaseYearSection(didSelectYear year: Int?) {
        setFilterObject()
        filter?.releaseYear = year
    }
}
