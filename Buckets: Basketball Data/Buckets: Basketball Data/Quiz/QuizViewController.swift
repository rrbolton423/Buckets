//
//  ViewController.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class QuizViewController: UIViewController {
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var feedbackField: UILabel!
    @IBOutlet weak var firstChoiceButton: UIButton!
    @IBOutlet weak var secondChoiceButton: UIButton!
    @IBOutlet weak var thirdChoiceButton: UIButton!
    @IBOutlet weak var fourthChoiceButton: UIButton!
    @IBOutlet weak var nextQuestionButton: UIButton!
    
    var questions = QuestionModel()
    let score = ScoreModel()
    
    let numberOfQuestionPerRound = 10
    var currentQuestion: Question? = nil

    var gameStartSound: SystemSoundID = 0
    var isDarkMode: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        playGameStartSound()
        displayQuestion()
    }
    
    @objc func defaultsChanged(){
        var isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if isDarkMode == true {
            //dark theme enabled
            updateToDarkTheme()
            //isDarkMode = true
            print(isDarkMode)
            
        } else {
            
            //dark theme disabled
            updateToLightTheme()
            //isDarkMode = false
            print(isDarkMode)
        }
    }
    
    func updateToDarkTheme(){
        navigationController?.navigationBar.barStyle = .black
        self.questionField.textColor = .white
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.tabBarController?.tabBar.barTintColor = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    func updateToLightTheme() {
        navigationController?.navigationBar.barStyle = .default
        self.questionField.textColor = .black
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.tabBarController?.tabBar.barTintColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultsChanged()
        self.navigationController?.navigationBar.isTranslucent = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                self.navigationController?.navigationBar.prefersLargeTitles = false
                
            case 1334:
                print("iPhone 6/6S/7/8")
                self.navigationController?.navigationBar.prefersLargeTitles = false
                
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                self.navigationController?.navigationBar.prefersLargeTitles = true
                
            case 2436:
                print("iPhone X, XS")
                self.navigationController?.navigationBar.prefersLargeTitles = true
                
            case 2688:
                print("iPhone XS Max")
                self.navigationController?.navigationBar.prefersLargeTitles = true
                
            case 1792:
                print("iPhone XR")
                self.navigationController?.navigationBar.prefersLargeTitles = true
                
            default:
                print("Unknown")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func isGameOver() -> Bool {
        return score.getQuestionsAsked() >= numberOfQuestionPerRound
    }
    
    func displayQuestion() {
        currentQuestion = questions.getRandomQuestion()
        
        if let question = currentQuestion {
            let choices = question.getChoices()
            
            questionField.text = question.getInterrogative()
            firstChoiceButton.setTitle(choices[0], for: .normal)
            secondChoiceButton.setTitle(choices[1], for: .normal)
            thirdChoiceButton.setTitle(choices[2], for: .normal)
            fourthChoiceButton.setTitle(choices[3], for: .normal)
            
            if (score.getQuestionsAsked() == numberOfQuestionPerRound - 1) {
                nextQuestionButton.setTitle("End Quiz", for: .normal)
            } else {
                nextQuestionButton.setTitle("Next Question", for: .normal)
            }
        }
        
        firstChoiceButton.isEnabled = true
        secondChoiceButton.isEnabled = true
        thirdChoiceButton.isEnabled = true
        fourthChoiceButton.isEnabled = true

        firstChoiceButton.isHidden = false
        secondChoiceButton.isHidden = false
        thirdChoiceButton.isHidden = false
        fourthChoiceButton.isHidden = false
        feedbackField.isHidden = true

        nextQuestionButton.isEnabled = false
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        if let question = currentQuestion, let answer = sender.titleLabel?.text {
            
            if (question.validateAnswer(to: answer)) {
                score.incrementCorrectAnswers()
                feedbackField.textColor = UIColor(red:0.15, green:0.61, blue:0.61, alpha:1.0)
                feedbackField.text = "Correct!"
            } else {
                score.incrementIncorrectAnswers()
                feedbackField.textColor = UIColor(red:0.82, green:0.40, blue:0.26, alpha:1.0)
                feedbackField.text = "Sorry, that's not it."
            }
            firstChoiceButton.isEnabled = false
            secondChoiceButton.isEnabled = false
            thirdChoiceButton.isEnabled = false
            fourthChoiceButton.isEnabled = false
            nextQuestionButton.isEnabled = true
            
            feedbackField.isHidden = false
        }
    }
    
    @IBAction func nextQuestionTapped(_ sender: Any) {
        if (isGameOver()) {
            displayScore()
        } else {
            displayQuestion()
        }
    }
    
    func displayScore() {
        questionField.text = score.getScore()
        score.reset()
        nextQuestionButton.setTitle("Play again", for: .normal)
        
        feedbackField.isHidden = true
        firstChoiceButton.isHidden = true
        secondChoiceButton.isHidden = true
        thirdChoiceButton.isHidden = true
        fourthChoiceButton.isHidden = true
    }
    
    // MARK: Sounds
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameStartSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameStartSound)
    }
}
