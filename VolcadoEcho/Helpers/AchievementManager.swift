//
//  AchievementManager.swift
//  VolcadoEcho
//
//  Created by Роман Главацкий on 11.12.2025.
//

import Foundation
import Combine

enum AchievementID: String, CaseIterable {
    // General
    case firstEcho = "firstEcho"
    case hotStart = "hotStart"
    case soundOfLava = "soundOfLava"
    case endlessEcho = "endlessEcho"
    case volcadoLegend = "volcadoLegend"
    
    // Double Echo
    case firstMatch = "firstMatch"
    case fastEcho = "fastEcho"
    case noMistakes = "noMistakes"
    case fieryFocus = "fieryFocus"
    case flowOfLava = "flowOfLava"
    case pairCollector = "pairCollector"
    
    // Echo Drop
    case firstCatch = "firstCatch"
    case lavaCollector = "lavaCollector"
    case ashMistake = "ashMistake"
    case volcadoNeverGivesUp = "volcadoNeverGivesUp"
    case echoAvalanche = "echoAvalanche"
    case masterOfFalls = "masterOfFalls"
    
    // Volcado Quiz
    case firstAnswer = "firstAnswer"
    case volcadoGenius = "volcadoGenius"
    case didntBurnOut = "didntBurnOut"
    case ashesOfKnowledge = "ashesOfKnowledge"
    case fieryMind = "fieryMind"
    case lavaLogic = "lavaLogic"
}

struct Achievement {
    let id: AchievementID
    let title: String
    let description: String
    let category: String
    var isUnlocked: Bool
    
