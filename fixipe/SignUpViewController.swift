//
//  SignUpViewController.swift
//  fixipe
//
//  Created by Tonishka Singh on 27/5/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

// baby tonix

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // send messages to you
        name.delegate = self
        email.delegate = self
        password.delegate = self
        // Do any additional setup after loading the view.
        let tap : UITapGestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(EditViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        signUpButton.layer.cornerRadius = 18
        loginButton.layer.cornerRadius = 18
        signUpLabel.center.x = self.view.center.x
        name.center.x = self.view.center.x
        email.center.x = self.view.center.x
        password.center.x = self.view.center.x
        signUpButton.center.x = self.view.center.x
        loginButton.center.x = self.view.center.x
        name.layer.cornerRadius = 2
        email.layer.cornerRadius = 2
        password.layer.cornerRadius = 2
        let myColor = UIColor.gray
        name.layer.borderColor = myColor.cgColor
        email.layer.borderColor = myColor.cgColor
        password.layer.borderColor = myColor.cgColor
        name.layer.borderWidth = 1
        email.layer.borderWidth = 1
        password.layer.borderWidth = 1
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @available(iOS 13.0, *)
    @IBAction func signUpTapped(_ sender: Any) {
        
        // display button that states you have not entered a name, and allows you to click 'Okay'
        if name.text?.isEmpty == true {
            //print("No text in email fied")
            let alert = UIAlertController(title: "Oh crepe!", message: "You have not entered a name. Please enter a valid name before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // same logic here
        if email.text?.isEmpty == true {
            //print("No text in email fied")
            let alert = UIAlertController(title: "Oh crab!", message: "You have not entered an email address. Please enter a valid email address before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        // same logic here
        if password.text?.isEmpty == true {
            let alert = UIAlertController(title: "Baba Ganoush!", message: "You have not entered a password. Please enter a valid password before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        signUp()
        
        let alert = UIAlertController(title: "Baba Ganoush!", message: "Seems like your email hasn't been verified. Please verify it by clicking on the link to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Back to sign up", style: .default, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
    // is this for if you already have an account
    @available(iOS 13.0, *)
    @IBAction func createAccountTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "login")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    // takes it to quiz
    @available(iOS 13.0, *)
    func signUp() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (authResult, error) in
        guard let user = authResult?.user, error == nil else {
            let alertMessage = UIAlertController(title: "Cheese and Crackers!", message:error?.localizedDescription, preferredStyle: .alert)
                    alertMessage.addAction(UIAlertAction(title: "That's bananas!", style: .default, handler: nil))
                    self.present(alertMessage, animated: true, completion: nil)
            
            //print("Error \(error?.localizedDescription)")
            return
        }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : QuizViewController = storyboard.instantiateViewController(withIdentifier: "quiz") as! QuizViewController
            vc.name = self.name.text!
            vc.email = self.email.text!
            //vc.password = self.password.text!
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    // return key tapped to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        name.resignFirstResponder()
        email.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
   
}


    
  


    
    

    


