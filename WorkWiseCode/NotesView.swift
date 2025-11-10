//
//  NotesView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//
import SwiftUI

struct NotesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAdd = false
    @State private var selectedNote: CareerNote?
    @State private var filterCategory: NoteCategory?
    
    var filteredNotes: [CareerNote] {
        if let category = filterCategory {
            return dataManager.notes.filter { $0.category == category }
        }
        return dataManager.notes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WorkWiseTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    categoryFilter
                    
                    if filteredNotes.isEmpty {
                        emptyState
                    } else {
                        notesList
                    }
                }
            }
            .navigationTitle("Notes & Research")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddNoteView()
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note)
            }
        }
    }
    
    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(title: "All", isSelected: filterCategory == nil) {
                    filterCategory = nil
                }
                
                ForEach(NoteCategory.allCases, id: \.self) { category in
                    FilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: filterCategory == category
                    ) {
                        filterCategory = category
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    var notesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredNotes.sorted(by: { $0.dateModified > $1.dateModified })) { note in
                    NoteCard(note: note)
                        .onTapGesture {
                            selectedNote = note
                        }
                }
            }
            .padding()
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.bold)
            Text("Keep track of interviews, research, and decisions")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(action: { showingAdd = true }) {
                Label("Add First Note", systemImage: "plus.circle.fill")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct FilterButton: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct NoteCard: View {
    let note: CareerNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: note.category.icon)
                    .foregroundColor(categoryColor)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                    Text(note.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(note.dateModified, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
    NotesView()
        .environmentObject(DataManager())
}
