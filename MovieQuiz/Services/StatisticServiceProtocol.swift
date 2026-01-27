//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 26.01.2026.
//

import Foundation

/// Протокол сервиса статистики
protocol StatisticServiceProtocol {
    /// Количество сыгранных игр
    var gamesCount: Int { get }
    /// Лучший результат среди всех игр
    var bestGame: GameResult { get }
    /// Общая точность (в процентах) по всем играм
    var totalAccuracy: Double { get }
    
    /// Сохраняет результаты текущего раунда
    /// - Parameters:
    ///   - count: количество правильных ответов
    ///   - amount: общее количество вопросов
    func store(correct count: Int, total amount: Int)
}
