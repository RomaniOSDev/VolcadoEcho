//
//  Settingsview.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI
import StoreKit

struct Settingsview: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Settings overlay content
            VStack(spacing: 20) {
                Text("Settings")
                    .foregroundStyle(.yellowApp)
                    .font(.title.bold())
                    .padding(.top, 20)
                
                VStack(spacing: 15) {
                    Button {
                        // Policy action
                        openPolicy()
                    } label: {
                        BackForMainButton(
                            text: "Policy",
                            iconString: "doc.text.fill",
                            isAlert: false
                        )
                        .padding(.horizontal, 40)
                    }
                    
                    Button {
                        // RateUs action
                        rateUs()
                    } label: {
                        BackForMainButton(
                            text: "RateUs",
                            iconString: "star.fill",
                            isAlert: false
                        )
                        .padding(.horizontal, 40)
                    }
                    
                    Button {
                        // Reset app action
                        resetApp()
                    } label: {
                        BackForMainButton(
                            text: "Reset app",
                            iconString: "arrow.clockwise",
                            isAlert: true
                        )
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.endMaingradient)
                    .shadow(color: .pinkApp, radius: 10)
            )
            .padding(.horizontal, 40)
        }
    }
    
    func openPolicy() {
        // Open policy URL or show policy view
        if let url = URL(string: "https://www.freeprivacypolicy.com/live/2a208994-b078-470a-8764-1fd45b932d52") {
            UIApplication.shared.open(url)
        }
        isPresented = false
    }
    
    func rateUs() {
        SKStoreReviewController.requestReview()
        isPresented = false
    }
    
    func resetApp() {
        // Reset all app data
        // Clear all UserDefaults records
        UserDefaults.standard.removeObject(forKey: "EchoDropRecord")
        UserDefaults.standard.removeObject(forKey: "DoubleEchoRecord_2x2")
        UserDefaults.standard.removeObject(forKey: "DoubleEchoRecord_2x3")
        UserDefaults.standard.removeObject(forKey: "DoubleEchoRecord_3x4")
        UserDefaults.standard.removeObject(forKey: "DoubleEchoRecord_4x4")
        UserDefaults.standard.removeObject(forKey: "VolcadoQuizRecord_Easy")
        UserDefaults.standard.removeObject(forKey: "VolcadoQuizRecord_Medium")
        UserDefaults.standard.removeObject(forKey: "VolcadoQuizRecord_Hard")
        
        // Clear achievement data
        for achievementID in AchievementID.allCases {
            UserDefaults.standard.removeObject(forKey: "achievement_\(achievementID.rawValue)")
        }
        
        // Clear tracking data
        UserDefaults.standard.removeObject(forKey: "totalGamesPlayed")
        UserDefaults.standard.removeObject(forKey: "gamePlayed_DoubleEcho")
        UserDefaults.standard.removeObject(forKey: "gamePlayed_EchoDrop")
        UserDefaults.standard.removeObject(forKey: "gamePlayed_VolcadoQuiz")
        UserDefaults.standard.removeObject(forKey: "totalPairsMatched")
        UserDefaults.standard.removeObject(forKey: "consecutiveLevelsCompleted_DoubleEcho")
        UserDefaults.standard.removeObject(forKey: "totalItemsCollected")
        UserDefaults.standard.removeObject(forKey: "consecutiveCorrectAnswers")
        UserDefaults.standard.removeObject(forKey: "perfectQuiz_Easy")
        UserDefaults.standard.removeObject(forKey: "perfectQuiz_Medium")
        UserDefaults.standard.removeObject(forKey: "perfectQuiz_Hard")
        
        // Reload achievements
        AchievementManager.shared.loadAchievements()
        
        isPresented = false
    }
}

#Preview {
    Settingsview(isPresented: .constant(true))
}
