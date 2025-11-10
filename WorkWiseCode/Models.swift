//
//  Models.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import Foundation

struct Job: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var company: String
    var location: String
    var salary: Double
    var bonus: Double
    var description: String
    
    var healthInsurance: Double
    var retirement401k: Double
    var paidTimeOff: Int
    var educationBudget: Double
    var stockOptions: Double
    var otherBenefits: String
    
    var remoteOption: RemoteType
    var workLifeBalance: Int
    var careerGrowth: Int
    
    var notes: String
    var personalRating: Int
    var dateAdded: Date
    
    var totalCompensation: Double {
        let ptoValue = Double(paidTimeOff) * salary / 260.0
        return salary + bonus + healthInsurance + retirement401k + ptoValue + educationBudget + stockOptions + remoteOption.value
    }
    
    var benefitsTotal: Double {
        let ptoValue = Double(paidTimeOff) * salary / 260.0
        return healthInsurance + retirement401k + ptoValue + educationBudget + stockOptions + remoteOption.value
    }
    
    var overallScore: Double {
        let compScore = min(totalCompensation / 2000.0, 50.0)
        let balanceScore = Double(workLifeBalance) * 2.0
        let growthScore = Double(careerGrowth) * 1.5
        let ratingScore = Double(personalRating) * 1.5
        return compScore + balanceScore + growthScore + ratingScore
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Job, rhs: Job) -> Bool {
        return lhs.id == rhs.id
    }
}

enum RemoteType: String, Codable, CaseIterable {
    case fullRemote = "Full Remote"
    case hybrid = "Hybrid (2-3 days)"
    case onsite = "On-site"
    
    var value: Double {
        switch self {
        case .fullRemote: return 15000.0
        case .hybrid: return 7500.0
        case .onsite: return 0.0
        }
    }
    
    var icon: String {
        switch self {
        case .fullRemote: return "house.fill"
        case .hybrid: return "building.2.fill"
        case .onsite: return "building.fill"
        }
    }
}

struct EducationInvestment: Identifiable, Codable {
    var id = UUID()
    var name: String
    var provider: String
    var cost: Double
    var isYearly: Bool
    var duration: Int
    var expectedSalaryIncrease: Double
    var skills: [String]
    var notes: String
    var dateAdded: Date
    
    var annualCost: Double {
        isYearly ? cost : (cost / Double(duration) * 12)
    }
    
    var roi: Double {
        if expectedSalaryIncrease <= 0.0 {
            return 0.0
        }
        let fiveYearGain = expectedSalaryIncrease * 5
        let fiveYearCost = annualCost * 5
        return ((fiveYearGain - fiveYearCost) / fiveYearCost) * 100
    }
    
    var breakEvenMonths: Double {
        if expectedSalaryIncrease <= 0.0 {
            return 0.0
        }
        let years = annualCost / expectedSalaryIncrease
        return years * 12
    }
}

struct CareerNote: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var category: NoteCategory
    var dateCreated: Date
    var dateModified: Date
    var relatedJobId: UUID?
}

enum NoteCategory: String, Codable, CaseIterable {
    case interview = "Interview"
    case research = "Research"
    case decision = "Decision"
    case general = "General"
    
    var icon: String {
        switch self {
        case .interview: return "person.2.fill"
        case .research: return "magnifyingglass"
        case .decision: return "checkmark.circle"
        case .general: return "note.text"
        }
    }
    
    var color: String {
        switch self {
        case .interview: return "blue"
        case .research: return "purple"
        case .decision: return "green"
        case .general: return "gray"
        }
    }
}

struct MuseJobResult: Codable {
    let results: [MuseJob]
    let pageCount: Int?
    let page: Int?
    let resultCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case results
        case pageCount = "page_count"
        case page
        case resultCount = "result_count"
    }
}

struct MuseJob: Codable {
    let id: Int?
    let name: String
    let company: MuseCompany
    let locations: [MuseLocation]
    let contents: String
    let levels: [MuseLevel]?
    let publicationDate: String?
    let refs: MuseRefs?
    
    enum CodingKeys: String, CodingKey {
        case id, name, company, locations, contents, levels
        case publicationDate = "publication_date"
        case refs
    }
    
    func toJob() -> Job {
        let estimatedSalary = estimateSalary()
        let remote = detectRemote()
        
        return Job(
            title: name,
            company: company.name,
            location: formatLocation(),
            salary: estimatedSalary,
            bonus: estimatedSalary * 0.1,
            description: cleanDescription(),
            healthInsurance: 8000.0,
            retirement401k: estimatedSalary * 0.06,
            paidTimeOff: 15,
            educationBudget: 1000.0,
            stockOptions: 0.0,
            otherBenefits: "",
            remoteOption: remote,
            workLifeBalance: 7,
            careerGrowth: 7,
            notes: "Found via The Muse API",
            personalRating: 5,
            dateAdded: Date()
        )
    }
    
