//
//  WorkWiseTheme.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct WorkWiseTheme {
    static let primaryGreen = Color(red: 0.2, green: 0.7, blue: 0.4)
    static let darkGreen = Color(red: 0.1, green: 0.5, blue: 0.3)
    static let lightGreen = Color(red: 0.8, green: 0.95, blue: 0.85)
    static let accentGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let info = Color(red: 0.2, green: 0.6, blue: 0.8)
    
    static let primaryGradient = LinearGradient(
        colors: [primaryGreen, darkGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [lightGreen.opacity(0.3), Color.white],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.white, lightGreen.opacity(0.2)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct WorkWiseLogo: View {
    var size: CGFloat = 80
    var showText: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(WorkWiseTheme.primaryGradient)
                    .frame(width: size, height: size)
                    .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                
                ZStack {
                    ForEach(0..<4) { i in
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 3, height: size * 0.35)
                            .offset(y: -size * 0.15)
                            .rotationEffect(.degrees(Double(i) * 90))
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: size * 0.4, height: size * 0.5)
                    
                    Capsule()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: size * 0.25, height: size * 0.15)
                        .offset(y: -size * 0.25)
                    
                    Circle()
                        .fill(WorkWiseTheme.accentGold)
                        .frame(width: size * 0.15, height: size * 0.15)
                }
            }
            
            if showText {
                Text("WorkWise")
                    .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(WorkWiseTheme.primaryGradient)
            .cornerRadius(12)
            .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(WorkWiseTheme.primaryGreen)
            .padding()
            .frame(maxWidth: .infinity)
            .background(WorkWiseTheme.lightGreen)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(WorkWiseTheme.primaryGreen, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ThemedCard<Content: View>: View {
    let content: Content
    var gradient: Bool = false
    
    init(gradient: Bool = false, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                Group {
                    if gradient {
                        WorkWiseTheme.cardGradient
                    } else {
                        Color(.systemBackground)
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(WorkWiseTheme.primaryGreen.opacity(0.1), lineWidth: 1)
            )
    }
}

struct ThemedSectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
            }
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ThemedBadge: View {
    let text: String
    let icon: String?
    let color: Color
    
    init(_ text: String, icon: String? = nil, color: Color = WorkWiseTheme.primaryGreen) {
        self.text = text
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            WorkWiseLogo(size: 100, showText: true)
            
            Button("Primary Button") {}
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
            
            Button("Secondary Button") {}
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal)
            
            ThemedCard {
                VStack(alignment: .leading, spacing: 12) {
                    ThemedSectionHeader("Sample Card", icon: "briefcase.fill")
                    Text("This is a themed card with the WorkWise design system")
                    HStack {
                        ThemedBadge("Remote", icon: "house.fill")
                        ThemedBadge("$120K", icon: "dollarsign.circle", color: WorkWiseTheme.success)
                    }
                }
            }
            .padding()
        }
        .background(WorkWiseTheme.backgroundGradient)
    }
}
