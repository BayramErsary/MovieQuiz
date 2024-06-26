import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var mainStackView: UIStackView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: ResultAlertPresenter!
    private var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStackView.isHidden = true
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = ResultAlertPresenter(viewController: self)
        questionFactory?.loadData()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        mainStackView.isHidden = false
        questionFactory?.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        hideLoadingIndicator()
        mainStackView.isHidden = false
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        enableButtons()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let bestGame = statisticService.bestGame
            let bestGameText = "Лучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let text = correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!\nСредняя точность: \(accuracy)%\n\(gamesCountText)\nЛучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!\nСредняя точность: \(accuracy)%\n\(gamesCountText)\nЛучший результат: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            enableButtons()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect{
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory.requestNextQuestion()
        }
        alertPresenter.show(alertModel: alertModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion else { return }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion else { return }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.retryLoadData()
        }
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func retryLoadData() {
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
}
