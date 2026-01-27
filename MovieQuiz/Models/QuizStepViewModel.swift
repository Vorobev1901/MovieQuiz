//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 22.01.2026.
//

import Foundation
import UIKit

/// ViewModel для отображения одного шага квиза
struct QuizStepViewModel {
    /// Картинка с афишей фильма
    let image: UIImage
    /// Вопрос квиза
    let question: String
    /// Строка с порядковым номером вопроса (например, "1/10")
    let questionNumber: String
}
