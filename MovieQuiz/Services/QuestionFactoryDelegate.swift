//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Байрам Джанкулиев on 13.06.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
