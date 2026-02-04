import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    
    /// Показывает номер текущего вопроса
    @IBOutlet weak private var counterLabel: UILabel!
    
    /// Отображает текст вопроса
    @IBOutlet weak private var textLabel: UILabel!
    
    /// Картинка фильма для вопроса
    @IBOutlet weak private var imageView: UIImageView!
    
    /// Кнопка "Нет"
    @IBOutlet weak private var noButton: UIButton!
    
    /// Кнопка "Да"
    @IBOutlet weak private var yesButton: UIButton!
    
    /// Индикатор загрузки фильмов
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private properties
    
    /// Индекс текущего вопроса
    private var currentQuestionIndex = 0
    
    /// Счётчик правильных ответов в раунде
    private var correctAnswers = 0
    
    /// Общее количество вопросов в раунде
    private var questionsAmount: Int = 10
    
    /// Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    /// Сервис статистики
    private var statisticService: StatisticServiceProtocol?
    
    /// Отвечает за показ алертов
    private var alertPresenter = AlertPresenter()
    
    /// Текущий вопрос
    private var currentQuestion: QuizQuestion?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        configureUI()
        setupServices()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    
    // MARK: - Setup
    
    /// Настраивает внешний вид интерфейса
    private func configureUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
    }
    
    /// Инициализирует сервисы и зависимости
    private func setupServices() {
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(
            moviesLoader: moviesLoader,
            delegate: self
        )
        
        statisticService = StatisticService()
    }
    
    /// Запускает первый вопрос квиза
    private func startGame() {
        requestNextQuestion()
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
            self.hideLoadingIndicator()
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        startGame()
    }

    func didFailToLoadData(with error: Error) {
        showError(message: error.localizedDescription)
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
    
    /// Конвертирует модель QuizQuestion в QuizStepViewModel
    /// - Parameter model: Модель вопроса
    /// - Returns: ViewModel для отображения вопроса в UI
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    /// Показывает экран вопроса на основе `QuizStepViewModel`
    ///
    /// Используется для отображения текущего вопроса:
    /// обновляет номер вопроса, текст и изображение,
    /// а также включает кнопки ответа.
    ///
    /// - Parameter step: ViewModel вопроса, содержит текст, номер вопроса и изображение
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
    
    /// Показывает экран результата квиза через алерт на основе `QuizResultsViewModel`
    ///
    /// Используется для отображения финального результата раунда:
    /// показывает алерт с итогами и кнопкой перезапуска.
    ///
    /// - Parameter result: ViewModel результата квиза, содержит заголовок, текст и название кнопки
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            self.resetGame()
            self.startGame()
            
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    /// Обрабатывает ответ пользователя и показывает результат
    /// - Parameter isCorrect: true, если ответ правильный, иначе false
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
    
    /// Определяет: показываем следующий вопрос или результат квиза
    private func showNextQuestionOrResults() {
        let isLastQuestion = currentQuestionIndex == questionsAmount - 1
        
        if isLastQuestion {
            showResults()
        } else {
            showNextQuestion()
        }
    }
    
    /// Показывает результаты раунда
    private func showResults() {
        finishGame()
        
        guard let statisticService else { return }
        
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
    }
    
    /// Запрашивает следующий вопрос
    private func showNextQuestion() {
        currentQuestionIndex += 1
        requestNextQuestion()
    }
    
    /// Сброс состояния раунда
    private func resetGame() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
    }
    
    /// Завершаем игру и сохраняем результаты текущего раунда
    private func finishGame() {
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
    }
    
    /// Запрашивает следующий вопрос у фабрики
    private func requestNextQuestion() {
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    /// Показывает индикиатор загрузки
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    /// Скрывает индикатор загрузки
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            guard let self else { return }
            
            self.showLoadingIndicator()
            questionFactory?.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}
