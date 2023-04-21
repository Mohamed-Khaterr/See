//
//  SceneDelegate.swift
//  See
//
//  Created by Khater on 10/18/22.
//

import UIKit
import dnssd

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // When app is will running
        if let _ = connectionOptions.urlContexts.first?.url{
        }
        
        // Check Internet Connection
//        if let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController {
//            //print(rootViewController) // is the TabBar
//            InternetConnection.shared.monitoringConnection(to: rootViewController)
//            print("Start Network Checking")
//        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // When app is running
        guard let url = URLContexts.first?.url else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        
        guard
            let scheme = components?.scheme,
            let path = components?.path,
            scheme.lowercased() == "khatermovieapp",
            path.lowercased() == "authenticate"
        else { return }
        
        let tmdbUserService = TMDBUserService()
        
        Task {
            do {
                // Get User Token
                let userToken = User.shared.getToken()
                
                // Get Session ID
                let sessionID = try await tmdbUserService.getUserSessionID(token: userToken ?? "")
                
                // Save Session ID in userDefualts
                User.shared.setSessionID(sessionID)
                
            } catch {
                print("Error: \(error)")
                // Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            }
        }
    }
}

