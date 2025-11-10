//
//  EducationView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct EducationView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAdd = false
    @State private var currentSalary = "75000"
    @State private var selectedInvestment: EducationInvestment?
    
    var totalAnnualCost: Double {
        dataManager.educationInvestments.reduce(0.0) { total, investment in
            total + (investment.isYearly ? investment.cost : investment.cost / Double(investment.duration) * 12)
        }
    }
    
    var totalExpectedIncrease: Double {
        dataManager.educationInvestments.reduce(0.0) { $0 + $1.expectedSalaryIncrease }
    }
    
    var currentSalaryValue: Double {
        Double(currentSalary) ?? 75000
    }
    
    var projectedSalary: Double {
        currentSalaryValue + totalExpectedIncrease
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        salaryInputCard
                        
                        if !dataManager.educationInvestments.isEmpty {
                            summaryCard
                            projectionCard
                            investmentsList
                        } else {
                            emptyState
                        }
                        
                        exampleSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Learning ROI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEducationView()
            }
            .sheet(item: $selectedInvestment) { investment in
                EducationDetailView(investment: investment)
            }
        }
    }
    
    var salaryInputCard: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader("Current Annual Salary", icon: "dollarsign.circle.fill")
                
                HStack {
                    Text("$")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    TextField("75000", text: $currentSalary)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(WorkWiseTheme.primaryGradient)
                }
                .padding()
                .background(WorkWiseTheme.lightGreen.opacity(0.3))
                .cornerRadius(12)
                
                if currentSalaryValue > 0 {
                    Text("Track how learning investments can increase your earning potential")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var summaryCard: some View {
        ThemedCard(gradient: true) {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader("Investment Summary", icon: "chart.bar.fill")
                
                HStack(spacing: 0) {
                    summaryColumn("Annual Cost", totalAnnualCost, .orange, icon: "minus.circle.fill")
                    Divider().frame(height: 60)
                    summaryColumn("Expected Increase", totalExpectedIncrease, WorkWiseTheme.success, icon: "plus.circle.fill")
                    Divider().frame(height: 60)
                    summaryColumn("Net Gain", totalExpectedIncrease - totalAnnualCost,
                                totalExpectedIncrease > totalAnnualCost ? WorkWiseTheme.success : .red,
                                icon: "equal.circle.fill")
                }
            }
        }
    }
    
    func summaryColumn(_ title: String, _ value: Double, _ color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("$\(Int(value).formatted())")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    var projectionCard: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                ThemedSectionHeader("Salary Projection", icon: "chart.line.uptrend.xyaxis")
                
                VStack(spacing: 12) {
                    projectionRow("Current Salary", currentSalaryValue, .blue)
                    
                    Image(systemName: "arrow.down")
                        .foregroundColor(WorkWiseTheme.primaryGreen)
                    
                    projectionRow("After Learning Investments", projectedSalary, WorkWiseTheme.success)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Percentage Increase")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            let percentIncrease = ((projectedSalary - currentSalaryValue) / currentSalaryValue) * 100
                            Text("+\(String(format: "%.1f", percentIncrease))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(WorkWiseTheme.accentGold)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("5-Year Value")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            let fiveYearGain = (totalExpectedIncrease * 5) - (totalAnnualCost * 5)
                            Text("$\(Int(fiveYearGain).formatted())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(WorkWiseTheme.success)
                        }
                    }
                    .padding()
                    .background(WorkWiseTheme.lightGreen.opacity(0.3))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    func projectionRow(_ label: String, _ value: Double, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("$\(Int(value).formatted())")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    var investmentsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThemedSectionHeader("Your Learning Investments", icon: "graduationcap.fill")
            
            ForEach(dataManager.educationInvestments) { investment in
                EducationCard(investment: investment)
                    .onTapGesture {
                        selectedInvestment = investment
                    }
            }
        }
    }
    
    var emptyState: some View {
        ThemedCard {
            VStack(spacing: 24) {
                Image(systemName: "graduationcap.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
                
                Text("No Investments Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
                
                Text("Track courses and subscriptions to calculate your learning ROI and see how they boost your earning potential")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: { showingAdd = true }) {
                    Label("Add Investment", systemImage: "plus.circle.fill")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
    }
    
    var exampleSection: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(WorkWiseTheme.accentGold)
                    Text("Popular Learning Platforms")
                        .font(.headline)
                        .foregroundStyle(WorkWiseTheme.primaryGradient)
                }
                
                Text("Track subscriptions and courses to see their real ROI on your career growth")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    exampleRow("Coursera Plus", "$399/year", "Unlimited courses & certificates", .purple)
                    exampleRow("YouTube Premium", "$140/year", "Ad-free tutorials & learning", .red)
                    exampleRow("Udemy Courses", "$200/year", "Specific technical skills", .orange)
                    exampleRow("LinkedIn Learning", "$360/year", "Professional development", .blue)
                }
            }
        }
    }
    
    func exampleRow(_ name: String, _ cost: String, _ benefit: String, _ color: Color) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(benefit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(cost)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct EducationDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let investment: EducationInvestment
    @State private var showingDelete = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ThemedCard(gradient: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(investment.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(WorkWiseTheme.primaryGradient)
                            Text(investment.provider)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ThemedBadge(
                                investment.isYearly ? "Annual Subscription" : "\(investment.duration) Months",
                                icon: "calendar",
                                color: WorkWiseTheme.primaryGreen
                            )
                        }
                    }
                    
                    ThemedCard {
                        VStack(alignment: .leading, spacing: 16) {
                            ThemedSectionHeader("ROI Analysis", icon: "chart.bar.fill")
                            
                            roiRow("Investment Cost", investment.cost, .orange)
                            roiRow("Expected Salary Increase", investment.expectedSalaryIncrease, WorkWiseTheme.success)
                            
                            Divider()
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Break-even Time")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(String(format: "%.1f months", investment.breakEvenMonths))
                                        .font(.headline)
                                        .foregroundColor(investment.breakEvenMonths < 12 ? WorkWiseTheme.success : .orange)
                                }
                                
                                let fiveYearReturn = (investment.expectedSalaryIncrease * 5) - (investment.isYearly ? investment.cost * 5 : investment.cost)
                                HStack {
                                    Text("5-Year Return")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("$\(Int(fiveYearReturn).formatted())")
                                        .font(.headline)
                                        .foregroundColor(WorkWiseTheme.success)
                                }
                            }
                            .padding()
                            .background(WorkWiseTheme.lightGreen.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    

                    if !investment.skills.isEmpty {
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                ThemedSectionHeader("Skills You'll Learn", icon: "star.fill")
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(investment.skills, id: \.self) { skill in
                                        Text(skill)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(WorkWiseTheme.primaryGreen.opacity(0.1))
                                            .foregroundColor(WorkWiseTheme.darkGreen)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    if !investment.notes.isEmpty {
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                ThemedSectionHeader("Notes", icon: "note.text")
                                Text(investment.notes)
                                    .font(.body)
                            }
                        }
                    }
                    
                    Button(role: .destructive, action: { showingDelete = true }) {
                        Label("Delete Investment", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding()
            }
            .background(WorkWiseTheme.backgroundGradient)
            .navigationTitle("Investment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Investment?", isPresented: $showingDelete) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteEducation(investment)
                    dismiss()
                }
            }
        }
    }
    
    func roiRow(_ label: String, _ value: Double, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("$\(Int(value).formatted())")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct EducationCard: View {
    @EnvironmentObject var dataManager: DataManager
    let investment: EducationInvestment
    
    var annualCost: Double {
        investment.isYearly ? investment.cost : (investment.cost / Double(investment.duration) * 12)
    }
    
    var body: some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(investment.name)
                            .font(.headline)
                            .foregroundStyle(WorkWiseTheme.primaryGradient)
                        Text(investment.provider)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    ThemedBadge(
                        investment.isYearly ? "Yearly" : "\(investment.duration)mo",
                        icon: "calendar",
                        color: investment.isYearly ? .purple : .blue
                    )
                }
                
                Divider()
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Annual Cost")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(Int(annualCost).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Salary Increase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("+$\(Int(investment.expectedSalaryIncrease).formatted())")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(WorkWiseTheme.success)
                    }
                }
                

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Break-even")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f mo", investment.breakEvenMonths))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(investment.breakEvenMonths < 12 ? WorkWiseTheme.success : .orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("5-Year Return")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        let fiveYearReturn = (investment.expectedSalaryIncrease * 5) - (investment.isYearly ? investment.cost * 5 : investment.cost)
                        Text("$\(Int(fiveYearReturn).formatted())")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(WorkWiseTheme.success)
                    }
                }
                .padding()
                .background(WorkWiseTheme.lightGreen.opacity(0.3))
                .cornerRadius(8)
                
                if !investment.skills.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Skills")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(investment.skills.prefix(3), id: \.self) { skill in
                                    Text(skill)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(WorkWiseTheme.primaryGreen.opacity(0.1))
                                        .foregroundColor(WorkWiseTheme.darkGreen)
                                        .cornerRadius(6)
                                }
                                if investment.skills.count > 3 {
                                    Text("+\(investment.skills.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    EducationView()
        .environmentObject(DataManager())
}
