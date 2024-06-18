//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Байрам Джанкулиев on 16.06.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {

    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()

            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        totalQuestions += amount
        gamesCount += 1
        
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetter(than: bestGame) {
            bestGame = newResult
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case totalQuestions
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
    
    // Приватное свойство для хранения общего количества правильных ответов
    private var correctAnswers: Int {
        get { return storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }
    
    // Приватное свойство для хранения общего количества вопросов
    private var totalQuestions: Int {
        get { return storage.integer(forKey: Keys.totalQuestions.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestions.rawValue) }
    }
}
