//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Байрам Джанкулиев on 13.06.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
