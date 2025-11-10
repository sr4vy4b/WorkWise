//
//  JobDetailView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//
import SwiftUI

struct JobDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let job: Job
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    compensationSection
                    benefitsSection
                    ratingsSection
                    
                    if !job.notes.isEmpty {
                        notesSection
                    }
                    
                    if !job.description.isEmpty {
                        descriptionSection
                    }
                }
                .padding()
            }
            .background(
                WorkWiseTheme.backgroundGradient
            )
            .navigationTitle("Job Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete Job?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteJob(job)
                    dismiss()
                }
            }
        }
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(job.company)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            HStack {
                Label(job.location, systemImage: "location.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: job.remoteOption.icon)
                    Text(job.remoteOption.rawValue)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(job.remoteOption == .fullRemote ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .foregroundColor(job.remoteOption == .fullRemote ? .green : .orange)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    var compensationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Total Compensation")
                .font(.headline)
            
            VStack(spacing: 12) {
                compRow("Base Salary", job.salary, .blue)
                compRow("Annual Bonus", job.bonus, .orange)
                
                Divider()
                
                HStack {
                    Text("Total Cash")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("$\(Int(job.salary + job.bonus).formatted())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benefits Package")
                .font(.headline)
            
            VStack(spacing: 12) {
                if job.healthInsurance > 0 {
                    benefitRow("Health Insurance", job.healthInsurance, "cross.case.fill")
                }
                if job.retirement401k > 0 {
                    benefitRow("401(k) Match", job.retirement401k, "chart.line.uptrend.xyaxis")
                }
                if job.paidTimeOff > 0 {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                        Text("\(job.paidTimeOff) days PTO")
                        Spacer()
                        Text("$\(Int(Double(job.paidTimeOff) * job.salary / 260).formatted())")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                if job.educationBudget > 0 {
                    benefitRow("Education Budget", job.educationBudget, "graduationcap.fill")
                }
                if job.stockOptions > 0 {
                    benefitRow("Stock Options", job.stockOptions, "chart.bar.fill")
                }
                if job.remoteOption.value > 0 {
                    benefitRow("Remote Savings", job.remoteOption.value, "house.fill")
                }
                
                if !job.otherBenefits.isEmpty {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.blue)
                        Text(job.otherBenefits)
                            .font(.subheadline)
                        Spacer()
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total Annual Value")
                        .font(.headline)
                    Spacer()
                    Text("$\(Int(job.totalCompensation).formatted())")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Ratings")
                .font(.headline)
            
            VStack(spacing: 16) {
                ratingRow("Work-Life Balance", job.workLifeBalance, .green)
                ratingRow("Career Growth", job.careerGrowth, .blue)
                ratingRow("Personal Rating", job.personalRating, .purple)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            Text(job.notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
        }
    }
    
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
            Text(job.description)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
        }
    }
    
    func compRow(_ label: String, _ value: Double, _ color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text("$\(Int(value).formatted())")
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    func benefitRow(_ label: String, _ value: Double, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(label)
            Spacer()
            Text("$\(Int(value).formatted())")
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
    
    func ratingRow(_ label: String, _ value: Int, _ color: Color) -> some View {
        HStack {
            Text(label)
            Spacer()
            HStack(spacing: 2) {
                ForEach(0..<10) { i in
                    Circle()
                        .fill(i < value ? color : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            Text("\(value)/10")
                .fontWeight(.semibold)
                .foregroundColor(color)
                .frame(width: 40)
        }
    }
}

#Preview {
    JobDetailView(job: Job(
        title: "Software Engineer",
        company: "Tech Corp",
        location: "Remote",
        salary: 120000,
        bonus: 15000,
        description: "Great job",
        healthInsurance: 8000,
        retirement401k: 7200,
        paidTimeOff: 25,
        educationBudget: 2000,
        stockOptions: 0,
        otherBenefits: "",
        remoteOption: .fullRemote,
        workLifeBalance: 9,
        careerGrowth: 7,
        notes: "Love the flexibility",
        personalRating: 9,
        dateAdded: Date()
    ))
    .environmentObject(DataManager())
}
