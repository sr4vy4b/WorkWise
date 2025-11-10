//
//  AuthManager.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let userKey = "current_user"
    private let authKey = "is_authenticated"
    
    static let userDidChangeNotification = Notification.Name("UserDidChange")
    
    init() {
        loadAuthState()
    }
    
    func signUp(name: String, email: String, password: String) -> Bool {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            return false
        }
        
        guard email.contains("@") else {
            return false
        }
        
        let user = User(
            name: name,
            email: email,
            joinDate: Date(),
            profileImage: nil
        )
        
        clearAllUserData()
        
        currentUser = user
        isAuthenticated = true
        saveAuthState()
        
        NotificationCenter.default.post(name: Self.userDidChangeNotification, object: nil)
        
        return true
    }
    
    func signIn(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            return false
        }
        
        if let savedUser = loadUser(), savedUser.email == email {
            currentUser = savedUser
            isAuthenticated = true
            saveAuthState()
            return true
        }
        
        let user = User(
            name: email.components(separatedBy: "@").first ?? "User",
            email: email,
            joinDate: Date(),
            profileImage: nil
        )
        
        clearAllUserData()
        
        currentUser = user
        isAuthenticated = true
        saveAuthState()
        
        NotificationCenter.default.post(name: Self.userDidChangeNotification, object: nil)
        
        return true
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        UserDefaults.standard.set(false, forKey: authKey)
        
        clearAllUserData()
    }
    
    func updateProfile(name: String, email: String) {
        guard var user = currentUser else { return }
        user.name = name
        user.email = email
        currentUser = user
        saveUser(user)
    }
    
    private func clearAllUserData() {
        UserDefaults.standard.removeObject(forKey: "saved_jobs")
        UserDefaults.standard.removeObject(forKey: "saved_education")
        UserDefaults.standard.removeObject(forKey: "saved_notes")
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(true, forKey: authKey)
        if let user = currentUser {
            saveUser(user)
        }
    }
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: authKey)
        if isAuthenticated {
            currentUser = loadUser()
        }
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    private func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}

struct User: Codable {
    var name: String
    var email: String
    var joinDate: Date
    var profileImage: String?
}
