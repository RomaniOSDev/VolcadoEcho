//
//  AchivmentsView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct AchivmentsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            BackMainView()
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.backBTN)
                            .resizable()
                            .frame(width: 56, height: 56)
                    }
                    .padding()
                    
                    Text("Achievements")
                        .foregroundStyle(.yellowApp)
                        .font(.title.bold())
                    
                    Spacer()
                    
                    Text("\(achievementManager.unlockedCount)/23")
                        .foregroundStyle(.yellowApp)
                        .font(.title2.bold())
                        .padding()
                }
                .background {
                    LinearGradient(colors: [.startMianGradient, .endMaingradient], startPoint: .top, endPoint: .bottom)
                }
                
                // Achievements List
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(["General", "Double Echo", "Echo Drop", "Volcado Quiz"], id: \.self) { category in
                            AchievementCategorySection(
                                category: category,
                                achievements: achievementManager.achievements.filter { $0.category == category }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct AchievementCategorySection: View {
    let category: String
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(category)
                .foregroundStyle(.yellowApp)
                .font(.title2.bold())
                .padding(.horizontal)
            
            ForEach(achievements, id: \.id) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.pinkApp.opacity(0.2))
        )
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            // Emoji/Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellowApp : Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Text(achievement.emoji)
                    .font(.system(size: 30))
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
            }
            
            // Title and Description
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .foregroundStyle(achievement.isUnlocked ? .yellowApp : .gray)
                    .font(.headline.bold())
                
                Text(achievement.description)
                    .foregroundStyle(achievement.isUnlocked ? .yellowApp.opacity(0.8) : .gray.opacity(0.6))
                    .font(.subheadline)
            }
            
            Spacer()
            
            // Checkmark
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(achievement.isUnlocked ? Color.pinkApp.opacity(0.2) : Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    AchivmentsView()
}
