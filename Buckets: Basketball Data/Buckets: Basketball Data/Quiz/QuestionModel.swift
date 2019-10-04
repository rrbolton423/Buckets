//
//  QuestionModel.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import GameKit

struct QuestionModel {
    let questions = [
        Question(interrogative: "Which of the following is NOT a nickname of Vince Carter?", answers: ["Jurassic Park", "Vinsanity", "Half-Man, Half-Amazing", "No one knows", "Air Canada"], correctAnswerIndex: 0),
        Question(interrogative: "What is depicted on the logo of the Golden State Warriors?", answers: ["A city skyline", "A bridge", "A spearhead", "A basketball"], correctAnswerIndex: 1),
        Question(interrogative: "Who was the shortest player to win an MVP?", answers: ["Steve Nash", "Charles Barkley", "Spud Webb", "Allen Iverson"], correctAnswerIndex: 3),
        Question(interrogative: "What was the \"process\" of 76ers general manager Sam Hinkie?", answers: ["Looking for players in Europe", "Tanking for several years in a row", "Only drafting excellent 3 point shooters", "Signing veteran leaders"], correctAnswerIndex: 1),
        Question(interrogative: "About what percent of NBA players are black, as of 2015?", answers: ["50", "95", "25", "75"], correctAnswerIndex: 3),
        Question(interrogative: "What country is Manu Ginóbili from?", answers: ["France", "United States", "Argentina", "Italy"], correctAnswerIndex: 2),
        Question(interrogative: "What is the record for most regular season wins, set by the Golden State Warriors in 2015-16?", answers: ["69", "50", "73", "82"], correctAnswerIndex: 2),
        Question(interrogative: "What team used to be the Seattle Supersonics?", answers: ["Oklahoma City Thunder", "Phoenix Suns", "San Antonio Spurs", "Orlando Magic"], correctAnswerIndex: 0),
        Question(interrogative: "When Kevin Durant won the MVP award in 2014, he said someone else was \"da real MVP\". Who was it?", answers: ["Barack Obama", "Lebron James", "Russell Westbrook", "His mom"], correctAnswerIndex: 3),
        Question(interrogative: "Which of the following was never a teammate of Michael Jordan?", answers: ["Toni Kukoč", "Dennis Rodman", "Grant Hill", "Steve Kerr"], correctAnswerIndex: 2)
    ]
    
    var previouslyUsedNumbers: [Int] = []
    mutating func getRandomQuestion() -> Question {
        if (previouslyUsedNumbers.count == questions.count) {
            previouslyUsedNumbers = []
        }
        var randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
        while (previouslyUsedNumbers.contains(randomNumber)) {
            randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
        }
        previouslyUsedNumbers.append(randomNumber)
        return questions[randomNumber]
    }
}

class Question {
    fileprivate let interrogative: String
    fileprivate let answers: [String]
    fileprivate let correctAnswerIndex: Int
    
    init(interrogative: String, answers: [String], correctAnswerIndex: Int) {
        self.interrogative = interrogative
        self.answers = answers
        self.correctAnswerIndex = correctAnswerIndex
    }
    
    func validateAnswer(to givenAnswer: String) -> Bool {
        return (givenAnswer == answers[correctAnswerIndex])
    }
    
    func getInterrogative() -> String {
        return interrogative
    }
    
    func getAnswer() -> String {
        return answers[correctAnswerIndex]
    }
    
    func getChoices() -> [String] {
        return answers
    }
    
    func getAnswerAt(index: Int) -> String {
        return answers[index]
    }
}
