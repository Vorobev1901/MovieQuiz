//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 22.01.2026.
//

import Foundation

/// Модель вопроса квиза
struct QuizQuestion {
    /// Имя картинки с постером фильма
    let imageName: String
    /// Текст вопроса
    let text: String
    /// Правильный ответ на вопрос
    let correctAnswer: Bool
}

