//
//  LoginViewController.swift
//  See
//
//  Created by Khater on 3/25/23.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Variables
    private lazy var mainView = LoginView(viewDelegate: self)
    private let tmdbUserService = TMDBUserService()
    private var username: String?
    private var password: String?
    
    // MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Network Requests Functions
    private func sendLoginRequest() async {
        guard
            let username = username,
            let password = password
        else { return }
        
        do {
            // Get User Token
            let userToken = try await tmdbUserService.getUserToken()
            
            // Login
            let newUserToken = try await tmdbUserService.login(withUserToken: userToken, username: username, password: password)
            
            // Save User Token in userDefaults
            User.shared.setToken(newUserToken)
            
            // Get Session ID
            let sessionID = try await tmdbUserService.getUserSessionID(token: newUserToken)
            
            // Save Session ID in userDefualts
            User.shared.setSessionID(sessionID)
            
            DispatchQueue.main.async { [weak self] in
                // Pop to Previeus Page
                // self?.dismiss(animated: true, completion: nil)
                self?.navigationController?.popToRootViewController(animated: true)
            }
            
        } catch {
            Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            DispatchQueue.main.async { [weak self] in
                self?.mainView.startLoading(false)
            }
        }
    }
    
    
    private func websiteLgoin() async {
        do {
            // Get User Token
            let userToken = try await tmdbUserService.getUserToken()
            
            // Save User Token in userDefaults
            User.shared.setToken(userToken)
            
            // Get URL to the Login Page
            let url = Endpoint.Auth.websiteLogin(token: userToken).url
            
            // Go to the Website
            await UIApplication.shared.open(url, options: [:])
            
        } catch {
            Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            DispatchQueue.main.async { [weak self] in
                self?.mainView.startLoading(false)
            }
        }
    }
}


// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    func loginView(buttonDidPressed button: UIButton) {
        mainView.startLoading(true)
        username = mainView.username
        password = mainView.password
        Task {
            await sendLoginRequest()
        }
    }
}
