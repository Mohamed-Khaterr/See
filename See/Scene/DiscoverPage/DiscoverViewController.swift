//
//  DiscoverViewController.swift
//  See
//
//  Created by Khater on 11/15/22.
//

import UIKit

//class DiscoverViewController: UIViewController {
//    static let identifier = "DiscoverViewController"
//    
//    @IBOutlet weak var tableView: UITableView!
//        
//    private var popularCollectionView: UICollectionView!
//    private var revenueCollectionView: UICollectionView!
//    private var primaryCollectionView: UICollectionView!
//    private var ratedCollectionView: UICollectionView!
//    
//    private let tmdbClient = TMDBClient()
//    
//    private var populars: [Show] = []
//    private var revenues: [Show] = []
//    private var primaries: [Show] = []
//    private var rateds: [Show] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        setupSubCollectionViews()
//        
//        fetchData(sort: .popularityDesc)
//        fetchData(sort: .revenueDesc)
//        fetchData(sort: .primaryReleaseDateDesc)
//        fetchData(sort: .voteAverageDesc)
//    }
//    
//    deinit {
//        print("DiscoverViewController deinit")
//    }
//    
//    private func setupTableView(){
//        tableView.register(HeaderTableViewCell.nib(), forCellReuseIdentifier: HeaderTableViewCell.identifier)
//        tableView.register(DiscoverTableViewCell.nib(), forCellReuseIdentifier: DiscoverTableViewCell.identifier)
//        tableView.dataSource = self
//        tableView.delegate = self
//    }
//    
//    private func setupSubCollectionViews(){
//        popularCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        revenueCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        primaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        ratedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        
//        [popularCollectionView, revenueCollectionView, primaryCollectionView, ratedCollectionView].forEach { collectionView in
//            collectionView?.register(ShowCollectionViewCell.nib(), forCellWithReuseIdentifier: ShowCollectionViewCell.identifier)
//            collectionView?.isScrollEnabled = false
//        }
//    }
//    
//    @IBAction func backButtonPressed(_ sender: UIButton) {
//        navigationController?.popToRootViewController(animated: true)
//    }
//    
//    private func fetchData(sort: TMDB.Sort){
//        tmdbClient.getDiscover(type: .movie, sortBy: sort) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .failure(let error):
//                print(error)
//                
//            case .success(let show):
//                if sort == .popularityDesc{
//                    self.populars = show
//                }else if sort == .revenueDesc{
//                    self.revenues = show
//                }else if sort == .primaryReleaseDateDesc {
//                    self.primaries = show
//                }else if sort == .voteAverageDesc{
//                    self.rateds = show
//                }
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.popularCollectionView.reloadData()
//                    self.revenueCollectionView.reloadData()
//                    self.primaryCollectionView.reloadData()
//                    self.ratedCollectionView.reloadData()
//                }
//            }
//        }
//    }
//}
//
//
//// MARK: - TableView DataSource
//extension DiscoverViewController: UITableViewDataSource{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier, for: indexPath) as! HeaderTableViewCell
//            return cell
//        }else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: DiscoverTableViewCell.identifier, for: indexPath) as! DiscoverTableViewCell
//            cell.setupPagingCollectionView(delegate: self, subCollectionViews: [popularCollectionView, revenueCollectionView, primaryCollectionView, ratedCollectionView])
//            return cell
//        }
//    }
//}
//
//
//// MARK: - TableView Delegate
//extension DiscoverViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0{
//            return view.frame.height * 0.35
//        }else{
//            return view.frame.height * 4.1
//        }
//    }
//}
//
//
//
//// MARK: - PagingCollectionView DataSource
//extension DiscoverViewController: PagingCollectionViewDataSource{
//    func pagingCollectionView(_ subCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if subCollectionView == popularCollectionView{
//            return populars.count
//        }else if subCollectionView == revenueCollectionView{
//            return revenues.count
//        }else if subCollectionView == primaryCollectionView{
//            return primaries.count
//        }else if subCollectionView == ratedCollectionView{
//            return rateds.count
//        }
//        fatalError()
//    }
//    
//    func pagingCollectionView(_ subCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = subCollectionView.dequeueReusableCell(withReuseIdentifier: ShowCollectionViewCell.identifier, for: indexPath) as! ShowCollectionViewCell
//
//        if subCollectionView == popularCollectionView{
//            return setupCell(cell: cell, show: populars[indexPath.row])
//        }else if subCollectionView == revenueCollectionView{
//            return setupCell(cell: cell, show: revenues[indexPath.row])
//        }else if subCollectionView == primaryCollectionView{
//            return setupCell(cell: cell, show: primaries[indexPath.row])
//        }else if subCollectionView == ratedCollectionView{
//            return setupCell(cell: cell, show: rateds[indexPath.row])
//        }
//        return cell
//    }
//    
//    private func setupCell(cell: ShowCollectionViewCell, show: Show) -> ShowCollectionViewCell{
//        cell.setData(cellID: show.identifier,
//                     title: show.title ?? show.name ?? "Error!",
//                     genre: show.genreString)
//        
////        show.getPosterImage { result in
////            if cell.representedIdentifier != show.identifier { return }
////            
////            switch result {
////            case .failure(_):
////                cell.setPosterImage(with: nil)
////            case .success(let data):
////                cell.setPosterImage(with: UIImage(data: data))
////            }
////        }
//        
//        return cell
//    }
//}
//
//
//// MARK: - PagingCollectionView Delegate & FlowLayout
//extension DiscoverViewController: PagingCollectionViewDelegate, PagingCollectionViewDelegateFlowLayout{
//    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (view.frame.width - 1) / 2, height: view.frame.height / 2.5)
//    }
//}

