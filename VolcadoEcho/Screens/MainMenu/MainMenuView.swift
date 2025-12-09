//
//  MainMenuView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                BackMainView()
                    .ignoresSafeArea()
                VStack{
                    //MARK: - top bar
                    HStack{
                        Spacer()
                        NavigationLink {
                            Settingsview()
                        } label: {
                            Image(.settingsbuttin)
                                .resizable()
                                .frame(width: 55, height: 55)
                        }

                    }
                    Spacer()
                    //MARK: - Main logo image
                    Image(.mainLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    //MARK: - Button Gruop
                    VStack(spacing: 20){
                        NavigationLink {
                            DoubleEchoView()
                        } label: {
                            BackForMainButton(text: "Double Echo", iconString: "document.on.clipboard.fill")
                        }
                        NavigationLink {
                            EchoDropView()
                        } label: {
                            BackForMainButton(text: "Echo Drop", iconString: "square.2.stack.3d.top.filled")
                        }
                        NavigationLink {
                            VolcadoQuizView()
                        } label: {
                            BackForMainButton(text: "Volcado Quiz", iconString: "square.stack.fill")
                        }

                    }
                    Spacer()
                }.padding()
            }
        }
    }
}

#Preview {
    MainMenuView()
}
