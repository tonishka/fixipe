//
//  ResetPasswordViewController.swift
//  fixipe
//
//  Created by Tonishka Singh on 15/7/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var goBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        send.center.x = self.view.center.x
        emailField.center.x = self.view.center.x
        resetLabel.center.x = self.view.center.x
        goBack.center.x = self.view.center.x
        send.layer.cornerRadius = 18
        goBack.layer.cornerRadius = 18
        let myColor = UIColor.gray
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = myColor.cgColor
    }
    
    @available(iOS 13.0, *)
    @IBAction func sendTapped(_ sender: Any) {
        let auth = Auth.auth()
        auth.sendPasswordReset(withEmail: emailField.text!) { (error) in
            if let error = error {
                let alertMessage = UIAlertController(title: "Holy Cow!", message:error.localizedDescription, preferredStyle: .alert)
                        alertMessage.addAction(UIAlertAction(title: "That's bananas!", style: .default, handler: nil))
                        self.present(alertMessage, animated: true, completion: nil)
                        return
                        
            }
            let alert = UIAlertController(title: "Hot Dog!", message: "A password reset email has been sent.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Back to login page", style: .default) { (action) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "login") as! SignInViewController
                self.present(vc, animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        return true
    }
}

    
    

