//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 26.01.2026.
//

import Foundation

// Сервис для хранения и получения статистики игр квиза
// Использует UserDefaults для постоянного хранения данных между запусками приложения
final class StatisticService {
    
    /// UserDefaults для хранения статистики между запусками приложения
    private let storage: UserDefaults = .standard
    
    /// Ключи для хранения разных показателей статистики в UserDefaults
    private enum Keys: String {
        /// Счётчик сыгранных игр
        case gamesCount
        /// Количество правильных ответов в лучшей игре
        case bestGameCorrect
        /// Общее количество вопросов в лучшей игре
        case bestGameTotal
        /// Дата лучшей игры
        case bestGameDate
        /// Общее количество правильных ответов за все игры
        case totalCorrectAnswers
        /// Общее количество вопросов за все игры
        case totalQuestionsAsked
    }
    
    /// Количество правильных ответов в текущей игре
    private var correct: Int = 0
    
    /// Общее количество вопросов в текущей игре
    private var total: Int = 0
}


// MARK: - Реализация протокола StatisticServiceProtocol

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if totalQuestionsAsked == 0 {
            return 0
        } else {
            let accuracy = Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
            return accuracy
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // Сохраняем в приватные свойства для удобства
        self.correct = count
        self.total = amount
        
        totalCorrectAnswers += correct
        totalQuestionsAsked += total
        gamesCount += 1
        
        let gameResult = GameResult(correct: correct, total: total, date: Date())
        
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }
}
