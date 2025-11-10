//
//  AddEducationView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct AddEducationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var provider = ""
    @State private var cost = ""
    @State private var isYearly = true
    @State private var duration = "12"
    @State private var expectedIncrease = ""
    @State private var skills = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Investment Details") {
                    TextField("Name (e.g., Coursera Plus)", text: $name)
                    TextField("Provider", text: $provider)
                }
                
                Section("Cost") {
                    Toggle("Annual Subscription", isOn: $isYearly)
                    TextField("Cost ($)", text: $cost)
                        .keyboardType(.decimalPad)
                    
                    if !isYearly {
                        TextField("Duration (months)", text: $duration)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Expected Return") {
                    TextField("Expected Salary Increase ($/year)", text: $expectedIncrease)
                        .keyboardType(.decimalPad)
                    
                    Text("Estimate how much your salary could increase per year after completing this learning investment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let costVal = Double(cost),
                       let increaseVal = Double(expectedIncrease),
                       costVal > 0,
                       increaseVal > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ROI Analysis")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            let durationVal = Double(duration) ?? 12
                            let annualCost = isYearly ? costVal : (costVal / durationVal * 12)
                            
                            let breakEvenYears = annualCost / increaseVal
                            let breakEvenMonths = breakEvenYears * 12
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Annual Cost")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(Int(annualCost).formatted())")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Break-even Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if breakEvenMonths < 12 {
                                        Text("\(Int(breakEvenMonths)) months")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    } else {
                                        Text(String(format: "%.1f years", breakEvenYears))
                                            .font(.headline)
                                            .foregroundColor(breakEvenYears < 2 ? .green : .orange)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            let fiveYearCost = annualCost * 5
                            let fiveYearGain = increaseVal * 5
                            let fiveYearReturn = fiveYearGain - fiveYearCost
                            
                            VStack(spacing: 8) {
                                Text("5-Year Projection")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text("Investment:")
                                        .font(.caption)
                                    Spacer()
                                    Text("-$\(Int(fiveYearCost).formatted())")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                                
                                HStack {
                                    Text("Salary Gain:")
                                        .font(.caption)
                                    Spacer()
                                    Text("+$\(Int(fiveYearGain).formatted())")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Net Return:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("$\(Int(fiveYearReturn).formatted())")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(fiveYearReturn > 0 ? .green : .red)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                Section("Skills You'll Learn") {
                    TextField("Enter skills separated by commas", text: $skills, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Text("Example: Python, Data Analysis, Machine Learning")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Learning Investment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveInvestment()
                    }
                    .disabled(name.isEmpty || provider.isEmpty || cost.isEmpty || expectedIncrease.isEmpty)
                }
            }
        }
    }
    
    func saveInvestment() {
        let skillsArray = skills
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let investment = EducationInvestment(
            name: name,
            provider: provider,
            cost: Double(cost) ?? 0,
            isYearly: isYearly,
            duration: Int(duration) ?? 12,
            expectedSalaryIncrease: Double(expectedIncrease) ?? 0,
            skills: skillsArray,
            notes: notes,
            dateAdded: Date()
        )
        
        dataManager.addEducation(investment)
        dismiss()
    }
}

#Preview {
    AddEducationView()
        .environmentObject(DataManager())
}