    func formatLocation() -> String {
        if locations.isEmpty {
            return "Remote"
        }
        return locations.first?.name ?? "Remote"
    }
    
    func cleanDescription() -> String {
        var cleaned = contents.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sentences = cleaned.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var brief = ""
        
        for sentence in sentences {
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 30 {
                brief = trimmed
                break
            }
        }
        
        if brief.isEmpty {
            brief = cleaned
        }
        
        if brief.count > 200 {
            return String(brief.prefix(200)) + "..."
        }
        
        return brief.isEmpty ? "Position available at \(company.name)" : brief
    }
    
    func estimateSalary() -> Double {
        let titleLower = name.lowercased()
        var baseSalary: Double = 75000.0
        
        if titleLower.contains("software") || titleLower.contains("engineer") || titleLower.contains("developer") {
            baseSalary = 95000.0
        } else if titleLower.contains("data scientist") || titleLower.contains("machine learning") {
            baseSalary = 110000.0
        } else if titleLower.contains("product manager") {
            baseSalary = 105000.0
        } else if titleLower.contains("designer") || titleLower.contains("ux") || titleLower.contains("ui") {
            baseSalary = 80000.0
        } else if titleLower.contains("marketing") || titleLower.contains("social media") {
            baseSalary = 60000.0
        } else if titleLower.contains("sales") {
            baseSalary = 65000.0
        } else if titleLower.contains("analyst") {
            baseSalary = 70000.0
        } else if titleLower.contains("manager") && !titleLower.contains("product") {
            baseSalary = 85000.0
        }
        
        guard let levels = levels, !levels.isEmpty else {
            return baseSalary
        }
        
        let levelName = levels[0].name.lowercased()
        
        if levelName.contains("senior") || levelName.contains("sr.") {
            return baseSalary * 1.4
        } else if levelName.contains("lead") {
            return baseSalary * 1.6
        } else if levelName.contains("principal") || levelName.contains("staff") {
            return baseSalary * 1.8
        } else if levelName.contains("mid") {
            return baseSalary * 1.1
        } else if levelName.contains("junior") || levelName.contains("jr.") || levelName.contains("entry") {
            return baseSalary * 0.8
        }
        
        return baseSalary
    }
    
    func detectRemote() -> RemoteType {
        let text = (name + " " + contents).lowercased()
        
        if text.contains("remote") || text.contains("work from home") || text.contains("wfh") {
            if text.contains("hybrid") {
                return .hybrid
            }
            return .fullRemote
        }
        
        for location in locations {
            if location.name.lowercased().contains("remote") {
                return .fullRemote
            }
        }
        
        return .onsite
    }
}

struct MuseCompany: Codable {
    let id: Int?
    let name: String
    let shortName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case shortName = "short_name"
    }
}

struct MuseLocation: Codable {
    let name: String
}

struct MuseLevel: Codable {
    let name: String
    let shortName: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case shortName = "short_name"
    }
}

struct MuseRefs: Codable {
    let landingPage: String?
    
    enum CodingKeys: String, CodingKey {
        case landingPage = "landing_page"
    }
}

struct AdzunaJobResult: Codable {
    let results: [AdzunaJob]
}

struct AdzunaJob: Codable {
    let id: String
    let title: String
    let company: AdzunaCompany
    let location: AdzunaLocation
    let description: String
    let salary_min: Double?
    let salary_max: Double?
    let contract_time: String?
    
    func toJob() -> Job {
        let avgSalary: Double
        if let min = salary_min, let max = salary_max, min > 0.0, max > 0.0 {
            let rawAvg = (min + max) / 2.0
            avgSalary = rawAvg > 500000.0 ? 85000.0 : rawAvg
        } else if let min = salary_min, min > 0.0 {
            avgSalary = min > 500000.0 ? 85000.0 : min
        } else if let max = salary_max, max > 0.0 {
            avgSalary = max > 500000.0 ? 85000.0 : max
        } else {
            avgSalary = 75000.0
        }
        
        let remote = detectRemote()
        
        var cleanedDesc = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        cleanedDesc = cleanedDesc.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedDesc = cleanedDesc.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedDesc.count > 200 {
            cleanedDesc = String(cleanedDesc.prefix(200)) + "..."
        }
        
        return Job(
            title: title,
            company: company.display_name,
            location: location.display_name,
            salary: avgSalary,
            bonus: avgSalary * 0.1,
            description: cleanedDesc,
            healthInsurance: 8000.0,
            retirement401k: avgSalary * 0.06,
            paidTimeOff: 15,
            educationBudget: 1000.0,
            stockOptions: 0.0,
            otherBenefits: "",
            remoteOption: remote,
            workLifeBalance: 7,
            careerGrowth: 7,
            notes: "Found via Adzuna",
            personalRating: 5,
            dateAdded: Date()
        )
    }
    
