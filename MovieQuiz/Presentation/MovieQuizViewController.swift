import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak private var counterLabel: UILabel!       // Показывает номер текущего вопроса
    @IBOutlet weak private var textLabel: UILabel!          // Отображает текст вопроса
    @IBOutlet weak private var imageView: UIImageView!      // Картинка фильма для вопроса
    @IBOutlet weak private var noButton: UIButton!          // Кнопка "Нет"
    @IBOutlet weak private var yesButton: UIButton!         // Кнопка "Да"
    
    // MARK: - Private properties
    
    private var currentQuestionIndex = 0                    // Индекс текущего вопроса
    private var correctAnswers = 0                          // Счётчик правильных ответов в раунде
    private var questionsAmount: Int = 10                   // Общее количество вопросов в раунде
    
    private var questionFactory: QuestionFactoryProtocol?   // Фабрика вопросов
    private var statisticService: StatisticServiceProtocol? // Сервис статистики
    private var alertPresenter = AlertPresenter()           // Отвечает за показ алертов
    private var currentQuestion: QuizQuestion?              // Текущий вопрос
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Скругление углов картинки и кнопок
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        
        // Настройка фабрики вопросов и установка делегата
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        // Инициализация сервиса статистики
        statisticService = StatisticService()
        
        // Запрос первого вопроса
        self.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // Делегатный метод фабрики вопросов: вызывается при получении нового вопроса
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question) // Конвертация модели вопроса в вью-модель
        
        // Обновление UI на главном потоке
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        // Проверяем ответ: "Нет" правильный, если текущий вопрос имеет correctAnswer == false
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        // Проверяем ответ: "Да" правильный, если текущий вопрос имеет correctAnswer == true
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    // Конвертация модели QuizQuestion в QuizStepViewModel для UI
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        return questionStep
    }
    
    // Показ вопроса на экране
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        
        // Сбрасываем рамку у картинки
        imageView.layer.borderWidth = 0
        // Включаем кнопки для следующего ответа
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // Показ результата квиза (алерт)
    private func show(quiz result: QuizResultsViewModel) {

        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            // Сброс состояния раунда
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // Начало нового раунда
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // Обработка ответа пользователя
    private func showAnswerResult(isCorrect: Bool) {
        // Показываем рамку: зеленая для правильного, красная для неправильного
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // Отключаем кнопки до следующего вопроса
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        // Увеличиваем счётчик правильных ответов
        if isCorrect {
            self.correctAnswers += 1
        }
        
        // Переход к следующему вопросу через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // Логика перехода: следующий вопрос или конец раунда
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          // Конец раунда
          guard let statisticService else { return }
          
          // Сохраняем результаты текущего раунда
          statisticService.store(correct: correctAnswers, total: questionsAmount)
          
          // Формируем текст для алерта
          let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
          """
          
          let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз"
          )
          show(quiz: viewModel)
      } else {
          // Переход к следующему вопросу
          currentQuestionIndex += 1
          self.questionFactory?.requestNextQuestion()
      }
        
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
