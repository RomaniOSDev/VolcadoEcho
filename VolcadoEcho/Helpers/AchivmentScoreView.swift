//
//  AchivmentScoreView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI

struct AchivmentScoreView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    var score: Int
    
    var body: some View {
        ZStack {
            // Внешний градиент для выпуклости
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.pinkApp,
                            Color.pinkApp
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.pinkApp.opacity(0.2), radius: 5, x: -5, y: -5) // Тень для выпуклости
                .shadow(color: Color.pinkApp.opacity(0.2), radius: 5, x: 5, y: 5) // Тень для углубления
            
            // Внутренний фон для TextField
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.yellowApp)
               // .padding(2)
            HStack{
                Image(systemName: "cup.and.saucer.fill")
                Text("\(achievementManager.unlockedCount)/23").bold()
                
            }
            .foregroundStyle(.endMaingradient)
                .font(.system(size: 22 ))
        
    
       }.frame(height: 58)
            .frame(width: 130)
    }
}

#Preview {
    AchivmentScoreView(score: 0)
}
