//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 26.01.2026.
//
import Foundation

/// Результат одного раунда игры
struct GameResult {
    /// Количество правильных ответов
    let correct: Int
    /// Общее количество вопросов
    let total: Int
    /// Дата проведения раунда
    let date: Date
    
    /// Сравнивает с другим результатом и возвращает true, если текущий лучше
    /// - Parameter another: другой результат игры
    /// - Returns: true, если текущий результат лучше
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
