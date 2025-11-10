//
//  WelcomeView.swift
//  WorkWise
//
//  Created by Sravya Bayaneni on 11/8/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [WorkWiseTheme.lightGreen.opacity(0.1), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showWelcome = false
                        }
                    }) {
                        Text("Skip")
                            .foregroundColor(WorkWiseTheme.primaryGreen)
                            .padding()
                    }
                }
                
                TabView(selection: $currentPage) {
                    WelcomePage1()
                        .tag(0)
                    WelcomePage2()
                        .tag(1)
                    WelcomePage3()
                        .tag(2)
                    WelcomePage4()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 16) {
                    if currentPage == 3 {
                        Button(action: {
                            withAnimation {
                                showWelcome = false
                            }
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(WorkWiseTheme.primaryGradient)
                                .cornerRadius(16)
                                .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(WorkWiseTheme.primaryGradient)
                                .cornerRadius(16)
                                .shadow(color: WorkWiseTheme.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
struct WelcomePage1: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            WorkWiseLogo(size: 120, showText: true)
            
            Text("Make Better Career Decisions")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            Text("Compare job offers beyond just salary. See the full picture: benefits, work-life balance, and long-term value.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct WelcomePage2: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(WorkWiseTheme.lightGreen.opacity(0.3))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
            }
            
            Text("Search & Compare Jobs")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            VStack(alignment: .leading, spacing: 16) {
                FeaturePoint(
                    icon: "magnifyingglass",
                    text: "Search thousands of jobs across multiple platforms"
                )
                FeaturePoint(
                    icon: "dollarsign.circle.fill",
                    text: "See total compensation including all benefits"
                )
                FeaturePoint(
                    icon: "chart.bar.fill",
                    text: "Compare up to 4 jobs side-by-side"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct WelcomePage3: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(WorkWiseTheme.lightGreen.opacity(0.3))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
            }
            
            Text("Uncover Hidden Value")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            VStack(alignment: .leading, spacing: 16) {
                FeaturePoint(
                    icon: "heart.fill",
                    text: "Health insurance, 401(k) matching, PTO value"
                )
                FeaturePoint(
                    icon: "house.fill",
                    text: "Remote work savings ($15K+ per year)"
                )
                FeaturePoint(
                    icon: "graduationcap.fill",
                    text: "Education budgets and stock options"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct WelcomePage4: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(WorkWiseTheme.lightGreen.opacity(0.3))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 70))
                    .foregroundStyle(WorkWiseTheme.primaryGradient)
            }
            
            Text("Invest in Your Growth")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(WorkWiseTheme.primaryGradient)
            
            VStack(alignment: .leading, spacing: 16) {
                FeaturePoint(
                    icon: "graduationcap.fill",
                    text: "Track learning investments and their ROI"
                )
                FeaturePoint(
                    icon: "chart.xyaxis.line",
                    text: "Calculate break-even time and salary increases"
                )
                FeaturePoint(
                    icon: "note.text",
                    text: "Keep notes on interviews and decisions"
                )
            }
            .padding(.horizontal, 32)
            
            Text("Ready to make smarter career choices?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct FeaturePoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(WorkWiseTheme.primaryGreen)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    WelcomeView(showWelcome: .constant(true))
}
