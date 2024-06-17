//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Байрам Джанкулиев on 16.06.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(than other: GameResult) -> Bool {
        return correct > other.correct || (correct == other.correct && total < other.total)
    }
}
