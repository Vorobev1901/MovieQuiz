//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Nikita Vorobiev on 04.02.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {

        let poster = app.images["Poster"]
        // 1. Ждём первый постер
        XCTAssertTrue(
            poster.waitForExistence(timeout: 10),
            "Poster did not appear"
        )
        
        let firstPosterData = poster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        // 2. Ждём обновления постера (например, другой вопрос)
        let predicate = NSPredicate { _, _ in
            poster.screenshot().pngRepresentation != firstPosterData
        }
        
        expectation(for: predicate, evaluatedWith: poster)
        waitForExpectations(timeout: 10)
        
        let newPosterData = poster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, newPosterData, "Poster did not change after tapping Yes")
        
        let indexLabel = app.staticTexts["Index"]
        
        let oldIndexLabel = indexLabel.label
        
        let indexPredicate = NSPredicate(
            format: "label != %@",
            oldIndexLabel
        )
        
        expectation(for: indexPredicate, evaluatedWith: indexLabel)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(indexLabel.label, "2/10", "Question index did not update")
    }
    
    func testsNoButton() {
        let poster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertTrue(
            poster.waitForExistence(timeout: 10),
            "Poster did not appear"
        )
        
        let firstPosterData = poster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        let predicate = NSPredicate { _, _ in
            poster.screenshot().pngRepresentation != firstPosterData
        }
        
        expectation(for: predicate, evaluatedWith: poster)
        waitForExpectations(timeout: 10)
        
        let newPosterData = poster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, newPosterData, "Poster did not change after tapping No")
        
        let oldIndexLabel = indexLabel.label
        
        let indexPredicate = NSPredicate(
            format: "label != %@",
            oldIndexLabel
        )
        
        expectation(for: indexPredicate, evaluatedWith: indexLabel)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(indexLabel.label, "2/10", "Question index did not update")
    }
    
    func testGameFinish() {
        
        let indexLabel = app.staticTexts["Index"]
            
        // Ждём, пока первый индекс появится
        XCTAssertTrue(
            indexLabel.waitForExistence(timeout: 10),
            "Index label did not appear"
        )
        
        for questionNumber in 1...10 {
            // Нажимаем кнопку "No"
            app.buttons["No"].tap()
            
            if questionNumber < 10 {
                // Для первых 9 кликов ждём обновления индекса
                let expectedIndex = "\(questionNumber + 1)/10"
                let indexPredicate = NSPredicate(format: "label == %@", expectedIndex)
                expectation(for: indexPredicate, evaluatedWith: indexLabel)
                waitForExpectations(timeout: 10)
                
                XCTAssertEqual(indexLabel.label, expectedIndex)
            }
        }

        // Проверяем финальный алерт
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Finish alert did not appear")
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        let indexLabel = app.staticTexts["Index"]
            
        // Ждём, пока первый индекс появится
        XCTAssertTrue(
            indexLabel.waitForExistence(timeout: 10),
            "Index label did not appear"
        )
        
        for questionNumber in 1...10 {
            // Нажимаем кнопку "No"
            app.buttons["No"].tap()
            
            if questionNumber < 10 {
                // Для первых 9 кликов ждём обновления индекса
                let expectedIndex = "\(questionNumber + 1)/10"
                let indexPredicate = NSPredicate(format: "label == %@", expectedIndex)
                expectation(for: indexPredicate, evaluatedWith: indexLabel)
                waitForExpectations(timeout: 10)
                
                XCTAssertEqual(indexLabel.label, expectedIndex)
            }
        }
        
        // Проверяем финальный алерт
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Finish alert did not appear")
        
        alert.buttons.firstMatch.tap()
        
        // Ждём, пока индекс обновится на "1/10"
        let resetIndexPredicate = NSPredicate(format: "label == %@", "1/10")
        expectation(for: resetIndexPredicate, evaluatedWith: indexLabel)
        waitForExpectations(timeout: 5)
        
        XCTAssertFalse(alert.exists, "Alert still exists after tapping button")
        XCTAssertEqual(indexLabel.label, "1/10", "Index did not reset after dismissing alert")
    }
}
