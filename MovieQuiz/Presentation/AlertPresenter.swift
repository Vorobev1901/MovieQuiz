//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 22.01.2026.
//

import UIKit

// Класс для показа стандартных алертов в приложении
// Используется для отображения результатов квиза или любых сообщений пользователю
final class AlertPresenter {
    
    /// Показывает алерт на переданном контроллере с данными из модели AlertModel
    /// - Parameters:
    ///   - vc: UIViewController, на котором нужно показать алерт
    ///   - model: AlertModel, содержит заголовок, текст, название кнопки и действие-замыкание
    func show(in vc: UIViewController, model: AlertModel) {
        
        // Создаём UIAlertController с заголовком и текстом
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        // Создаём кнопку алерта, которая выполняет переданное замыкание completion при нажатии
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        // Добавляем действие на алерт
        alert.addAction(action)
        
        // Показываем алерт на экране
        vc.present(alert, animated: true, completion: nil)
    }
}