    func detectRemote() -> RemoteType {
        let text = "\(title) \(description)".lowercased()
        if text.contains("remote") || text.contains("work from home") {
            return text.contains("hybrid") ? .hybrid : .fullRemote
        }
        return .onsite
    }
}

struct AdzunaCompany: Codable {
    let display_name: String
}

struct AdzunaLocation: Codable {
    let display_name: String
}

struct RemotiveJobResult: Codable {
    let jobs: [RemotiveJob]
}

struct RemotiveJob: Codable {
    let id: Int
    let title: String
    let company_name: String
    let job_type: String
    let description: String
    let salary: String?
    
    func toJob() -> Job {
        let estimatedSalary = parseSalary()
        
        var cleanedDesc = description
        cleanedDesc = cleanedDesc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        cleanedDesc = cleanedDesc.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedDesc = cleanedDesc.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedDesc.count > 200 {
            cleanedDesc = String(cleanedDesc.prefix(200)) + "..."
        }
        
        return Job(
            title: title,
            company: company_name,
            location: "Remote",
            salary: estimatedSalary,
            bonus: estimatedSalary * 0.1,
            description: cleanedDesc,
            healthInsurance: 8000.0,
            retirement401k: estimatedSalary * 0.06,
            paidTimeOff: 20,
            educationBudget: 1500.0,
            stockOptions: 0.0,
            otherBenefits: "",
            remoteOption: .fullRemote,
            workLifeBalance: 8,
            careerGrowth: 7,
            notes: "Remote position via Remotive",
            personalRating: 6,
            dateAdded: Date()
        )
    }
    
    func parseSalary() -> Double {
        guard let salary = salary else { return 75000.0 }
        
        let cleaned = salary.lowercased()
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "usd", with: "")
            .replacingOccurrences(of: "per year", with: "")
            .replacingOccurrences(of: "/year", with: "")
            .replacingOccurrences(of: "k", with: "000")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let numbers = cleaned.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        
        if let firstNum = numbers.first, let value = Double(firstNum) {
            if value > 20.0 && value < 500.0 {
                return value * 1000.0
            }
            if value >= 20000.0 && value <= 500000.0 {
                return value
            }
        }
        
        return 85000.0
    }
}

struct ReedJobResult: Codable {
    let results: [ReedJob]
}

struct ReedJob: Codable {
    let jobId: Int
    let jobTitle: String
    let employerName: String
    let locationName: String
    let jobDescription: String
    let minimumSalary: Double?
    let maximumSalary: Double?
    
    func toJob() -> Job {
        let avgSalary: Double
        if let minSal = minimumSalary, let maxSal = maximumSalary, minSal > 0.0, maxSal > 0.0 {
            let rawAvg = (minSal + maxSal) / 2.0
            let cappedAvg = rawAvg > 150000.0 ? 150000.0 : rawAvg
            avgSalary = cappedAvg * 1.27
        } else if let minSal = minimumSalary, minSal > 0.0 {
            let cappedMin = minSal > 150000.0 ? 150000.0 : minSal
            avgSalary = cappedMin * 1.27
        } else if let maxSal = maximumSalary, maxSal > 0.0 {
            let cappedMax = maxSal > 150000.0 ? 150000.0 : maxSal
            avgSalary = cappedMax * 1.27
        } else {
            avgSalary = 70000.0
        }
        
        var cleanedDesc = jobDescription
        cleanedDesc = cleanedDesc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        cleanedDesc = cleanedDesc.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        cleanedDesc = cleanedDesc.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanedDesc.count > 200 {
            cleanedDesc = String(cleanedDesc.prefix(200)) + "..."
        }
        
        return Job(
            title: jobTitle,
            company: employerName,
            location: locationName,
            salary: avgSalary,
            bonus: avgSalary * 0.08,
            description: cleanedDesc,
            healthInsurance: 6000.0,
            retirement401k: avgSalary * 0.05,
            paidTimeOff: 20,
            educationBudget: 1000.0,
            stockOptions: 0.0,
            otherBenefits: "",
            remoteOption: .onsite,
            workLifeBalance: 7,
            careerGrowth: 6,
            notes: "UK position via Reed",
            personalRating: 5,
            dateAdded: Date()
        )
    }
}
