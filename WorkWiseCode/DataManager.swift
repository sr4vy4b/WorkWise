//
//  DataManager.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var educationInvestments: [EducationInvestment] = []
    @Published var notes: [CareerNote] = []
    @Published var selectedJobIds: Set<UUID> = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [Job] = []
    
    private let jobsKey = "saved_jobs"
    private let educationKey = "saved_education"
    private let notesKey = "saved_notes"
    
    private let museAPIKey: String? = "32772e2bb486d93c9c3c98b899222820be6351da8eae27836f0bcea5bd163fa7"
    private let adzunaAppId: String? = "24030b70"
    private let adzunaAPIKey: String? = "1ed33f648b034aab3892e58d63f42789"
    private let reedAPIKey: String? = "fdca6d7e-878b-41bc-872d-67839395660e"
    
    init() {
        loadData()
        
        NotificationCenter.default.addObserver(
            forName: AuthManager.userDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearAllData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func searchJobs(query: String, location: String = "") async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            searchResults = []
        }
        
        print("Starting search for: \(query), location: \(location)")
        
        async let museResults = searchMuseAPI(query: query, location: location)
        async let adzunaResults = searchAdzunaAPI(query: query, location: location)
        async let remoteResults = searchRemotiveAPI(query: query)
        async let reedResults = searchReedAPI(query: query, location: location)
        
        let allResults = await [museResults, adzunaResults, remoteResults, reedResults]
            .flatMap { $0 }
        
        print("Total results found: \(allResults.count)")
        
        await MainActor.run {
            if allResults.isEmpty {
                errorMessage = "No jobs found. Try different search terms or location."
            } else {
                let uniqueJobs = removeDuplicates(from: allResults)
                searchResults = uniqueJobs
                
                errorMessage = "Found \(uniqueJobs.count) jobs!"
            }
            isLoading = false
        }
    }
    
    
    func addJobFromSearch(_ job: Job) {
        jobs.append(job)
        saveJobs()
    }
    
    
    private func searchMuseAPI(query: String, location: String) async -> [Job] {
        var components = URLComponents(string: "https://www.themuse.com/api/public/jobs")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "0"),
            URLQueryItem(name: "descending", value: "true")
        ]
        
        if let apiKey = museAPIKey {
            queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        }
        
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: query))
        }
        if !location.isEmpty {
            queryItems.append(URLQueryItem(name: "location", value: location))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { return [] }
        
        print("Muse API URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Muse Status: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(MuseJobResult.self, from: data)
            print("Muse found: \(result.results.count) jobs")
            return result.results.prefix(15).map { $0.toJob() }
        } catch {
            print("Muse API Error: \(error)")
            return []
        }
    }
    
    
    private func searchAdzunaAPI(query: String, location: String) async -> [Job] {
        guard let appId = adzunaAppId, let apiKey = adzunaAPIKey else {
            print("Adzuna keys not configured")
            return []
        }
        
        let country = "us"
        let locationParam = location.isEmpty ? "USA" : location
        
        var components = URLComponents(string: "https://api.adzuna.com/v1/api/jobs/\(country)/search/1")!
        components.queryItems = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: apiKey),
            URLQueryItem(name: "what", value: query),
            URLQueryItem(name: "where", value: locationParam),
            URLQueryItem(name: "results_per_page", value: "20")
        ]
        
        guard let url = components.url else { return [] }
        
        print("Adzuna API URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Adzuna Status: \(httpResponse.statusCode)")
            }
            
            let result = try JSONDecoder().decode(AdzunaJobResult.self, from: data)
            print("Adzuna found: \(result.results.count) jobs")
            return result.results.map { $0.toJob() }
        } catch {
            print("Adzuna API Error: \(error)")
            return []
        }
    }
    
    
    private func searchRemotiveAPI(query: String) async -> [Job] {
        var components = URLComponents(string: "https://remotive.com/api/remote-jobs")!
        if !query.isEmpty {
            components.queryItems = [URLQueryItem(name: "search", value: query)]
        }
        
        guard let url = components.url else { return [] }
        
        print("Remotive API URL: \(url.absoluteString)")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(RemotiveJobResult.self, from: data)
            print("Remotive found: \(result.jobs.count) jobs")
            return result.jobs.prefix(10).map { $0.toJob() }
        } catch {
            print("Remotive API Error: \(error)")
            return []
        }
    }
    
    
    private func searchReedAPI(query: String, location: String) async -> [Job] {
        guard let apiKey = reedAPIKey else {
            print("Reed key not configured")
            return []
        }
        
        var components = URLComponents(string: "https://www.reed.co.uk/api/1.0/search")!
        components.queryItems = [
            URLQueryItem(name: "keywords", value: query),
            URLQueryItem(name: "locationName", value: location.isEmpty ? "London" : location),
            URLQueryItem(name: "resultsToTake", value: "15")
        ]
        
        guard let url = components.url else { return [] }
        
        var request = URLRequest(url: url)
        let credentials = "\(apiKey):".data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        
        print("Reed API URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Reed Status: \(httpResponse.statusCode)")
            }
            
            let result = try JSONDecoder().decode(ReedJobResult.self, from: data)
            print("Reed found: \(result.results.count) jobs")
            return result.results.map { $0.toJob() }
        } catch {
            print("Reed API Error: \(error)")
            return []
        }
    }
    
    
    private func removeDuplicates(from jobs: [Job]) -> [Job] {
        var seen = Set<String>()
        return jobs.filter { job in
            let key = "\(job.title)-\(job.company)".lowercased()
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }
    
    
    func addJob(_ job: Job) {
        jobs.append(job)
        saveJobs()
    }
    
    func updateJob(_ job: Job) {
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index] = job
            saveJobs()
        }
    }
    
    func deleteJob(_ job: Job) {
        jobs.removeAll { $0.id == job.id }
        selectedJobIds.remove(job.id)
        saveJobs()
    }
    
    func toggleJobSelection(_ jobId: UUID) {
        if selectedJobIds.contains(jobId) {
            selectedJobIds.remove(jobId)
        } else {
            if selectedJobIds.count < 4 {
                selectedJobIds.insert(jobId)
            }
        }
    }
    
    func getSelectedJobs() -> [Job] {
        jobs.filter { selectedJobIds.contains($0.id) }
    }
    
    
    func addEducation(_ education: EducationInvestment) {
        educationInvestments.append(education)
        saveEducation()
    }
    
    func updateEducation(_ education: EducationInvestment) {
        if let index = educationInvestments.firstIndex(where: { $0.id == education.id }) {
            educationInvestments[index] = education
            saveEducation()
        }
    }
    
    func deleteEducation(_ education: EducationInvestment) {
        educationInvestments.removeAll { $0.id == education.id }
        saveEducation()
    }
    
    
    func addNote(_ note: CareerNote) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: CareerNote) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(_ note: CareerNote) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    
    private func saveJobs() {
        if let encoded = try? JSONEncoder().encode(jobs) {
            UserDefaults.standard.set(encoded, forKey: jobsKey)
        }
    }
    
    private func saveEducation() {
        if let encoded = try? JSONEncoder().encode(educationInvestments) {
            UserDefaults.standard.set(encoded, forKey: educationKey)
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: jobsKey),
           let decoded = try? JSONDecoder().decode([Job].self, from: data) {
            jobs = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: educationKey),
           let decoded = try? JSONDecoder().decode([EducationInvestment].self, from: data) {
            educationInvestments = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([CareerNote].self, from: data) {
            notes = decoded
        }
    }
    
    func clearAllData() {
        jobs = []
        educationInvestments = []
        notes = []
        selectedJobIds = []
        searchResults = []
        UserDefaults.standard.removeObject(forKey: jobsKey)
        UserDefaults.standard.removeObject(forKey: educationKey)
        UserDefaults.standard.removeObject(forKey: notesKey)
    }
}
