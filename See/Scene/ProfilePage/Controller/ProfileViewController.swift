//
//  ProfileViewController.swift
//  See
//
//  Created by Khater on 11/1/22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    // MARK: - Variables
    private let tmdbUserService = TMDBUserService()
    private var userInfo: Account?
    private var isLogin = false
    
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLogin = User.shared.isLogin()
        tableView.reloadData()
        if userInfo == nil && isLogin {
            Task { await requestUserInfo() }
        }
    }
    
    
    // MARK: - Functions
    private func requestUserInfo() async {
        do {
            let sessionID = User.shared.getSessionID() ?? ""
            let info = try await tmdbUserService.getAccountInfo(withUserSessionID: sessionID)
            self.userInfo = info
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
        } catch {
            Alert.show(to: self, title: "User Info", message: error.localizedDescription, compeltionHandler: nil)
        }
    }
    
    private func requestLogout() async {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.startAnimating()
        }
        
        do {
            let sessionID = User.shared.getSessionID() ?? ""
            let success = try await tmdbUserService.logout(withUserSessionID: sessionID)
            
            if success {
                User.shared.logout()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLogin = false
                    self.loadingIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
                
            } else {
                // Show alert
                Alert.show(to: self, title: "Logout", message: "Logout is failed!", compeltionHandler: nil)
            }
            
        } catch {
            Alert.show(to: self, title: "Logout", message: error.localizedDescription, compeltionHandler: nil)
        }
    }
}



// MARK: - UITableView DataSource
extension ProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        switch indexPath.row{
        case 0:
            // Application Settings
            cell.textLabel?.text = "Application settings"
            cell.accessoryType = .disclosureIndicator
            
        case 1:
            // Login or Logout
            if isLogin{
                cell.textLabel?.text = "Log out"
                cell.imageView?.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                
                
            }else{
                cell.textLabel?.text = "Login"
                cell.imageView?.image = UIImage(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
            }
            
            cell.imageView?.tintColor = .label
            
        default:
            fatalError()
        }
        
        return cell
    }
}



// MARK: - UITableView Delegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            // Go to application settings
            print("Application Settings")
            
        case 1:
            if isLogin {
                Task { await requestLogout() }
                
            } else {
                // Navigate To Login Page
                let loginVC = LoginViewController()
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
            
        default: return
        }
    }
    
    
}



// MARK: - UITableView Header
extension ProfileViewController{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !isLogin{ return nil }
        
        let headerView = UIView()
        
        let profileImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: self.view.center.x - 50,
                                                      y: 24,
                                                      width: 100,
                                                      height: 100))
            imageView.image = Constant.profileImage
            imageView.contentMode = .scaleAspectFill
            imageView.tintColor = .label
            imageView.cornerRadius = 50
            imageView.clipsToBounds = true
            
            return imageView
        }()
        
        let usernameLabe: UILabel = {
            let label = UILabel(frame: CGRect(x: self.view.center.x - 250,
                                              y: profileImageView.frame.origin.y + profileImageView.frame.height + 18,
                                              width: 500,
                                              height: 20))
            label.text = userInfo?.username ?? "Username"
            label.font = UIFont(name: "Inter-Medium", size: 20)
            label.textColor = .label
            label.textAlignment = .center
            
            return label
        }()
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(usernameLabe)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isLogin ? CGFloat(self.view.frame.width / 2) : CGFloat(0)
    }
}
