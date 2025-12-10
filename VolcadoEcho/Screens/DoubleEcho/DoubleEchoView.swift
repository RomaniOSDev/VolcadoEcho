//
//  DoubleEchoView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

enum DoubleEchoGameState {
    case fieldSizeSelection
    case playing
    case gameOver
}

struct FieldSize {
    let rows: Int
    let cols: Int
    let totalCards: Int
    
    var displayName: String {
        "\(rows)x\(cols)"
    }
}

struct Card: Identifiable {
    let id = UUID()
    let cardType: Int // 1-8
    var isRevealed: Bool = false
    var isMatched: Bool = false
}

struct DoubleEchoView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gameState: DoubleEchoGameState = .fieldSizeSelection
    @State private var cards: [Card] = []
    @State private var selectedCard1: Card?
    @State private var selectedCard2: Card?
    @State private var moves: Int = 0
    @State private var pairsFound: Int = 0
    @State private var record: Int = 0
    @State private var canSelect: Bool = true
    @State private var selectedFieldSize: FieldSize?
    @State private var fieldSizeRows: Int = 2
    @State private var fieldSizeCols: Int = 2
    @State private var level: Int = 1
    @State private var timeLeft: Int = 60 // Время в секундах
    @State private var gameTimer: Timer?
    
    private let availableSizes: [FieldSize] = [
        FieldSize(rows: 2, cols: 2, totalCards: 4),
        FieldSize(rows: 2, cols: 3, totalCards: 6),
        FieldSize(rows: 3, cols: 4, totalCards: 12),
        FieldSize(rows: 4, cols: 4, totalCards: 16)
    ]
    
    private var totalPairs: Int {
        (selectedFieldSize?.totalCards ?? 4) / 2
    }
    
    var body: some View {
        ZStack {
            BackMainView()
                .ignoresSafeArea()
            VStack{
                HStack {
                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Image(.backBTN)
                            .resizable()
                            .frame(width: 56, height: 56)
                    }
                    .padding()
                    Spacer()
                }
                
                .background {
                    LinearGradient(colors: [.startMianGradient, .endMaingradient], startPoint: .top, endPoint: .bottom)
                }
                switch gameState {
                case .fieldSizeSelection:
                    fieldSizeSelectionScreen
                case .playing:
                    gameScreen
                case .gameOver:
                    gameOverScreen
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Загружаем рекорд для первого размера по умолчанию
            if let firstSize = availableSizes.first {
                loadRecordForSize(firstSize)
            }
        }
    }
    
    // MARK: - Field Size Selection Screen
    var fieldSizeSelectionScreen: some View {
        VStack(spacing: 30) {
            
            
            // Рекорд вверху
            VStack(spacing: 10) {
                Text("Records")
                    .foregroundStyle(.yellowApp)
                    .font(.title2)
                
                HStack {
                    Spacer()
                    Text("\(record)")
                        .foregroundStyle(.yellowApp)
                        .font(.system(size: 50, weight: .bold))
                    Spacer()
                }
            }
            .padding()
            .background(
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
                        .foregroundStyle(.endMaingradient)
                       // .padding(2)
            
               }
            )
            .padding()
            
            // Выбор размера поля
            VStack(spacing: 20) {
                Text("Field size")
                    .foregroundStyle(.yellowApp)
                    .font(.title2.bold())
                
                VStack(spacing: 15) {
                    ForEach(availableSizes, id: \.displayName) { size in
                        Button {
                            selectedFieldSize = size
                            fieldSizeRows = size.rows
                            fieldSizeCols = size.cols
                            loadRecordForSize(size)
                            startGame()
                        } label: {
                            BackForMainButton(
                                text: size.displayName,
                                iconString: "square.grid.2x2",
                                isAlert: false
                            )
                            .padding(.horizontal, 40)
                        }
                    }
                }
            }
            
            
            
            Spacer()
        }
        
    }
    
    // MARK: - Game Screen
    var gameScreen: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Level: \(level)")
                    .foregroundStyle(.yellowApp)
                    .font(.title2.bold())
                Text("Time left: \(formatTime(timeLeft))")
                    .foregroundStyle(.yellowApp)
                    .font(.title2.bold())
            }
            .padding()
            
            // Игровое поле
            VStack(spacing: 10) {
                Spacer()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: fieldSizeCols), spacing: 8) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .onTapGesture {
                                handleCardTap(card)
                            }
                    }
                }
                .padding()
                
            }
            Spacer()
        }
    }
    
    // MARK: - Game Over Screen
    var gameOverScreen: some View {
        VStack(spacing: 40) {
            Text("Победа!")
                .foregroundStyle(.yellowApp)
                .font(Font.largeTitle.bold())
            
            VStack(spacing: 20) {
                Text("Ходов использовано")
                    .foregroundStyle(.yellowApp)
                    .font(.title2)
                
                Text("\(moves)")
                    .foregroundStyle(.yellowApp)
                    .font(.system(size: 60, weight: .bold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pinkApp.opacity(0.3))
            )
            
            if moves == record && record > 0 {
                Text("Новый рекорд!")
                    .foregroundStyle(.yellowApp)
                    .font(.title.bold())
            }
            
            Button {
                stopTimer()
                level = 1
                gameState = .fieldSizeSelection
                resetGame()
            } label: {
                BackForMainButton(
                    text: "Играть снова",
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
    
    // MARK: - Card View
    struct CardView: View {
        let card: Card
        
        private func cardImageName(for cardType: Int) -> String {
            return "card\(cardType)"
        }
        
        var body: some View {
            
                
                if card.isMatched {
                    // Карта найдена - показываем картинку
                    Image(cardImageName(for: card.cardType))
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .opacity(0.5)
                } else if card.isRevealed {
                    // Карта открыта
                    Image(cardImageName(for: card.cardType))
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    // Карта закрыта
                    Image(.closeCard)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
            }
        
    }
    
    // MARK: - Game Logic
    func startGame() {
        guard let size = selectedFieldSize else { return }
        level = 1 // Сбрасываем уровень при начале новой игры
        resetGame()
        gameState = .playing
        setupCards(for: size)
        startTimer()
    }
    
    func stopGame() {
        stopTimer()
    }
    
    func resetGame() {
        moves = 0
        pairsFound = 0
        cards = []
        selectedCard1 = nil
        selectedCard2 = nil
        canSelect = true
        // Время зависит от уровня - чем выше уровень, тем меньше времени
        // Начинаем с 90 секунд, уменьшаем на 5 секунд каждый уровень (минимум 30 секунд)
        timeLeft = max(30, 90 - (level - 1) * 5)
    }
    
    func startTimer() {
        stopTimer() // Убеждаемся, что предыдущий таймер остановлен
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
            } else {
                // Время вышло
                self.stopTimer()
                self.gameOver()
            }
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    func gameOver() {
        stopTimer()
        gameState = .gameOver
        updateRecord()
    }
    
    func setupCards(for size: FieldSize) {
        let totalCards = size.totalCards
        let pairsCount = totalCards / 2
        
        // Создаем пары карт
        var cardTypes: [Int] = []
        var cardType = 1
        
        // Создаем пары - каждый тип карты встречается дважды
        for _ in 0..<pairsCount {
            cardTypes.append(cardType)
            cardTypes.append(cardType) // Добавляем пару
            cardType = (cardType % 8) + 1
        }
        
        // Перемешиваем карты
        cards = cardTypes.map { Card(cardType: $0) }
        cards.shuffle()
    }
    
    func handleCardTap(_ card: Card) {
        guard canSelect else { return }
        guard !card.isRevealed && !card.isMatched else { return }
        
        if selectedCard1 == nil {
            // Первая выбранная карта
            selectedCard1 = card
            revealCard(card)
        } else if selectedCard2 == nil {
            // Вторая выбранная карта
            // Проверяем, что это не та же самая карта
            if card.id != selectedCard1!.id {
                selectedCard2 = card
                revealCard(card)
                moves += 1
                checkMatch()
            }
        }
    }
    
    func revealCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isRevealed = true
        }
    }
    
    func checkMatch() {
        guard let card1 = selectedCard1, let card2 = selectedCard2 else { return }
        
        canSelect = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if card1.cardType == card2.cardType {
                // Найдена пара!
                markAsMatched(card1)
                markAsMatched(card2)
                pairsFound += 1
                
                if pairsFound >= totalPairs {
                    // Игра завершена - переходим на следующий уровень
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        levelCompleted()
                    }
                } else {
                    canSelect = true
                }
            } else {
                // Не совпали - закрываем карты
                hideCard(card1)
                hideCard(card2)
                canSelect = true
            }
            
            selectedCard1 = nil
            selectedCard2 = nil
        }
    }
    
    func markAsMatched(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isMatched = true
            cards[index].isRevealed = true
        }
    }
    
    func hideCard(_ card: Card) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isRevealed = false
        }
    }
    
    func levelCompleted() {
        // Увеличиваем уровень и начинаем новую игру
        level += 1
        guard let size = selectedFieldSize else { return }
        resetGame()
        setupCards(for: size)
        startTimer()
    }
    
    func endGame() {
        stopTimer()
        gameState = .gameOver
        updateRecord()
    }
    
    func loadRecord() {
        // Загружаем рекорд для выбранного размера или общий
        if let size = selectedFieldSize {
            loadRecordForSize(size)
        } else {
            record = UserDefaults.standard.integer(forKey: "DoubleEchoRecord")
        }
    }
    
    func loadRecordForSize(_ size: FieldSize) {
        let key = "DoubleEchoRecord_\(size.displayName)"
        record = UserDefaults.standard.integer(forKey: key)
    }
    
    func updateRecord() {
        guard let size = selectedFieldSize else { return }
        let key = "DoubleEchoRecord_\(size.displayName)"
        // Рекорд - минимальное количество ходов
        if record == 0 || moves < record {
            record = moves
            UserDefaults.standard.set(record, forKey: key)
        }
    }
}

#Preview {
    DoubleEchoView()
}
