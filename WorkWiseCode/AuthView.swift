//
//  AuthView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isSignUp = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            WorkWiseTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    WorkWiseLogo(size: 100, showText: true)
                    
                    Text(isSignUp ? "Create Your Account" : "Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(WorkWiseTheme.primaryGradient)
                    
                    VStack(spacing: 20) {
                        if isSignUp {
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "Full Name",
                                text: $name
                            )
                        }
                        
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )
                        
                        if isSignUp {
                            CustomTextField(
                                icon: "lock.fill",
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isSecure: true
                            )
                        }
                        
                        if showError {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(WorkWiseTheme.error)
                                .padding(.horizontal)
                        }
                        
                        Button(action: handleAuth) {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(WorkWiseTheme.primaryGradient)
                                .cornerRadius(12)
                                .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                        
                        Button(action: {
                            withAnimation {
                                isSignUp.toggle()
                                showError = false
                                errorMessage = ""
                            }
                        }) {
                            HStack {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .foregroundColor(.secondary)
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .foregroundColor(WorkWiseTheme.primaryGreen)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer(minLength: 60)
                }
            }
        }
    }
    
    func handleAuth() {
        showError = false
        errorMessage = ""
        
        if isSignUp {
            if name.isEmpty {
                errorMessage = "Please enter your name"
                showError = true
                return
            }
            
            if password != confirmPassword {
                errorMessage = "Passwords don't match"
                showError = true
                return
            }
            
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
                showError = true
                return
            }
            
            if authManager.signUp(name: name, email: email, password: password) {
            } else {
                errorMessage = "Sign up failed. Please try again."
                showError = true
            }
        } else {
            if authManager.signIn(email: email, password: password) {
            } else {
                errorMessage = "Invalid email or password"
                showError = true
            }
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(WorkWiseTheme.primaryGreen)
                .frame(width: 30)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
