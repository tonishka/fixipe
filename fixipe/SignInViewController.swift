//
//  LoginViewController.swift
//  fixipe
//
//  Created by Tonishka Singh on 27/5/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccButton: UIButton!
    @IBOutlet weak var fixipe: UILabel!
    var db : Any! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        db = Firestore.firestore()
        let tap : UITapGestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(EditViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        loginButton.layer.cornerRadius = 18
        createAccButton.layer.cornerRadius = 18
        fixipe.center.x = self.view.center.x
        loginButton.center.x = self.view.center.x
        createAccButton.center.x = self.view.center.x
        email.center.x = self.view.center.x
        forgotPassButton.center.x = self.view.center.x
        password.center.x = self.view.center.x
        let myBorder = UIColor.gray
        email.layer.borderColor = myBorder.cgColor
        password.layer.borderColor = myBorder.cgColor
        email.layer.borderWidth = 1
        password.layer.borderWidth = 1
        email.layer.cornerRadius = 2
        password.layer.cornerRadius = 2
    }
    
    @IBAction func forgotPassTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "forgotPasstoResetSeg", sender: nil)
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @available(iOS 13.0, *)
    @IBAction func loginTapped(_ sender: Any) {
        validateFields()
    }
    
    // takes it to the sign up page
    @available(iOS 13.0, *)
    @IBAction func createAccountTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "signUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
        
    }
    
    // same logic as entering fields in the signUp screen
    @available(iOS 13.0, *)
    func validateFields() {
        
        if email.text?.isEmpty == true {
            let alert = UIAlertController(title: "Email field cannot be empty.", message: "Please enter an email address before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if password.text?.isEmpty == true {
            let alert = UIAlertController(title: "Password field cannot be empty.", message: "Please enter your password before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        login()
    }
    
    @available(iOS 13.0, *)
    func login() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { [weak self] authResult, err in
            guard let strongSelf = self else { return }
            if let err = err {
                //print(err.localizedDescription)
                let alert = UIAlertController(title: "Your credentials are incorrect.", message: "Please check your email and password before continuing.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self!.present(alert, animated: true)
            }
            self!.checkUserInfo()
        }
    }
    
    // this takes you to the homepage (THIS IS PRETTY MUNDANE)
    @available(iOS 13.0, *)
    func checkUserInfo() {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!.uid)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UITabBarController = storyboard.instantiateViewController(identifier: "tab") as!
                UITabBarController
            
            let home : HomeViewController = storyboard.instantiateViewController(identifier: "home") as! HomeViewController
            let recipes : RecipesViewController = storyboard.instantiateViewController(identifier: "recipes") as! RecipesViewController
            let scan : ScanViewController = storyboard.instantiateViewController(identifier: "scan") as! ScanViewController
            vc.viewControllers = [home, recipes, scan]
            
            let docRef = (db as AnyObject).collection("users").document(self.email.text!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    home.username.text = (document.get("username") as! String)
                    home.email = self.email.text!
                    //recipes.name = (document.get("username") as! String)
                    recipes.email = self.email.text!
                    recipes.recipeHandles = (document.get("recipes") as! [String])
                    scan.email = self.email.text!
                    scan.diet = (document.get("diet") as! [String])
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                    print("Data retrived")
                }
            }
                //as? UITabBarController
        }
    }
    
    // same logic as in signUp
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
}
