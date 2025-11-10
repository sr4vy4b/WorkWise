//
//  JobListView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct JobsListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddJob = false
    @State private var showingSearch = false
    @State private var selectedJob: Job?
    @State private var searchQuery = ""
    @State private var searchLocation = ""
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if !showingSearch {
                        headerWithLogo
                    }
                    
                    if showingSearch {
                        enhancedSearchBar
                    }
                    
                    if showingResults && !dataManager.searchResults.isEmpty {
                        searchResultsList
                    } else if dataManager.jobs.isEmpty && !showingResults {
                        emptyState
                    } else {
                        jobsList
                    }
                }
            }
            .navigationTitle(showingSearch ? "Search Jobs" : "My Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showingSearch.toggle()
                            if !showingSearch {
                                showingResults = false
                            }
                        }
                    }) {
                        Image(systemName: showingSearch ? "xmark.circle.fill" : "magnifyingglass.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddJob = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddJob) {
                AddJobView()
            }
            .sheet(item: $selectedJob) { job in
                JobDetailView(job: job)
            }
        }
    }
    
    var headerWithLogo: some View {
        VStack(spacing: 12) {
            WorkWiseLogo(size: 50, showText: false)
            
            Text("Find Your Perfect Career Match")
                .font(.subheadline)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    var enhancedSearchBar: some View {
        ThemedCard {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    Text("Searching across multiple job platforms")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    TextField("Job title or keywords", text: $searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(WorkWiseTheme.lightGreen.opacity(0.3))
                .cornerRadius(10)
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    TextField("Location (optional)", text: $searchLocation)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(WorkWiseTheme.lightGreen.opacity(0.3))
                .cornerRadius(10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(quickSearches, id: \.self) { search in
                            Button(action: {
                                searchQuery = search
                            }) {
                                Text(search)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(WorkWiseTheme.primaryGreen.opacity(0.1))
                                    .foregroundColor(WorkWiseTheme.darkGreen)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                Button(action: performSearch) {
                    if dataManager.isLoading {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Searching...")
                        }
                    } else {
                        Label("Search All Platforms", systemImage: "sparkles")
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(searchQuery.isEmpty)
                
                if let error = dataManager.errorMessage {
                    HStack {
                        Image(systemName: error.contains("Found") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.caption)
                    }
                    .foregroundColor(error.contains("Found") ? WorkWiseTheme.success : WorkWiseTheme.error)
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }
    
    var quickSearches: [String] {
        ["Software Engineer", "Data Analyst", "Product Manager", "Designer", "Marketing", "Sales"]
    }
    
    func performSearch() {
        Task {
            await dataManager.searchJobs(query: searchQuery, location: searchLocation)
            showingResults = true
        }
    }
    
    var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ThemedCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Search Results")
                                .font(.headline)
                                .foregroundStyle(WorkWiseTheme.primaryGradient)
                            Text("\(dataManager.searchResults.count) jobs found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Clear") {
                            withAnimation {
                                showingResults = false
                                dataManager.searchResults = []
                            }
                        }
                        .font(.caption)
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    }
                }
                .padding(.horizontal)
                
                ForEach(dataManager.searchResults) { job in
                    SearchResultJobCard(job: job)
                        .onTapGesture {
                            selectedJob = job
                        }
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    var jobsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dataManager.jobs) { job in
                    SavedJobCard(job: job)
                        .onTapGesture {
                            selectedJob = job
                        }
                }
            }
            .padding()
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 24) {
            WorkWiseLogo(size: 80, showText: false)
            
            Text("No Jobs Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            Text("Search thousands of jobs or add your opportunities manually")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        showingSearch = true
                    }
                }) {
                    Label("Search Jobs", systemImage: "magnifyingglass")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button(action: { showingAddJob = true }) {
                    Label("Add Job Manually", systemImage: "plus.circle")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct SearchResultJobCard: View {
    @EnvironmentObject var dataManager: DataManager
    let job: Job
    
    var isAlreadySaved: Bool {
        dataManager.jobs.contains(where: { $0.id == job.id })
    }
    
    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                        Text(job.company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {
                        if isAlreadySaved {
                            dataManager.deleteJob(job)
                        } else {
                            dataManager.addJobFromSearch(job)
                        }
                    }) {
                        Image(systemName: isAlreadySaved ? "checkmark.circle.fill" : "plus.circle")
                            .font(.title2)
                            .foregroundColor(isAlreadySaved ? WorkWiseTheme.success : WorkWiseTheme.primaryGreen)
                    }
                }
                
                HStack {
                    Label(job.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    ThemedBadge(
                        job.remoteOption.rawValue,
                        icon: job.remoteOption.icon,
                        color: job.remoteOption == .fullRemote ? WorkWiseTheme.success : WorkWiseTheme.warning
                    )
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Base Salary")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(job.salary).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(job.totalCompensation).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(WorkWiseTheme.success)
                    }
                }
                
                if isAlreadySaved {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(WorkWiseTheme.success)
                        Text("Added to your jobs")
                            .font(.caption)
                            .foregroundColor(WorkWiseTheme.success)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
}

struct SavedJobCard: View {
    @EnvironmentObject var dataManager: DataManager
    let job: Job
    
    var isSelectedForComparison: Bool {
        dataManager.selectedJobIds.contains(job.id)
    }
    
    var body: some View {
        ThemedCard(gradient: isSelectedForComparison) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                        Text(job.company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Button(action: {
                            withAnimation {
                                dataManager.toggleJobSelection(job.id)
                            }
                        }) {
                            Image(systemName: isSelectedForComparison ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundColor(isSelectedForComparison ? WorkWiseTheme.primaryGreen : .gray)
                        }
                        Text("Compare")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label(job.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    ThemedBadge(
                        job.remoteOption.rawValue,
                        icon: job.remoteOption.icon,
                        color: job.remoteOption == .fullRemote ? WorkWiseTheme.success : WorkWiseTheme.warning
                    )
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Base Salary")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(job.salary).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(job.totalCompensation).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(WorkWiseTheme.success)
                    }
                }
                
                HStack(spacing: 16) {
                    ratingView("Balance", job.workLifeBalance, WorkWiseTheme.success)
                    ratingView("Growth", job.careerGrowth, WorkWiseTheme.info)
                    ratingView("Rating", job.personalRating, WorkWiseTheme.primaryGreen)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelectedForComparison ? WorkWiseTheme.primaryGreen : Color.clear, lineWidth: 2)
        )
    }
    
    func ratingView(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < value/2 ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundColor(color)
                }
            }
        }
    }
}

#Preview {
    JobsListView()
        .environmentObject(DataManager())
}
