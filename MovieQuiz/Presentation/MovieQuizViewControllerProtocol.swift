//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 09.02.2026.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
        func show(quiz result: QuizResultsViewModel)
        
        func highlightImageBorder(isCorrectAnswer: Bool)
        
        func showLoadingIndicator()
        func hideLoadingIndicator()
        func setButtonsEnabled(_ isEnabled: Bool)
        
        func showError(message: String)
}
