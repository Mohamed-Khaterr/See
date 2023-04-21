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
    
    private init() {}
    
    func setToken(_ token: String){
        userDefaults.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String?{
        return userDefaults.string(forKey: tokenKey)
    }
    
    func setSessionID(_ sessionID: String){
        userDefaults.set(sessionID, forKey: sessionIDKey)
    }
    
    func getSessionID() -> String?{
        return userDefaults.string(forKey: sessionIDKey)
    }
    
    func isLogin() -> Bool {
        return getSessionID() != nil
    }
    
    func logout(){
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: sessionIDKey)
    }
}
