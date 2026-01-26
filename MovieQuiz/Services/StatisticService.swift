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
    
    /// UserDefaults для сохранения данных
    private let storage: UserDefaults = .standard
    
    /// Ключи для хранения разных показателей статистики в UserDefaults
    private enum Keys: String {
        case gamesCount          // Счётчик сыгранных игр
        case bestGameCorrect     // Количество правильных ответов в лучшей игре
        case bestGameTotal       // Общее количество вопросов в лучшей игре
        case bestGameDate        // Дата лучшей игры
        case totalCorrectAnswers // Общее количество правильных ответов за все игры
        case totalQuestionsAsked // Общее количество вопросов за все игры
    }
}

// MARK: - Реализация протокола StatisticServiceProtocol

extension StatisticService: StatisticServiceProtocol {
    
    /// Количество сыгранных игр
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    /// Общее количество правильных ответов за все игры
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    /// Общее количество заданных вопросов за все игры
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    /// Информация о лучшей игре
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
    
    /// Общая точность всех игр в процентах
    var totalAccuracy: Double {
        // Если ещё не было вопросов, точность = 0
        if totalQuestionsAsked == 0 {
            return 0
        } else {
            // accuracy = (правильные ответы / всего вопросов) * 100
            let accuracy = Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
            return accuracy
        }
    }
    
    /// Сохраняет результаты текущей игры
    /// - Parameters:
    ///   - count: количество правильных ответов
    ///   - amount: общее количество вопросов
    func store(correct count: Int, total amount: Int) {
        // Увеличиваем общую статистику
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1
        
        // Создаём объект результата текущей игры
        let gameResult = GameResult(correct: count, total: amount, date: Date())
        
        // Если эта игра лучше предыдущей лучшей, обновляем bestGame
        if gameResult.isBetterThan(bestGame) {
            bestGame = gameResult
        }
    }
}
