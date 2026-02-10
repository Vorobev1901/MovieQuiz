//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 07.02.2026.
//

import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    
    // MARK: - Lifecycle
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        startGame()
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    /// Делегатный метод фабрики вопросов — вызывается при получении нового вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        // Обновление UI на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.hideLoadingIndicator()
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showError(message: message)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    // MARK: - Game Flow
    
    func startGame() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        requestNextQuestion()
    }
    
    /// Запрашивает следующий вопрос
    func showNextQuestion() {
        switchToNextQuestion()
        requestNextQuestion()
    }
    
    func requestNextQuestion() {
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    
    // MARK: - Answer Handling
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        // Проверяем ответ: "Нет" правильный, если текущий вопрос имеет correctAnswer == false
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func processAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    /// Конвертирует модель QuizQuestion в QuizStepViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.imageData,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    /// Обрабатывает ответ пользователя и показывает результат
    func proceedWithAnswer(isCorrect: Bool) {
        
        processAnswer(isCorrectAnswer: isCorrect)
        // Показываем рамку: зеленая для правильного, красная для неправильного
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        // Отключаем кнопки до следующего вопроса
        viewController?.setButtonsEnabled(false)
        
        // Переход к следующему вопросу через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            showResults()
        } else {
            showNextQuestion()
        }
    }
    
    func showResults() {
        let message = makeResultsMessage()
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть ещё раз"
        )
        
        viewController?.show(quiz: viewModel)
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}
