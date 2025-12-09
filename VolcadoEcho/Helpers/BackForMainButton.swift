//
//  Untitled.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

struct BackForMainButton: View {
    var height: CGFloat = 55
    var text: String
    var iconString: String
    var isAlert: Bool = false
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
                .foregroundStyle(isAlert ? .endMaingradient : .yellowApp)
               // .padding(2)
            HStack{
                Image(systemName: iconString)
                Text(text).bold()
                Image(systemName: iconString)
            }
            .foregroundStyle(isAlert ? .yellowApp : .endMaingradient)
                .font(.system(size: height / 2.2 ))
        
    
       }.frame(height: height)
    }
}

#Preview {
    BackForMainButton(text: "Policy", iconString: "star.fill", isAlert: true)
}
