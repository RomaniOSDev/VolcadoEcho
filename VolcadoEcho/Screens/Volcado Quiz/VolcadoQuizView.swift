//
//  VolcadoQuizView.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 08.12.2025.
//

import SwiftUI

enum QuizDifficulty {
    case easy
    case medium
    case hard
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

enum QuizGameState {
    case difficultySelection
    case playing
    case results
}

struct QuizQuestion {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int // Индекс правильного ответа (0, 1, или 2)
}

struct VolcadoQuizView: View {
    @Environment(\.dismiss) var dismiss
    @State private var gameState: QuizGameState = .difficultySelection
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var currentQuestionIndex: Int = 0
    @State private var score: Int = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showAnswer: Bool = false
    @State private var questions: [QuizQuestion] = []
    @State private var record: Int = 0
    
    var body: some View {
        ZStack {
            BackMainView()
                .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        stopQuiz()
                        dismiss()
                    } label: {
                        Image(.backBTN)
                            .resizable()
                            .frame(width: 56, height: 56)
                    }
                    .padding()
                    Spacer()
                }
                
                switch gameState {
                case .difficultySelection:
                    difficultySelectionScreen
                case .playing:
                    quizScreen
                case .results:
                    resultsScreen
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            loadRecord()
        }
    }
    
    // MARK: - Difficulty Selection Screen
    var difficultySelectionScreen: some View {
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
                        .shadow(color: Color.pinkApp.opacity(0.2), radius: 5, x: -5, y: -5)
                        .shadow(color: Color.pinkApp.opacity(0.2), radius: 5, x: 5, y: 5)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.endMaingradient)
                }
            )
            .padding()
            
            // Выбор уровня сложности
            VStack(spacing: 20) {
                Text("Select Difficulty")
                    .foregroundStyle(.yellowApp)
                    .font(.title2.bold())
                
                VStack(spacing: 15) {
                    Button {
                        selectedDifficulty = .easy
                        loadRecordForDifficulty(.easy)
                        startQuiz(difficulty: .easy)
                    } label: {
                        BackForMainButton(
                            text: "Easy",
                            iconString: "star.fill",
                            isAlert: false
                        )
                        .padding(.horizontal, 40)
                    }
                    
                    Button {
                        selectedDifficulty = .medium
                        loadRecordForDifficulty(.medium)
                        startQuiz(difficulty: .medium)
                    } label: {
                        BackForMainButton(
                            text: "Medium",
                            iconString: "star.fill",
                            isAlert: false
                        )
                        .padding(.horizontal, 40)
                    }
                    
                    Button {
                        selectedDifficulty = .hard
                        loadRecordForDifficulty(.hard)
                        startQuiz(difficulty: .hard)
                    } label: {
                        BackForMainButton(
                            text: "Hard",
                            iconString: "star.fill",
                            isAlert: false
                        )
                        .padding(.horizontal, 40)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Quiz Screen
    var quizScreen: some View {
        VStack(spacing: 30) {
            // Прогресс
            VStack(spacing: 10) {
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .foregroundStyle(.yellowApp)
                    .font(.headline)
                
                ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellowApp))
                    .frame(height: 8)
            }
            .padding()
            
            // Вопрос
            VStack(spacing: 20) {
                Text(questions[currentQuestionIndex].question)
                    .foregroundStyle(.yellowApp)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pinkApp.opacity(0.3))
            )
            .padding(.horizontal)
            
            // Варианты ответов
            VStack(spacing: 15) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button {
                        if !showAnswer {
                            selectedAnswer = index
                            showAnswer = true
                            
                            // Проверяем ответ через небольшую задержку
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                checkAnswer(index)
                            }
                        }
                    } label: {
                        HStack {
                            Text(questions[currentQuestionIndex].options[index])
                                .foregroundStyle(.yellowApp)
                                .font(.title3)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            
                            if showAnswer {
                                if index == questions[currentQuestionIndex].correctAnswer {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.title2)
                                } else if index == selectedAnswer && index != questions[currentQuestionIndex].correctAnswer {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    showAnswer && index == questions[currentQuestionIndex].correctAnswer ? Color.green.opacity(0.3) :
                                    showAnswer && index == selectedAnswer && index != questions[currentQuestionIndex].correctAnswer ? Color.red.opacity(0.3) :
                                    selectedAnswer == index ? Color.pinkApp.opacity(0.3) :
                                    Color.pinkApp.opacity(0.2)
                                )
                        )
                    }
                    .disabled(showAnswer)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Results Screen
    var resultsScreen: some View {
        VStack(spacing: 40) {
            Text("Quiz Complete!")
                .foregroundStyle(.yellowApp)
                .font(Font.largeTitle.bold())
            
            VStack(spacing: 20) {
                Text("Your Score")
                    .foregroundStyle(.yellowApp)
                    .font(.title2)
                
                Text("\(score)/\(questions.count)")
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
                gameState = .difficultySelection
                resetQuiz()
            } label: {
                BackForMainButton(
                    text: "Play Again",
                    iconString: "arrow.clockwise",
                    isAlert: false
                )
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Quiz Logic
    func startQuiz(difficulty: QuizDifficulty) {
        resetQuiz()
        selectedDifficulty = difficulty
        questions = getQuestions(for: difficulty)
        questions.shuffle()
        gameState = .playing
    }
    
    func stopQuiz() {
        // Остановка квиза если нужно
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showAnswer = false
        questions = []
    }
    
    func checkAnswer(_ answerIndex: Int) {
        if answerIndex == questions[currentQuestionIndex].correctAnswer {
            score += 1
        }
        
        // Переходим к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
                showAnswer = false
            } else {
                // Квиз завершен
                endQuiz()
            }
        }
    }
    
    func endQuiz() {
        gameState = .results
        updateRecord()
    }
    
    func loadRecord() {
        record = UserDefaults.standard.integer(forKey: "VolcadoQuizRecord")
    }
    
    func loadRecordForDifficulty(_ difficulty: QuizDifficulty) {
        let key = "VolcadoQuizRecord_\(difficulty.displayName)"
        record = UserDefaults.standard.integer(forKey: key)
    }
    
    func updateRecord() {
        let key = "VolcadoQuizRecord_\(selectedDifficulty.displayName)"
        if score > record {
            record = score
            UserDefaults.standard.set(record, forKey: key)
        }
    }
    
    // MARK: - Questions Data
    func getQuestions(for difficulty: QuizDifficulty) -> [QuizQuestion] {
        switch difficulty {
        case .easy:
            return easyQuestions
        case .medium:
            return mediumQuestions
        case .hard:
            return hardQuestions
        }
    }
    
    private let easyQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "What is a Volcano?",
            options: ["A mountain that can erupt", "A river", "A forest"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which color is lava usually?",
            options: ["Blue", "Red or orange", "Green"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What do you call molten rock from a Volcano?",
            options: ["Lava", "Ice", "Sand"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Where are most Volcanoes located?",
            options: ["Near oceans", "In deserts", "In the sky"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which of these is a famous Volcano?",
            options: ["Mount Everest", "Mount Vesuvius", "Mount Kilimanjaro"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What can happen when a Volcano erupts?",
            options: ["Lava flows", "Snow falls", "Flowers bloom"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is a crater?",
            options: ["The hole at the top of a Volcano", "A type of cloud", "A small lake"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which animal lives near Volcanoes?",
            options: ["Penguins", "Birds", "Polar bears"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What is the molten rock called before it erupts?",
            options: ["Magma", "Lava", "Water"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is a lava flow?",
            options: ["Molten rock moving down a Volcano", "Rain flowing down a mountain", "Wind blowing ash"],
            correctAnswer: 0
        )
    ]
    
    private let mediumQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "What is the difference between magma and lava?",
            options: ["Magma is underground, lava is above ground", "Lava is underground, magma is above ground", "They are the same"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What type of eruption is the most explosive?",
            options: ["Effusive", "Plinian", "Gentle"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Which plate boundary is most associated with Volcanoes?",
            options: ["Divergent", "Transform", "Static"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is a shield Volcano?",
            options: ["A Volcano with broad, gentle slopes", "A Volcano with a very steep cone", "A Volcano that only erupts once"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which gas is commonly released by Volcanoes?",
            options: ["Oxygen", "Carbon dioxide", "Hydrogen"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What is a pyroclastic flow?",
            options: ["Fast-moving hot gas and rock from a Volcano", "A lava river", "A type of earthquake"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which famous eruption buried the city of Pompeii?",
            options: ["Mount St. Helens", "Mount Vesuvius", "Krakatoa"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "What can trigger a volcanic eruption?",
            options: ["Movement of tectonic plates", "Heavy rainfall", "Full moon"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is volcanic ash mostly made of?",
            options: ["Fine rock particles", "Sand", "Soil"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which Volcano is considered the tallest in the solar system?",
            options: ["Mount Everest", "Olympus Mons", "Mauna Loa"],
            correctAnswer: 1
        )
    ]
    
    private let hardQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "Which type of magma is the most viscous, causing explosive eruptions?",
            options: ["Basaltic", "Andesitic", "Rhyolitic"],
            correctAnswer: 2
        ),
        QuizQuestion(
            question: "What is a caldera?",
            options: ["A small volcanic cone", "A large crater formed after a Volcano collapses", "A lava tunnel"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Which of these Volcanoes is part of the Pacific Ring of Fire?",
            options: ["Mauna Loa", "Mount Kilimanjaro", "Mount Kosciuszko"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is a volcanic hotspot?",
            options: ["A region where magma rises from deep within the mantle", "The hottest lava on the surface", "A crater with active lava flows"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which eruption caused the \"Year Without a Summer\" in 1816?",
            options: ["Mount Tambora", "Krakatoa", "Mount Fuji"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "What is lahars?",
            options: ["Hot volcanic gas", "Mudflows of volcanic ash and water", "Small volcanic rocks"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Which feature indicates a Volcano is extinct?",
            options: ["No lava flow for thousands of years", "Small eruptions every year", "Continuous gas release"],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "Which factor increases the explosiveness of a volcanic eruption?",
            options: ["Low silica content", "High silica content", "Presence of water on the surface only"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Which is true about stratoVolcanoes?",
            options: ["They have gentle slopes and low eruptions", "They are tall, steep, and prone to explosive eruptions", "They only erupt once in history"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "Which is the largest active Volcano on Earth?",
            options: ["Mauna Loa", "Mount Fuji", "Mount Etna"],
            correctAnswer: 0
        )
    ]
}

#Preview {
    VolcadoQuizView()
}
