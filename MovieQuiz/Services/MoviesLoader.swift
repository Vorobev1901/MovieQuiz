//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Nikita Vorobiev on 01.02.2026.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    enum MoviesLoaderError: LocalizedError {
        case api(String)
        case emptyItems
        
        var errorDescription: String? {
            switch self {
            case .api(let message):
                return message
            case .emptyItems:
                return "Не удалось загрузить фильмы. Попробуйте позже."
            }
        }
    }
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    private let decoder = JSONDecoder()
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(MostPopularMovies.self, from: data)
                    
                    // 🔴 ВОТ ОНА — ГЛАВНАЯ ПРОВЕРКА
                    if !response.errorMessage.isEmpty {
                        handler(.failure(
                            MoviesLoaderError.api(response.errorMessage)
                        ))
                        return
                    }
                    
                    // (опционально, но полезно)
                    if response.items.isEmpty {
                        handler(.failure(MoviesLoaderError.emptyItems))
                        return
                    }
                    
                    handler(.success(response))
                } catch {
                    handler(.failure(error))
                }
                
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
