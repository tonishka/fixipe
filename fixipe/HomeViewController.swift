//
//  HomeViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 25/6/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var teleBot: UIButton!
    @IBOutlet weak var retakeQuiz: UIButton!
    @IBOutlet weak var reset: UIButton!
    
    @IBAction func resetPassTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "resetPassSegue", sender: nil)
    }
    
    var email = ""
    
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
        logout.layer.cornerRadius = 18
        userButton.layer.cornerRadius = 18
        teleBot.layer.cornerRadius = 18
        retakeQuiz.layer.cornerRadius = 18
        reset.layer.cornerRadius = 18
        let myColor = UIColor.gray
        userField.layer.borderWidth = 1
        userField.layer.borderColor = myColor.cgColor
        logout.center.x = self.view.center.x
        userButton.center.x = self.view.center.x
        userField.center.x = self.view.center.x
        username.center.x = self.view.center.x
        retakeQuiz.center.x = self.view.center.x
        teleBot.center.x = self.view.center.x
        reset.center.x = self.view.center.x
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    
    //Telegram Bot
    @IBAction func teleClick(_ sender: Any) {
        let botURL = URL.init(string: "tg://resolve?domain=fixipeBot")
        let webURL = URL(string: "https://t.me/fixipeBot")
        if UIApplication.shared.canOpenURL(botURL!) {
            UIApplication.shared.open(botURL!, options: [:], completionHandler: nil)
        } else {
          // Telegram is not installed.
            UIApplication.shared.open(webURL!, options: [:], completionHandler: nil)
        }
        
    }
    
    @available(iOS 13.0, *)
    @IBAction func quizClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let quiz : QuizViewController = storyboard.instantiateViewController(identifier: "quiz") as! QuizViewController
        
        let docRef = (db as AnyObject).collection("users").document(self.email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                quiz.name = (document.get("username") as! String)
                quiz.email = (document.get("email") as! String)
                quiz.diet = [String]()
                //quiz.image = (document.get("image") as! String)
                quiz.recipes = (document.get("recipes") as! [String])
            }
        }
        quiz.modalPresentationStyle = .overFullScreen
        present(quiz, animated: true)
    }
    
    @IBAction func userClick(_ sender: Any) {
        if (username.text == userField.text) {
            let alert = UIAlertController(title: "Username hasn't changed.", message: "Please enter a different username.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        } else if (userField.text == "") {
            let alert = UIAlertController(title: "Username cannot be empty.", message: "Please enter a different username.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        } else {
            username.text = userField.text
            let docRef = (db as AnyObject).collection("users").document(self.email)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let diet = (document.get("diet") as! [String])
                    let image = (document.get("image") as! String)
                    let recipes = (document.get("recipes") as! [String])
                    self.db.collection("users").document(self.email).setData([
                        "username" : self.userField.text!,
                        "email" : self.email,
                        "diet" : diet,
                        "image" : image,
                        "recipes" : recipes,
                    ])
                }
            }
            let alert = UIAlertController(title: "Username successfully changed!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
    }
    
    @IBAction func logoutClick(_ sender: Any) {
        do { try Auth.auth().signOut() }
            catch { print("already logged out") }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let vc : SignInViewController  = storyboard.instantiateViewController(identifier: "login") as! SignInViewController
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
    

