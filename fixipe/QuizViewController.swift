//
//  QuizViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 19/5/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class QuizViewController: UIViewController {
    
    var name = ""
    var email = ""
    var diet = [String]()
    var image = ""
    var recipes = [String]()
    var db = Firestore.firestore()

    @IBOutlet weak var glutenFree: UIButton!
    @IBOutlet weak var dairyFree: UIButton!
    @IBOutlet weak var eggFree: UIButton!
    @IBOutlet weak var nutFree: UIButton!
    @IBOutlet weak var vegan: UIButton!
    @IBOutlet weak var Paleo: UIButton!
    @IBOutlet weak var noSugar: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var veg: UIButton!
    @IBOutlet weak var dietLabel: UILabel!
    @IBOutlet weak var soyFree: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        glutenFree.layer.cornerRadius = 18
        dairyFree.layer.cornerRadius = 18
        eggFree.layer.cornerRadius = 18
        nutFree.layer.cornerRadius = 18
        vegan.layer.cornerRadius = 18
        Paleo.layer.cornerRadius = 18
        noSugar.layer.cornerRadius = 18
        nextButton.layer.cornerRadius = 18
        veg.layer.cornerRadius = 18
        dietLabel.center.x = self.view.center.x
        soyFree.layer.cornerRadius = 18
        
    }
    
    @available(iOS 13.0, *)
    @IBAction func nextClick(_ sender: Any) {
        self.db.collection("users").document(self.email).setData([
            "username" : self.name,
            "email" : self.email,
            "diet" : self.diet,
            "image" : self.image,
            "recipes" : self.recipes,
        ])
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UITabBarController = storyboard.instantiateViewController(identifier: "tab") as!
            UITabBarController
        let home : HomeViewController = storyboard.instantiateViewController(identifier: "home") as! HomeViewController
        let recipes : RecipesViewController = storyboard.instantiateViewController(identifier: "recipes") as! RecipesViewController
        let scan : ScanViewController = storyboard.instantiateViewController(identifier: "scan") as! ScanViewController
        vc.viewControllers = [home, recipes, scan]
        
        let docRef = (db as AnyObject).collection("users").document(self.email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                home.username.text = self.name
                recipes.email = self.email
                recipes.recipeHandles = self.recipes
                scan.email = self.email
                scan.diet = (document.get("diet") as! [String])
                print("Data retrived")
            } else {
                print("Document does not exist")
            }
        }
            //as? UITabBarController
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @IBAction func glutenClick(_ sender: Any) {
        diet.append("Gluten Free")
    }
    
    @IBAction func dairyClick(_ sender: Any) {
        diet.append("Dairy Free")
    }
    
    @IBAction func eggClick(_ sender: Any) {
        diet.append("Egg Free")
    }
    
    @IBAction func nutClick(_ sender: Any) {
        diet.append("Nut Free")
    }
    
    @IBAction func veganClick(_ sender: Any) {
        diet.append("Vegan")
    }
    
    @IBAction func paleoClick(_ sender: Any) {
        diet.append("Paleo")
    }
    
    @IBAction func noSugarClick(_ sender: Any) {
        diet.append("No Artificial Sugar")
    }
    
    @IBAction func soyClick(_ sender: Any) {
        diet.append("Soy Free")
    }
    
    
    @IBAction func vegClick(_ sender: Any) {
        diet.append("Vegetarian")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
