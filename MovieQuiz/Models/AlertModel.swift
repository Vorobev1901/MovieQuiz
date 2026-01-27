//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 22.01.2026.
//

import Foundation

/// Модель для отображения алерта
struct AlertModel {
    /// Заголовок алерта
    let title: String
    /// Основной текст алерта
    let message: String
    /// Текст кнопки действия
    let buttonText: String
    /// Замыкание, вызываемое при нажатии на кнопку
    let completion: () -> Void
}