    var emoji: String {
        switch id {
        case .firstEcho: return "🎮"
        case .hotStart: return "🔥"
        case .soundOfLava: return "🌋"
        case .endlessEcho: return "♾️"
        case .volcadoLegend: return "👑"
        case .firstMatch: return "🎯"
        case .fastEcho: return "⚡"
        case .noMistakes: return "✨"
        case .fieryFocus: return "🔥"
        case .flowOfLava: return "🌊"
        case .pairCollector: return "📚"
        case .firstCatch: return "🎣"
        case .lavaCollector: return "💎"
        case .ashMistake: return "💣"
        case .volcadoNeverGivesUp: return "💪"
        case .echoAvalanche: return "🏔️"
        case .masterOfFalls: return "👑"
        case .firstAnswer: return "✅"
        case .volcadoGenius: return "🧠"
        case .didntBurnOut: return "🔥"
        case .ashesOfKnowledge: return "💨"
        case .fieryMind: return "🔥"
        case .lavaLogic: return "🧪"
        }
    }
}

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = []
    
    private init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        achievements = [
            // General
            Achievement(id: .firstEcho, title: "First Echo", description: "Play your first game.", category: "General", isUnlocked: isUnlocked(.firstEcho)),
            Achievement(id: .hotStart, title: "Hot Start", description: "Play each game mode once.", category: "General", isUnlocked: isUnlocked(.hotStart)),
            Achievement(id: .soundOfLava, title: "Sound of Lava", description: "Earn 10 rewards.", category: "General", isUnlocked: isUnlocked(.soundOfLava)),
            Achievement(id: .endlessEcho, title: "Endless Echo", description: "Play 100 games in total.", category: "General", isUnlocked: isUnlocked(.endlessEcho)),
            Achievement(id: .volcadoLegend, title: "Volcado Legend", description: "Collect all achievements.", category: "General", isUnlocked: isUnlocked(.volcadoLegend)),
            
            // Double Echo
            Achievement(id: .firstMatch, title: "First Match", description: "Find your first matching pair.", category: "Double Echo", isUnlocked: isUnlocked(.firstMatch)),
            Achievement(id: .fastEcho, title: "Fast Echo", description: "Complete a level in under 10 seconds.", category: "Double Echo", isUnlocked: isUnlocked(.fastEcho)),
            Achievement(id: .noMistakes, title: "No Mistakes", description: "Finish a level without any errors.", category: "Double Echo", isUnlocked: isUnlocked(.noMistakes)),
            Achievement(id: .fieryFocus, title: "Fiery Focus", description: "Complete 3 levels in a row without losing.", category: "Double Echo", isUnlocked: isUnlocked(.fieryFocus)),
            Achievement(id: .flowOfLava, title: "Flow of Lava", description: "Play 50 levels in a row.", category: "Double Echo", isUnlocked: isUnlocked(.flowOfLava)),
            Achievement(id: .pairCollector, title: "Pair Collector", description: "Match 1000 pairs.", category: "Double Echo", isUnlocked: isUnlocked(.pairCollector)),
            
            // Echo Drop
            Achievement(id: .firstCatch, title: "First Catch", description: "Catch your first item.", category: "Echo Drop", isUnlocked: isUnlocked(.firstCatch)),
            Achievement(id: .lavaCollector, title: "Lava Collector", description: "Collect 150 items.", category: "Echo Drop", isUnlocked: isUnlocked(.lavaCollector)),
            Achievement(id: .ashMistake, title: "Ash Mistake", description: "Catch 5 bombs in one game.", category: "Echo Drop", isUnlocked: isUnlocked(.ashMistake)),
            Achievement(id: .volcadoNeverGivesUp, title: "Volcado Never Gives Up", description: "Score 500 points with one life.", category: "Echo Drop", isUnlocked: isUnlocked(.volcadoNeverGivesUp)),
            Achievement(id: .echoAvalanche, title: "Echo Avalanche", description: "Score 2000 points.", category: "Echo Drop", isUnlocked: isUnlocked(.echoAvalanche)),
            Achievement(id: .masterOfFalls, title: "Master of Falls", description: "Score 10000 points.", category: "Echo Drop", isUnlocked: isUnlocked(.masterOfFalls)),
            
            // Volcado Quiz
            Achievement(id: .firstAnswer, title: "First Answer", description: "Answer your first question correctly.", category: "Volcado Quiz", isUnlocked: isUnlocked(.firstAnswer)),
            Achievement(id: .volcadoGenius, title: "Volcado Genius", description: "Get 10 correct answers in a row.", category: "Volcado Quiz", isUnlocked: isUnlocked(.volcadoGenius)),
            Achievement(id: .didntBurnOut, title: "Didn't Burn Out!", description: "Complete a quiz level without mistakes.", category: "Volcado Quiz", isUnlocked: isUnlocked(.didntBurnOut)),
            Achievement(id: .ashesOfKnowledge, title: "Ashes of Knowledge", description: "Give 5 wrong answers in a row.", category: "Volcado Quiz", isUnlocked: isUnlocked(.ashesOfKnowledge)),
            Achievement(id: .fieryMind, title: "Fiery Mind", description: "Complete the \"Hard\" difficulty quiz.", category: "Volcado Quiz", isUnlocked: isUnlocked(.fieryMind)),
            Achievement(id: .lavaLogic, title: "Lava Logic", description: "Answer all questions correctly on all difficulty levels.", category: "Volcado Quiz", isUnlocked: isUnlocked(.lavaLogic))
        ]
    }
    
    func isUnlocked(_ id: AchievementID) -> Bool {
        return UserDefaults.standard.bool(forKey: "achievement_\(id.rawValue)")
    }
    
    func unlock(_ id: AchievementID) {
        guard !isUnlocked(id) else { return }
        UserDefaults.standard.set(true, forKey: "achievement_\(id.rawValue)")
        loadAchievements()
        checkGeneralAchievements()
    }
    
    func checkGeneralAchievements() {
        // Reload to get current count
        loadAchievements()
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        
        // Sound of Lava - Earn 10 rewards
        if unlockedCount >= 10 && !isUnlocked(.soundOfLava) {
            UserDefaults.standard.set(true, forKey: "achievement_\(AchievementID.soundOfLava.rawValue)")
            loadAchievements()
        }
        
        // Endless Echo - Play 100 games in total
        let totalGames = UserDefaults.standard.integer(forKey: "totalGamesPlayed")
        if totalGames >= 100 && !isUnlocked(.endlessEcho) {
            UserDefaults.standard.set(true, forKey: "achievement_\(AchievementID.endlessEcho.rawValue)")
            loadAchievements()
        }
        
        // Volcado Legend - Collect all achievements
        if unlockedCount >= 23 && !isUnlocked(.volcadoLegend) {
            UserDefaults.standard.set(true, forKey: "achievement_\(AchievementID.volcadoLegend.rawValue)")
            loadAchievements()
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    // Tracking methods
    func trackGamePlayed(gameMode: String) {
        let key = "gamePlayed_\(gameMode)"
        if !UserDefaults.standard.bool(forKey: key) {
            UserDefaults.standard.set(true, forKey: key)
            unlock(.firstEcho)
            checkHotStart()
        }
        
        let totalGames = UserDefaults.standard.integer(forKey: "totalGamesPlayed")
        UserDefaults.standard.set(totalGames + 1, forKey: "totalGamesPlayed")
        checkGeneralAchievements()
    }
    
    func checkHotStart() {
        let doubleEchoPlayed = UserDefaults.standard.bool(forKey: "gamePlayed_DoubleEcho")
        let echoDropPlayed = UserDefaults.standard.bool(forKey: "gamePlayed_EchoDrop")
        let quizPlayed = UserDefaults.standard.bool(forKey: "gamePlayed_VolcadoQuiz")
        
        if doubleEchoPlayed && echoDropPlayed && quizPlayed {
            unlock(.hotStart)
        }
    }
}

