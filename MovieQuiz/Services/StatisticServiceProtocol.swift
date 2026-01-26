//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 26.01.2026.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
