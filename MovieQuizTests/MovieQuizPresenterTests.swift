//
//  MovieQuizPresenterTests.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 10.02.2026.
//

import Foundation

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {

    func setButtonsEnabled(_ isEnabled: Bool) { }

    func show(quiz step: QuizStepViewModel) { }

    func show(quiz result: QuizResultsViewModel) { }

    func highlightImageBorder(isCorrectAnswer: Bool) { }

    func showLoadingIndicator() { }

    func hideLoadingIndicator() { }

    func showError(message: String) { }
}



final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let text = "Рейтинг этого фильма больше 6?"
        let question = QuizQuestion(imageData: emptyData, text: text, correctAnswer: true)
        let viewModel: QuizStepViewModel = sut.convert(model: question)
        
        XCTAssertEqual(viewModel.image, emptyData)
        XCTAssertEqual(viewModel.question, text)
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
