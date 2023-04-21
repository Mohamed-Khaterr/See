////
////  SavedViewController.swift
////  See
////
////  Created by Khater on 11/3/22.
////
//
//
//import UIKit
//
//
//class SavedOldViewController: UIViewController {
//    
//    @IBOutlet weak var segmentControlView: CustomSegmentControl!
//    @IBOutlet weak var pagingCollectionView: PagingCollectionView!
//    
//    private var favoriteCollectionView: UICollectionView!
//    private var  watchlistCollectionView: UICollectionView!
//    
//    private var favoriteShows: [Show] = []
//    private var watchlistShows: [Show] = []
//    
//    private let tmdbClient = TMDBClient()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCollectionViews()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if Client.shared.isLogin() {
//            removeLoginMessage()
//            setupRefreshControl()
//            if favoriteShows.isEmpty {
//                fetchingFavoriteShows(.movie)
//                fetchingFavoriteShows(.tv)
//            }
//            
//            if watchlistShows.isEmpty{
//                fetchingWatchlistShows(.movie)
//                fetchingWatchlistShows(.tv)
//            }
//        }else{
//            userNotLogingMessage()
//            favoriteShows = []
//            favoriteCollectionView.reloadData()
//            watchlistShows = []
//            watchlistCollectionView.reloadData()
//        }
//    }
//    
//    private func userNotLogingMessage(){
//        let label: UILabel = {
//            let label = UILabel()
//            label.font = UIFont(name: "Inter-Regular", size: 17)
//            label.textColor = .label
//            label.text = "You are not loged in.\nLogin to see your Favorite shows and Watch List"
//            label.textAlignment = .center
//            label.numberOfLines = 0
//            label.frame.size.width = 300
//            label.frame.size.height = 70
//            label.center = view.center
//            label.tag = 10110
//            
//            return label
//        }()
//        
//        view.addSubview(label)
//    }
//    
//    private func removeLoginMessage(){
//        view.subviews.forEach { view in
//            if view.tag == 10110{
//                view.removeFromSuperview()
//            }
//        }
//    }
//    
//    private func setupCollectionViews(){
//        setupSubCollectionViews()
//        setupMainCollectionView()
//    }
//    
//    private func setupSubCollectionViews(){
//        favoriteCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        watchlistCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        
//        favoriteCollectionView.register(SavedCollectionViewCell.nib(), forCellWithReuseIdentifier: SavedCollectionViewCell.identifier)
//        watchlistCollectionView.register(SavedCollectionViewCell.nib(), forCellWithReuseIdentifier: SavedCollectionViewCell.identifier)
//    }
//    
//    private func setupMainCollectionView(){
//        pagingCollectionView.pagingDataSource = self
//        pagingCollectionView.pagingDelegate = self
//        pagingCollectionView.addSubCollectionViews([favoriteCollectionView, watchlistCollectionView])
//        pagingCollectionView.segmentControl = segmentControlView
//    }
//    
//    private func setupRefreshControl(){
//        favoriteCollectionView.refreshControl = UIRefreshControl()
//        favoriteCollectionView.refreshControl!.addTarget(self, action: #selector(didPullToReferesh), for: .valueChanged)
//        
//        watchlistCollectionView.refreshControl = UIRefreshControl()
//        watchlistCollectionView.refreshControl!.addTarget(self, action: #selector(didPullToReferesh), for: .valueChanged)
//    }
//    
//    
//    @objc private func didPullToReferesh(){
//        favoriteShows = []
//        watchlistShows = []
//        
//        favoriteCollectionView.reloadData()
//        watchlistCollectionView.reloadData()
//        
//        fetchingFavoriteShows(.movie)
//        fetchingFavoriteShows(.tv)
//        fetchingWatchlistShows(.movie)
//        fetchingWatchlistShows(.tv)
//    }
//    
//    
//    private func fetchingFavoriteShows(_ type: ShowType){
//        self.tmdbClient.getFavoriteShows(type: type) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .failure(let error):
//                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)
//                
//            case .success(let shows):
//                self.favoriteShows += shows
//                
//                DispatchQueue.main.async {
//                    self.favoriteCollectionView.refreshControl?.endRefreshing()
//                    self.favoriteCollectionView.reloadData()
//                }
//            }
//        }
//    }
//    
//    private func fetchingWatchlistShows(_ type: ShowType){
//        self.tmdbClient.getWatchlistShows(type: type) { [weak self] result in
//            guard let self = self else { return }
//            switch result{
//            case .failure(let error):
//                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)
//                
//            case .success(let shows):
//                self.watchlistShows += shows
//                
//                DispatchQueue.main.async {
//                    self.watchlistCollectionView.refreshControl?.endRefreshing()
//                    self.watchlistCollectionView.reloadData()
//                }
//            }
//        }
//        
//    }
//}
//
//
//
//// MARK: - Data Source
//extension SavedOldViewController: PagingCollectionViewDataSource{
//    func pagingCollectionView(_ subCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if subCollectionView == favoriteCollectionView{
//            return favoriteShows.count
//        }else if subCollectionView == watchlistCollectionView{
//            return watchlistShows.count
//        }
//        fatalError("pagingCollectionView(numberOFItemInSection:) unkown collectionView in SavedViewController")
//    }
//    
//    func pagingCollectionView(_ subCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = subCollectionView.dequeueReusableCell(withReuseIdentifier: SavedCollectionViewCell.identifier, for: indexPath) as! SavedCollectionViewCell
//        
//        cell.posterImageView.image = Constant.defualtImage
//        cell.loadingIndicator.startAnimating()
//        
//        if subCollectionView == favoriteCollectionView{
//            cell.button.setImage(Constant.favouriteFillImage, for: .normal)
//            return setupCell(cell, show: favoriteShows[indexPath.row])
//            
//        }else if subCollectionView == watchlistCollectionView{
//            cell.button.setImage(Constant.bookmarkFillImage, for: .normal)
//            return setupCell(cell, show: watchlistShows[indexPath.row])
//        }
//        
//        return cell
//    }
//    
//    private func setupCell(_ cell: SavedCollectionViewCell, show: Show) -> SavedCollectionViewCell{
//        cell.titleLabel.text = show.name ?? show.title
//        cell.genreLabel.text = show.genreString
//        cell.representedIdentifier = show.identifier
//        
////        show.getPosterImage { result in
////            if cell.representedIdentifier != show.identifier { return }
////            
////            switch result {
////            case .failure(let error):
////                print(error)
////                
////            case .success(let data):
////                cell.imageView.image = UIImage(data: data)
////            }
////            
////            cell.loadingIndicator.stopAnimating()
////            cell.layoutIfNeeded()
////        }
//        
//        return cell
//    }
//}
//
//
//
//// MARK: - Delegate
//extension SavedOldViewController: PagingCollectionViewDelegate{
//    func pagingCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        var showDetailsVC: ShowDetailsViewController? = self.storyboard?.instantiateViewController(withIdentifier: ShowDetailsViewController.identifier) as? ShowDetailsViewController
////        var navController: UINavigationController? = UINavigationController(rootViewController: showDetailsVC!)
////        navController!.modalPresentationStyle = .fullScreen
////        
////        if collectionView == favoriteCollectionView{
////            // title for movie and name for tv show
//////            let type: ShowType = (favoriteShows[indexPath.row].title != nil) ? .movie : .tv
//////            showDetailsVC!.detailsOfShow(id: favoriteShows[indexPath.row].id, type: type)
////            self.present(navController!, animated: true) {
////                showDetailsVC = nil
////                navController = nil
////            }
////            
////        }else if collectionView == watchlistCollectionView{
////            // title for movie and name for tv show
//////            let type: ShowType = (watchlistShows[indexPath.row].title != nil) ? .movie : .tv
//////            showDetailsVC!.detailsOfShow(id: watchlistShows[indexPath.row].id, type: type)
////            self.present(navController!, animated: true) {
////                showDetailsVC = nil
////                navController = nil
////            }
////        }
//    }
//}
//
//
//
//// MARK: - FlowLayout
//extension SavedOldViewController: PagingCollectionViewDelegateFlowLayout{
//    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (pagingCollectionView.frame.width / 2), height: (pagingCollectionView.frame.height / 2) + 16)
//    }
//}
