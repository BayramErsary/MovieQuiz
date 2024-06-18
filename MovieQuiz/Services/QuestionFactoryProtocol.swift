//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Байрам Джанкулиев on 13.06.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func setup(delegate: QuestionFactoryDelegate)
}
