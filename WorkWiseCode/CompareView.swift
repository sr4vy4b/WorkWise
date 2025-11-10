//
//  CompareView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct CompareView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var selectedJobs: [Job] {
        dataManager.getSelectedJobs()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                if selectedJobs.isEmpty {
                    emptyState
                } else if selectedJobs.count == 1 {
                    singleJobState
                } else {
                    comparisonContent
                }
            }
            .navigationTitle("Compare Jobs")
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 24) {
            WorkWiseLogo(size: 80, showText: false)
            
            Text("No Jobs Selected")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            Text("Select 2-4 jobs from the Search tab to compare them side-by-side")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    var singleJobState: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(WorkWiseTheme.primaryGreen)
            
            Text("Select More Jobs")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            Text("Add at least one more job from the Search tab to start comparing")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    var comparisonContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                jobHeadersRow
                
                compensationComparison
                benefitsComparison
                ratingsComparison
                recommendation
            }
            .padding()
        }
    }
    
    var jobHeadersRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Comparing \(selectedJobs.count) Jobs", icon: "chart.bar.fill")
            
            ThemedCard {
                HStack(spacing: 12) {
                    ForEach(Array(selectedJobs.enumerated()), id: \.offset) { index, job in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(jobColor(for: index))
                                    .frame(width: 50, height: 50)
                                
                                Text("\(index + 1)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 2) {
                                Text(job.title)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                
                                Text(job.company)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    var compensationComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Compensation", icon: "dollarsign.circle")
            
            ThemedCard {
                VStack(spacing: 16) {
                    compareRowWithLabels("Base Salary", selectedJobs.map { $0.salary })
                    compareRowWithLabels("Bonus", selectedJobs.map { $0.bonus })
                    compareRowWithLabels("Benefits Value", selectedJobs.map { $0.benefitsTotal })
                    
                    Divider()
                    
                    compareRowWithLabels("Total Annual Value", selectedJobs.map { $0.totalCompensation }, isBold: true)
                }
            }
        }
    }
    
    var benefitsComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Benefits Breakdown", icon: "heart.fill")
            
            ThemedCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("Benefit")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        ForEach(Array(selectedJobs.enumerated()), id: \.offset) { index, _ in
                            ZStack {
                                Circle()
                                    .fill(jobColor(for: index))
                                    .frame(width: 30, height: 30)
                                
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    

                    benefitCompareRowWithValues("Health Ins.", selectedJobs.map { $0.healthInsurance })
                    benefitCompareRowWithValues("401(k)", selectedJobs.map { $0.retirement401k })
                    benefitCompareRowWithValues("PTO", selectedJobs.map { Double($0.paidTimeOff) * $0.salary / 260 })
                    benefitCompareRowWithValues("Education", selectedJobs.map { $0.educationBudget })
                    benefitCompareRowWithValues("Stock", selectedJobs.map { $0.stockOptions })
                    benefitCompareRowWithValues("Remote", selectedJobs.map { $0.remoteOption.value })
                }
            }
        }
    }
    
    var ratingsComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Ratings", icon: "star.fill")
            
            ThemedCard {
                VStack(spacing: 16) {
                    HStack {
                        Text("Category")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        ForEach(Array(selectedJobs.enumerated()), id: \.offset) { index, _ in
                            ZStack {
                                Circle()
                                    .fill(jobColor(for: index))
                                    .frame(width: 30, height: 30)
                                
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    ratingCompareRowWithValues("Work-Life Balance", selectedJobs.map { $0.workLifeBalance }, WorkWiseTheme.success)
                    ratingCompareRowWithValues("Career Growth", selectedJobs.map { $0.careerGrowth }, WorkWiseTheme.info)
                    ratingCompareRowWithValues("Personal Rating", selectedJobs.map { $0.personalRating }, WorkWiseTheme.primaryGreen)
                }
            }
        }
    }
    
    var recommendation: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Recommendation", icon: "star.circle.fill")
            
            if let bestJob = getBestJob() {
                ThemedCard(gradient: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundColor(WorkWiseTheme.accentGold)
                            VStack(alignment: .leading) {
                                Text("Best Overall Match")
                                    .font(.headline)
                                    .foregroundStyle(WorkWiseTheme.primaryGradient)
                                Text("\(bestJob.title) at \(bestJob.company)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(getRecommendationReason(for: bestJob))
                            .font(.body)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    func compareRowWithLabels(_ label: String, _ values: [Double], isBold: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(Array(zip(selectedJobs.indices, values)), id: \.0) { index, value in
                    VStack(spacing: 4) {
                        Text("$\(Int(value).formatted())")
                            .font(isBold ? .headline : .body)
                            .fontWeight(isBold ? .bold : .regular)
                            .foregroundColor(isMax(value, in: values) ? WorkWiseTheme.success : .primary)
                        
                        if isMax(value, in: values) && !isBold {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(WorkWiseTheme.success)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func benefitCompareRowWithValues(_ label: String, _ values: [Double]) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            HStack(spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 2) {
                        if value > 0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(WorkWiseTheme.success)
                            Text("$\(Int(value).formatted())")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("—")
                                .font(.system(size: 9))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func ratingCompareRowWithValues(_ label: String, _ values: [Int], _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(width: 120, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 4) {
                        Text("\(value)")
                            .font(.headline)
                            .foregroundColor(isMaxInt(value, in: values) ? color : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func jobColor(for index: Int) -> Color {
        let colors: [Color] = [
            WorkWiseTheme.primaryGreen,
            WorkWiseTheme.info,
            WorkWiseTheme.warning,
            .purple
        ]
        return colors[index % colors.count]
    }
    
    func isMax(_ value: Double, in values: [Double]) -> Bool {
        guard let max = values.max() else { return false }
        return value == max
    }
    
    func isMaxInt(_ value: Int, in values: [Int]) -> Bool {
        guard let max = values.max() else { return false }
        return value == max
    }
    
    func getBestJob() -> Job? {
        selectedJobs.max(by: { calculateScore($0) < calculateScore($1) })
    }
    
    func calculateScore(_ job: Job) -> Double {
        let compScore = job.totalCompensation / 1000
        let balanceScore = Double(job.workLifeBalance * 10000)
        let growthScore = Double(job.careerGrowth * 8000)
        let ratingScore = Double(job.personalRating * 6000)
        return compScore + balanceScore + growthScore + ratingScore
    }
    
    func getRecommendationReason(for job: Job) -> String {
        var reasons: [String] = []
        
        if job.totalCompensation == selectedJobs.map({ $0.totalCompensation }).max() {
            reasons.append("highest total value ($\(Int(job.totalCompensation).formatted()))")
        }
        if job.workLifeBalance >= 8 {
            reasons.append("excellent work-life balance (\(job.workLifeBalance)/10)")
        }
        if job.remoteOption == .fullRemote {
            reasons.append("full remote flexibility")
        }
        if job.careerGrowth >= 8 {
            reasons.append("strong growth potential")
        }
        
        if reasons.isEmpty {
            return "This job offers the best overall balance of compensation, benefits, and personal fit."
        }
        
        return "This job stands out with: " + reasons.joined(separator: ", ") + "."
    }
}

#Preview {
    CompareView()
        .environmentObject(DataManager())
}
