//
//  User.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation


struct User {
    public static let shared = User()
    private let userDefaults = UserDefaults.standard
    
    private let tokenKey = "requestToken"
    private let sessionIDKey = "sessionId"
    private let accountIDKey = "accountIdKey"
    
    public var token: String {
        get {
            userDefaults.string(forKey: tokenKey) ?? ""
        }
    }
    
    public var sessionID: String {
        userDefaults.string(forKey: sessionIDKey) ?? ""
    }
    
    public var isLoggedIn: Bool {
        userDefaults.string(forKey: sessionIDKey) != nil
    }
    
    public var accountID: Int {
        userDefaults.integer(forKey: accountIDKey)
    }
    
    
    private let notificationCenter = NotificationCenter.default
    public static let loginNotificationKey = "User.loggedIn"
    public static let logoutNotificationKey = "User.loggedOut"
    
    private init() {}
    
    func setToken(_ token: String){
        userDefaults.set(token, forKey: tokenKey)
    }
    
    func setSessionID(_ sessionID: String){
        userDefaults.set(sessionID, forKey: sessionIDKey)
        sendNotifictaionForLogin()
    }
    
    func setAccountID(_ id: Int) {
        userDefaults.set(id, forKey: accountIDKey)
    }
    
    func logout(){
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: sessionIDKey)
        userDefaults.removeObject(forKey: accountIDKey)
        sendNotificationForLogout()
    }
    
    private func sendNotifictaionForLogin() {
        notificationCenter.post(name: Notification.Name(User.loginNotificationKey), object: nil)
    }
    
    private func sendNotificationForLogout() {
        notificationCenter.post(name: Notification.Name(User.logoutNotificationKey), object: nil)
    }
}
