//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 07.02.2026.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Проверяем ответ: "Нет" правильный, если текущий вопрос имеет correctAnswer == false
        viewController?.showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Проверяем ответ: "Да" правильный, если текущий вопрос имеет correctAnswer == true
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    /// Конвертирует модель QuizQuestion в QuizStepViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
}
