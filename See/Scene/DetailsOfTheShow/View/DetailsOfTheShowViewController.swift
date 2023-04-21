//
//  DetailsOfTheShowViewController.swift
//  See
//
//  Created by Khater on 3/21/23.
//

import UIKit
import WebKit



// MARK: - UPDATE* Make it UITableView with Sections each Section is Responseble for its netwrok
class DetailsOfTheShowViewController: UIViewController {
    
    // MARK: - Storyboard  Refernce
    static func storyboardInstance(showID id: Int, andType type: ShowType) -> DetailsOfTheShowViewController {
        let restorationID = "DetailsOfTheShow"
        let storyboard = UIStoryboard(name: restorationID, bundle: nil).instantiateViewController(withIdentifier: restorationID) as! DetailsOfTheShowViewController
        storyboard.viewModel = DetailsOfTheShowViewModel(showID: id, showType: type)
        return storyboard
    }
    
    
    // MARK: - UI Components
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var episodeSeasonsLabel: UILabel!
    @IBOutlet weak var trailerWebView: WKWebView!
    @IBOutlet weak var trailerLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateCountLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var popularityLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(CastCollectionViewCell.nib(), forCellWithReuseIdentifier: CastCollectionViewCell.identifier)
            collectionView.register(ShowCollectionViewCell.nib(), forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
            collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: HeaderCollectionReusableView.kind, withReuseIdentifier: HeaderCollectionReusableView.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isScrollEnabled = false
            
            collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] index, layoutEnvironment in
                return self?.sections[index].sectionLayout()
            }
        }
    }
    
    
    
    // MARK: - Variables
    private var viewModel: DetailsOfTheShowViewModel?
    private var sections: [CollectionViewSection] = []
    private let castSection = CastSection()
    private let similarShowsSection = SimilarShowsSection()
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupCollectionViewSections()
        setupViewModel()
    }
    
    
    
    // MARK: - Functions
    private func setupUI() {
        backdropImageView.addGradientLayer(withHeightRatio: 0.3)
        trailerWebView.layer.cornerRadius = 20
        trailerWebView.layer.borderWidth = 1
        trailerWebView.layer.borderColor = UIColor.label.cgColor
        trailerWebView.scrollView.isScrollEnabled = false
        trailerWebView.navigationDelegate = self
    }
    
    private func setupNavigationBar() {
        let shareButton = UIBarButtonItem(image: Constant.shareImage, style: .done, target: self, action: #selector(shareButtonPressed))
        shareButton.tintColor = .label
        navigationItem.rightBarButtonItem = shareButton
    }
    
    private func setupCollectionViewSections() {
        castSection.delegate = viewModel
        similarShowsSection.delegate = viewModel
        sections = [castSection, similarShowsSection]
        collectionView.reloadData()
    }
    
    private func setupViewModel() {
        viewModel?.hideEpisodeSeasonsLabel = { [weak self] isHidden in
            self?.episodeSeasonsLabel.isHidden = isHidden
        }
        
        viewModel?.delegate = self
        viewModel?.viewDidLoad()
    }
    
    
    
    
    // MARK: - IB Buttons Actions
    @IBAction func watchlistButtonPressed(_ sender: UIButton) {
        viewModel?.watchlistButtonPressed()
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        viewModel?.favoriteButtonPressed()
    }
    
    @IBAction func RateButtonPressed(_ sender: UIButton) {
        viewModel?.rateButtonPressed()
    }
    
    @objc private func shareButtonPressed() {
        viewModel?.shareButtonPressed()
    }
}



// MARK: - UICollectionView
extension DetailsOfTheShowViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sections[indexPath.section].collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    // MARK: Delegate
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return sections[indexPath.section].collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ?? UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sections[indexPath.section].collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}



// MARK: - WKNavigationDelegate
extension DetailsOfTheShowViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        trailerLoadingIndicator.stopAnimating()
    }
}




// MARK: - ViewModel Delegate
extension DetailsOfTheShowViewController: DetailsOfTheShowViewModelDelegate {
    func detailsOfTheShowViewModel(showErrorMessage title: String, message: String) {
        Alert.show(to: self, title: title, message: message, compeltionHandler: nil)
    }
    
    func detailsOfTheShowViewModel(showSuccessMessage message: String) {
        Alert.successMessage(to: self, message: message)
    }
    
    func detailsOfTheShowViewModel(updateAccountStatus status: Status) {
        let watchlistButtonImage = status.watchlist ? Constant.bookmarkFillImage : Constant.bookmarkImage
        watchlistButton.setImage(watchlistButtonImage, for: .normal)
        
        let favoriteButtonImage = status.favorite ? Constant.favouriteFillImage : Constant.favouriteImage
        favoriteButton.setImage(favoriteButtonImage, for: .normal)
        
        let ratedButtonText = status.rated ? "Rated" : "Rate"
        rateButton.setTitle(ratedButtonText, for: .normal)
    }
    
    func detailsOfTheShowViewModel(UpdateDetailsOfTheShow details: Details) {
        titleLabel.text = details.safeTitle
        genreLabel.text = details.genreString
        yearLabel.text = details.releaseYear
        overviewLabel.text = details.overview
        rateLabel.text = String(format: "%.1f", details.rate)
        rateCountLabel.text = "\(details.ratedCount)"
        popularityLabel.text = String(format: "%.0f", details.popularity)
        
        if !episodeSeasonsLabel.isHidden {
            var epsiodeSeasonsText = ""
            if let numOfEpisode = details.numberOfEpisodes {
                epsiodeSeasonsText = "\(numOfEpisode) Episodes"
            }
            
            if let numOfSeasons = details.numberOfSeasons {
                epsiodeSeasonsText += ", \(numOfSeasons) Seasons"
            }
            
            episodeSeasonsLabel.text = epsiodeSeasonsText
        }
    }
    
    func detailsOfTheShowViewModel(UpdateBackdrop image: UIImage?) {
        backdropLoadingIndicator.stopAnimating()
        if let image = image {
            backdropImageView.image = image
        } else {
            backdropImageView.image = Constant.defualtImage
        }
    }
    
    func detailsOfTheShowViewModel(UpdateTrailerWebViewWith request: URLRequest?) {
        if let request = request {
            trailerWebView.load(request)
            return
            
        } else {
            let imageView = UIImageView(frame: trailerWebView.bounds)
            imageView.image = Constant.defualtImage
            imageView.contentMode = .scaleAspectFill
            trailerWebView.addSubview(imageView)
            let label = UILabel(frame: trailerWebView.bounds)
            label.text = "No Official Trailer Video!"
            label.font = UIFont(name: "Inter-Regular", size: 9)
            label.textColor = .white
            label.textAlignment = .center
            trailerWebView.addSubview(label)
        }
    }
    
    func detailsOfTheShowViewModel(updateCastSectionWith cast: [Cast]) {
        castSection.setCast(with: cast)
        collectionView.reloadData()
    }
    
    func detailsOfTheShowViewModel(updateSimilarShowsSectionWith shows: [Show]) {
        similarShowsSection.updateShows(shows)
        collectionView.reloadData()
    }
    
    func detailsOfTheShowViewModel(shareButtonPressed shareSheetVC: UIActivityViewController) {
        present(shareSheetVC, animated: true, completion: nil)
    }
    
    func detailsOfTheShowViewModel(goTo detailsVC: DetailsOfTheShowViewController) {
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
