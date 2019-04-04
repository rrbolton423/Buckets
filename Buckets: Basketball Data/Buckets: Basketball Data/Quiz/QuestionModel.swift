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
        Question(interrogative: "Who invented the game of basketball?", answers: ["Frank Mahan", "Abner Doubleday", "Walter Camp", "James Naismith"], correctAnswerIndex: 3),
        Question(interrogative: "What teammates were nicknamed the \"Splash Brothers\"?", answers: ["Jerry West & Wilt Chamberlain", "Kevin Durant & Ruseell Westbrook", "Michael Jordan & Scottie Pippen", "Stephen Curry & Klay Thompson"], correctAnswerIndex: 3),
        Question(interrogative: "What player holds the NBA record for the most career assists?", answers: ["Jason Kidd", "John Stockton", "Magic Johnson", "Steve Nash"], correctAnswerIndex: 1),
        Question(interrogative: "Who was the first NBA player to record a triple-double in the All-Star Game?", answers: ["Dwyane Wade", "John Stockton", "LeBron James", "Michael Jordan"], correctAnswerIndex: 3),
        Question(interrogative: "Who is the highest-scoring foreign-born player in NBA history?", answers: ["Dirk Nowitzki", "Yao Ming", "Hakeem Olajuwon", "Detlef Schrempf"], correctAnswerIndex: 0),
        Question(interrogative: "Who is the NBA Championship trophey named after?", answers: ["Larry O'Brien", "Maurice Podoloff", "Red Auerbach", "James Naismith"], correctAnswerIndex: 0),
        Question(interrogative: "Which NBA team plays at Madison Square Garden?", answers: ["Brooklyn Nets", "Miami Heat", "New York Knicks", "Golden State Warriors"], correctAnswerIndex: 2),
        Question(interrogative: "What NBA player has won the most league MVPs?", answers: ["Michael Jordan", "LeBron James", "Kareem Abdul-Jabbar", "Stephen Curry"], correctAnswerIndex: 2),
        Question(interrogative: "Which team owns the longest winning streak in NBA history?", answers: ["Chicago Bulls", "Los Angeles Lakers", "Miami Heat", "Golden State Warriors"], correctAnswerIndex: 1),
        Question(interrogative: "Who has the most blocked shots in NBA history?", answers: ["Mark Eaton", "Dikembe Mutombo", "Hakeem Olajuwon", "Kareem Abdul-Jabbar"], correctAnswerIndex: 2)
    ]
    
    var previouslyUsedNumbers: [Int] = []
    
    mutating func getRandomQuestion() -> Question {
        
        if (previouslyUsedNumbers.count == questions.count) {
            previouslyUsedNumbers = []
        }
        var randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: questions.count)
        
        // Picks a new random number if the previous one has been used
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
