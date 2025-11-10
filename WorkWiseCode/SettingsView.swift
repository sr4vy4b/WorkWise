//
//  SettingsView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingClearAlert = false
    @State private var showingSignOutAlert = false
    @State private var showingAbout = false
    @State private var showingEditProfile = false
    
    var user: User {
        authManager.currentUser ?? User(name: "User", email: "", joinDate: Date(), profileImage: nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        
                        statsSection
                        
                        dataSection
                        
                        resourcesSection
                        
                        signOutButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Clear All Data?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    dataManager.clearAllData()
                }
            } message: {
                Text("This will permanently delete all your jobs, education investments, and notes. This cannot be undone.")
            }
            .alert("Sign Out?", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    withAnimation {
                        authManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    var profileHeader: some View {
        ThemedCard(gradient: true) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(WorkWiseTheme.primaryGradient)
                        .frame(width: 100, height: 100)
                    
                    Text(user.name.prefix(1).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(WorkWiseTheme.primaryGradient)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    Text("Member since \(user.joinDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: { showingEditProfile = true }) {
                    Label("Edit Profile", systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(WorkWiseTheme.lightGreen)
                        .cornerRadius(20)
                }
            }
        }
    }
    
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Your Activity", icon: "chart.bar.fill")
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Jobs Saved",
                    value: "\(dataManager.jobs.count)",
                    icon: "briefcase.fill",
                    color: WorkWiseTheme.info
                )
                
                StatCard(
                    title: "Compared",
                    value: "\(dataManager.selectedJobIds.count)",
                    icon: "chart.bar.fill",
                    color: WorkWiseTheme.primaryGreen
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Investments",
                    value: "\(dataManager.educationInvestments.count)",
                    icon: "graduationcap.fill",
                    color: WorkWiseTheme.warning
                )
                
                StatCard(
                    title: "Notes",
                    value: "\(dataManager.notes.count)",
                    icon: "note.text",
                    color: .purple
                )
            }
        }
    }
    
    var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Data Management", icon: "gear")
            
            ThemedCard {
                VStack(spacing: 0) {
                    ActionRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Clear All Data",
                        color: WorkWiseTheme.warning
                    ) {
                        showingClearAlert = true
                    }
                    
                    Divider()
                    
                    ActionRow(
                        icon: "info.circle",
                        title: "About WorkWise",
                        color: WorkWiseTheme.primaryGreen
                    ) {
                        showingAbout = true
                    }
                }
            }
        }
    }
    
    var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Resources", icon: "link")
            
            ThemedCard {
                VStack(spacing: 0) {
                    ResourceLink(
                        title: "Job Search - The Muse",
                        icon: "briefcase.fill",
                        url: "https://www.themuse.com/"
                    )
                    
                    Divider()
                    
                    ResourceLink(
                        title: "Coursera Learning",
                        icon: "graduationcap.fill",
                        url: "https://www.coursera.org/"
                    )
                    
                    Divider()
                    
                    ResourceLink(
                        title: "YouTube Premium",
                        icon: "play.circle.fill",
                        url: "https://www.youtube.com/premium"
                    )
                }
            }
        }
    }
    
    var signOutButton: some View {
        Button(action: { showingSignOutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
                    .fontWeight(.semibold)
            }
            .foregroundColor(WorkWiseTheme.error)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(WorkWiseTheme.error.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, 16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct ResourceLink: View {
    let title: String
    let icon: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(WorkWiseTheme.primaryGreen)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var name: String
    @State private var email: String
    
    init() {
        let user = AuthManager().currentUser ?? User(name: "", email: "", joinDate: Date(), profileImage: nil)
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    Section("Personal Information") {
                        TextField("Name", text: $name)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        Button("Save Changes") {
                            authManager.updateProfile(name: name, email: email)
                            dismiss()
                        }
                        .disabled(name.isEmpty || email.isEmpty)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        WorkWiseLogo(size: 80, showText: false)
                        
                        Text("WorkWise")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                        
                        Text("Make Better Career Decisions")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(
                                icon: "chart.bar",
                                title: "Compare Jobs",
                                description: "Side-by-side comparison of total compensation including benefits and remote work value"
                            )
                            
                            FeatureRow(
                                icon: "dollarsign.circle",
                                title: "Beyond Salary",
                                description: "Calculate true value: health insurance, 401k, PTO, education budget, stock options, and remote savings"
                            )
                            
                            FeatureRow(
                                icon: "graduationcap",
                                title: "Education ROI",
                                description: "Track learning investments like Coursera, YouTube Premium, and courses. See break-even time and returns"
                            )
                            
                            FeatureRow(
                                icon: "note.text",
                                title: "Organize Research",
                                description: "Keep interview notes, company research, and decision-making notes all in one place"
                            )
                            
                            FeatureRow(
                                icon: "house.fill",
                                title: "Work-Life Balance",
                                description: "Rate and compare jobs on what matters: remote flexibility, growth, and personal satisfaction"
                            )
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(WorkWiseTheme.primaryGreen)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
        .environmentObject(AuthManager())
}
