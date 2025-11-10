//
//  AddJobView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//


import SwiftUI

struct AddJobView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title = ""
    @State private var company = ""
    @State private var location = ""
    @State private var salary = ""
    @State private var bonus = ""
    @State private var description = ""
    @State private var remoteOption: RemoteType = .onsite
    
    @State private var healthInsurance = ""
    @State private var retirement401k = ""
    @State private var paidTimeOff = ""
    @State private var educationBudget = ""
    @State private var stockOptions = ""
    @State private var otherBenefits = ""
    
    @State private var workLifeBalance = 5
    @State private var careerGrowth = 5
    @State private var personalRating = 5
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Job Title", text: $title)
                    TextField("Company", text: $company)
                    TextField("Location", text: $location)
                }
                
                Section("Compensation") {
                    TextField("Annual Salary ($)", text: $salary)
                        .keyboardType(.numberPad)
                    TextField("Annual Bonus ($)", text: $bonus)
                        .keyboardType(.numberPad)
                }
                
                Section("Benefits (Annual Value)") {
                    TextField("Health Insurance ($)", text: $healthInsurance)
                        .keyboardType(.numberPad)
                    TextField("401(k) Match ($)", text: $retirement401k)
                        .keyboardType(.numberPad)
                    TextField("Paid Time Off (days)", text: $paidTimeOff)
                        .keyboardType(.numberPad)
                    TextField("Education Budget ($)", text: $educationBudget)
                        .keyboardType(.numberPad)
                    TextField("Stock Options Value ($)", text: $stockOptions)
                        .keyboardType(.numberPad)
                    TextField("Other Benefits", text: $otherBenefits)
                }
                
                Section("Work Arrangement") {
                    Picker("Remote Option", selection: $remoteOption) {
                        ForEach(RemoteType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    Text("Remote value: $\(Int(remoteOption.value).formatted())/year")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Ratings (1-10)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Work-Life Balance: \(workLifeBalance)")
                        Slider(value: Binding(get: { Double(workLifeBalance) },
                                            set: { workLifeBalance = Int($0) }),
                               in: 1...10, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Career Growth: \(careerGrowth)")
                        Slider(value: Binding(get: { Double(careerGrowth) },
                                            set: { careerGrowth = Int($0) }),
                               in: 1...10, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Rating: \(personalRating)")
                        Slider(value: Binding(get: { Double(personalRating) },
                                            set: { personalRating = Int($0) }),
                               in: 1...10, step: 1)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveJob()
                    }
                    .disabled(title.isEmpty || company.isEmpty || salary.isEmpty)
                }
            }
        }
    }
    
    func saveJob() {
        let job = Job(
            title: title,
            company: company,
            location: location,
            salary: Double(salary) ?? 0,
            bonus: Double(bonus) ?? 0,
            description: description,
            healthInsurance: Double(healthInsurance) ?? 0,
            retirement401k: Double(retirement401k) ?? 0,
            paidTimeOff: Int(paidTimeOff) ?? 0,
            educationBudget: Double(educationBudget) ?? 0,
            stockOptions: Double(stockOptions) ?? 0,
            otherBenefits: otherBenefits,
            remoteOption: remoteOption,
            workLifeBalance: workLifeBalance,
            careerGrowth: careerGrowth,
            notes: notes,
            personalRating: personalRating,
            dateAdded: Date()
        )
        
        dataManager.addJob(job)
        dismiss()
    }
}

#Preview {
    AddJobView()
        .environmentObject(DataManager())
}
