//
//  EchoDropView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

enum GameState {
    case start
    case playing
    case gameOver
}

struct FallingItem: Identifiable {
    let id = UUID()
    let imageName: String
    var position: CGPoint
    var points: Int
    var restoresLife: Bool = false
    var removesLife: Bool = false
}

struct EchoDropView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var gameState: GameState = .start
    @State private var score: Int = 0
    @State private var lives: Int = 3
    @State private var record: Int = 0
    @State private var fallingItems: [FallingItem] = []
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var screenSize: CGSize = .zero
    @State private var fallSpeed: CGFloat = 3.0
    @State private var lastSpeedLevel: Int = 0
    
    // Achievement tracking
    @State private var bombsCaughtThisGame: Int = 0
    @State private var itemsCaughtThisGame: Int = 0
    
    private let itemTypes: [(name: String, points: Int, restoresLife: Bool, removesLife: Bool)] = [
        ("coin1", 1, false, false),
        ("coin2", 1, false, false),
        ("coin3", 1, false, false),
        ("coin4", 1, false, false),
        ("circle1", 5, false, false),
        ("circle2", 5, false, false),
        ("circle3", 5, false, false),
        ("circle4", 5, false, false),
        ("vulcan1", 50, false, false),
        ("vulcan2", 0, true, false),
        ("bomb", 0, false, true)
    ]
    
    var body: some View {
        ZStack {
            BackMainView()
                .ignoresSafeArea()
            VStack{
                HStack {
                    Button {
                        dismiss()
                        if gameState == .playing {
                            stopGame()
                            gameState = .start
                        }
                    } label: {
                        Image(.backBTN)
                            .resizable()
                            .frame(width: 56, height: 56)
                    }
                    .padding()
                    Text("Echo Drop")
                        .foregroundStyle(.yellowApp)
                        .font(Font.title.bold())
                    Spacer()
                    
                    if gameState == .playing {
                        // Lives indicator
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Image(.vulcan2)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .opacity(index < lives ? 1 : 0.3)
                            }
                        }.padding()
                    }
                }
                
                .background {
                    LinearGradient(colors: [.startMianGradient, .endMaingradient], startPoint: .top, endPoint: .bottom)
                }
                
                switch gameState {
                case .start:
                    startScreen
                case .playing:
                    gameScreen
                case .gameOver:
                    gameOverScreen
                }
                
                if gameState == .playing {
                    // Score display
                    HStack {
                        VStack {
                            Text("Score")
                            Text("\(score)")
                                
                                                            
                        }
                        .foregroundStyle(.yellowApp)
                        .font(.system(size: 24, weight: .bold))
                        .padding()
                       Spacer()
                    }
                    .background {
                        LinearGradient(colors: [.startMianGradient, .endMaingradient], startPoint: .top, endPoint: .bottom)
                    }
                }
                
            }
            .navigationBarBackButtonHidden()
        }
        .onAppear {
            loadRecord()
        }
    }
    
    // MARK: - Start Screen
    var startScreen: some View {
        VStack(spacing: 40) {
            
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("Records")
                        .foregroundStyle(.yellowApp)
                        .font(.title2)
                    Spacer()
                }
                
                Text("\(record)")
                    .foregroundStyle(.yellowApp)
                    .font(.system(size: 60, weight: .bold))
            }
            .shadow(color: .pinkApp, radius: 3)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.endMaingradient)
                    .shadow(color: .pinkApp, radius: 5)
                    
            )
            
            
            Button {
                startGame()
            } label: {
                BackForMainButton(
                    text: "Start",
                    iconString: "play.fill",
                    isAlert: false
                )
                .padding(.horizontal, 40)
            }
            
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Game Screen
    var gameScreen: some View {
        GeometryReader { geometry in
            ZStack {
                // Falling items
                ForEach(fallingItems) { item in
                    Image(item.imageName)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .position(item.position)
                        .onTapGesture {
                            handleItemTap(item)
                        }
                }
            }
            .onAppear {
                screenSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                screenSize = newSize
            }
        }
    }
    
    // MARK: - Game Over Screen
    var gameOverScreen: some View {
        VStack(spacing: 40) {
            Text("Game Over")
                .foregroundStyle(.yellowApp)
                .font(Font.largeTitle.bold())
            
            VStack(spacing: 20) {
                Text("Your Score")
                    .foregroundStyle(.yellowApp)
                    .font(.title2)
                
                Text("\(score)")
                    .foregroundStyle(.yellowApp)
                    .font(.system(size: 60, weight: .bold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pinkApp.opacity(0.3))
            )
            
            if score == record && score > 0 {
                Text("New Record!")
                    .foregroundStyle(.yellowApp)
                    .font(.title.bold())
            }
            
            Button {
                gameState = .start
                resetGame()
            } label: {
                BackForMainButton(
                    text: "Play Again",
                    iconString: "arrow.clockwise",
                    isAlert: false
                )
                .padding(.horizontal, 40)
            }
            
            Button {
                dismiss()
            } label: {
                Image(.backBTN)
                    .resizable()
                    .frame(width: 56, height: 56)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Game Logic
    func startGame() {
        resetGame()
        gameState = .playing
        bombsCaughtThisGame = 0
        itemsCaughtThisGame = 0
        
        // Track game played
        achievementManager.trackGamePlayed(gameMode: "EchoDrop")
        
        // Небольшая задержка, чтобы размер экрана успел определиться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startGameTimers()
        }
    }
    
    func startGameTimers() {
        // Используем размер экрана из GeometryReader или UIScreen как запасной вариант
        var currentSize = screenSize
        if currentSize.width == 0 || currentSize.height == 0 {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                currentSize = window.bounds.size
                screenSize = currentSize
            } else {
                // Если размер еще не определен, пробуем еще раз через небольшое время
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    startGameTimers()
                }
                return
            }
        }
        
        // Timer to move items down (60 FPS)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateFallingItems()
        }
        
        // Timer to spawn new items
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            spawnRandomItem()
        }
        
        // Сразу спавним первый предмет
        spawnRandomItem()
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    func resetGame() {
        score = 0
        lives = 3
        fallingItems = []
        fallSpeed = 3.0
        lastSpeedLevel = 0
        bombsCaughtThisGame = 0
        itemsCaughtThisGame = 0
        stopGame()
    }
    
    func spawnRandomItem() {
        DispatchQueue.main.async {
            guard screenSize.width > 0 else { return }
            
            let randomX = CGFloat.random(in: 60...(screenSize.width - 60))
            let randomItemType = itemTypes.randomElement()!
            
            let newItem = FallingItem(
                imageName: randomItemType.name,
                position: CGPoint(x: randomX, y: -30),
                points: randomItemType.points,
                restoresLife: randomItemType.restoresLife,
                removesLife: randomItemType.removesLife
            )
            
            fallingItems.append(newItem)
        }
    }
    
    func updateFallingItems() {
        DispatchQueue.main.async {
            guard screenSize.height > 0 else { return }
            
            // Move items down and collect items to remove
            var itemsToRemove: [UUID] = []
            
            for index in fallingItems.indices {
                fallingItems[index].position.y += fallSpeed
                
                // Remove items that fell off screen
                if fallingItems[index].position.y > screenSize.height + 50 {
                    itemsToRemove.append(fallingItems[index].id)
                }
            }
            
            // Remove items that fell off screen
            fallingItems.removeAll { item in
                itemsToRemove.contains(item.id)
            }
        }
    }
    
    func handleItemTap(_ item: FallingItem) {
        // Remove the tapped item
        if let index = fallingItems.firstIndex(where: { $0.id == item.id }) {
            fallingItems.remove(at: index)
        }
        
        // Handle item effects
        if item.restoresLife {
            lives = min(lives + 1, 3)
            itemsCaughtThisGame += 1
            
            // First Catch achievement
            achievementManager.unlock(.firstCatch)
            
            // Track total items collected
            let totalItems = UserDefaults.standard.integer(forKey: "totalItemsCollected")
            UserDefaults.standard.set(totalItems + 1, forKey: "totalItemsCollected")
            if totalItems + 1 >= 150 {
                achievementManager.unlock(.lavaCollector)
            }
        } else if item.removesLife {
            // Бомба забирает жизнь только при нажатии
            bombsCaughtThisGame += 1
            lives -= 1
            
            // Ash Mistake achievement
            if bombsCaughtThisGame >= 5 {
                achievementManager.unlock(.ashMistake)
            }
            
            checkGameOver()
        } else {
            itemsCaughtThisGame += 1
            score += item.points
            
            // First Catch achievement
            achievementManager.unlock(.firstCatch)
            
            // Track total items collected
            let totalItems = UserDefaults.standard.integer(forKey: "totalItemsCollected")
            UserDefaults.standard.set(totalItems + 1, forKey: "totalItemsCollected")
            if totalItems + 1 >= 150 {
                achievementManager.unlock(.lavaCollector)
            }
            
            // Check score achievements
            if score >= 2000 {
                achievementManager.unlock(.echoAvalanche)
            }
            if score >= 10000 {
                achievementManager.unlock(.masterOfFalls)
            }
            
            // Volcado Never Gives Up - score 500 with one life
            if lives == 1 && score >= 500 {
                achievementManager.unlock(.volcadoNeverGivesUp)
            }
            
            // Увеличиваем скорость каждые 200 очков
            updateFallSpeed()
        }
    }
    
    func updateFallSpeed() {
        let currentSpeedLevel = score / 200
        if currentSpeedLevel > lastSpeedLevel {
            lastSpeedLevel = currentSpeedLevel
            // Увеличиваем скорость на 1.5 каждые 200 очков
            fallSpeed += 1.5
        }
    }
    
    func checkGameOver() {
        if lives <= 0 {
            stopGame()
            updateRecord()
            gameState = .gameOver
        }
    }
    
    func loadRecord() {
        record = UserDefaults.standard.integer(forKey: "EchoDropRecord")
    }
    
    func updateRecord() {
        if score > record {
            record = score
            UserDefaults.standard.set(record, forKey: "EchoDropRecord")
        }
    }
}

#Preview {
    EchoDropView()
}
