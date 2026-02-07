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
    
    /// Счётчик правильных ответов в раунде
    private var correctAnswers = 0
    
    /// Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    /// Сервис статистики
    private var statisticService: StatisticServiceProtocol?
    
    /// Отвечает за показ алертов
    private var alertPresenter = AlertPresenter()
    
    private let presenter = MovieQuizPresenter()
    
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
        
        presenter.viewController = self
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
        
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
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
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    
    // MARK: - Private Methods
 
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
        imageView.image = UIImage(data: step.image) ?? UIImage()
        
        // Сбрасываем рамку у картинки
//        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
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
    func showAnswerResult(isCorrect: Bool) {
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
        
        if presenter.isLastQuestion() {
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
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
        presenter.switchToNextQuestion()
        requestNextQuestion()
    }
    
    /// Сброс состояния раунда
    private func resetGame() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
    }
    
    /// Завершаем игру и сохраняем результаты текущего раунда
    private func finishGame() {
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
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
