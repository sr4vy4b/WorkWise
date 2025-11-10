//
//  AddNoteView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: NoteCategory = .general
    @State private var relatedJobId: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Note Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Category", selection: $category) {
                        ForEach(NoteCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section("Related Job (Optional)") {
                    Picker("Link to Job", selection: $relatedJobId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(dataManager.jobs) { job in
                            Text("\(job.title) - \(job.company)")
                                .tag(job.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    func saveNote() {
        let note = CareerNote(
            title: title,
            content: content,
            category: category,
            dateCreated: Date(),
            dateModified: Date(),
            relatedJobId: relatedJobId
        )
        
        dataManager.addNote(note)
        dismiss()
    }
}

struct NoteDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    let note: CareerNote
    
    @State private var showingDelete = false
    
    var relatedJob: Job? {
        guard let jobId = note.relatedJobId else { return nil }
        return dataManager.jobs.first(where: { $0.id == jobId })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    categoryBadge
                    
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Created: \(note.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Modified: \(note.dateModified, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text(note.content)
                        .font(.body)
                    
                    if let job = relatedJob {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Job")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(job.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(job.company)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive, action: { showingDelete = true }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Delete Note?", isPresented: $showingDelete) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteNote(note)
                    dismiss()
                }
            }
        }
    }
    
    var categoryBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: note.category.icon)
            Text(note.category.rawValue)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(categoryColor.opacity(0.2))
        .foregroundColor(categoryColor)
        .cornerRadius(8)
    }
    
    var categoryColor: Color {
        switch note.category.color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        default: return .gray
        }
    }
}

#Preview {
    AddNoteView()
        .environmentObject(DataManager())
}
