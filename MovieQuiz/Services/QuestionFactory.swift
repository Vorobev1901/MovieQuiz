//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 22.01.2026.
//

import Foundation

// Класс, отвечающий за генерацию и предоставление вопросов для квиза
// Делегат получает следующий вопрос, когда он запрашивается
class QuestionFactory: QuestionFactoryProtocol {
    
    /// Делегат, которому сообщается о новом вопросе
    /// Используется weak, чтобы избежать retain cycle
    weak var delegate: QuestionFactoryDelegate?
    
    /// Массив доступных вопросов квиза
    /// Каждый вопрос содержит название картинки, текст вопроса и правильный ответ
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            imageName: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            imageName: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            imageName: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    /// Метод запроса следующего вопроса
    /// Выбирает случайный индекс из массива вопросов и передаёт его делегату
    func requestNextQuestion() {
        // Получаем случайный индекс из диапазона существующих вопросов
        guard let index = (0..<questions.count).randomElement() else {
            // Если по какой-то причине индекс не получен, сообщаем делегату nil
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        // Берём вопрос безопасно через subscript safe (возвращает nil, если индекс вне диапазона)
        let question = questions[safe: index]
        
        // Передаём вопрос делегату, который отобразит его на экране
        delegate?.didReceiveNextQuestion(question: question)
    }
    
}
