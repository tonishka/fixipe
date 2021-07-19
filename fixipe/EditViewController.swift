//
//  EditViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 15/6/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditViewController: UIViewController {

    var email = ""
    var name = ""
    var didScan = false
    var infoString = ""
    var replaceString = ""
   
    typealias Rational = (num : Int, den : Int)
    var diet = [String]()
    var collDoc = [String]()
    var items = [String]()
    
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var info: UITextView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var alternatives: UIButton!
    var db = Firestore.firestore()


    override func viewDidLoad() {
        super.viewDidLoad()
        recipeName.text = self.name
        self.makeBold(self.infoString)
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
        alternatives.layer.cornerRadius = 18
        alternatives.center.x = self.view.center.x
        save.layer.cornerRadius = 18
        delete.layer.cornerRadius = 18
        recipeName.center.x = self.view.center.x
        info.center.x = self.view.center.x
        info.center.y = self.view.center.y
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    func makeBold(_ text: String) {
        let arrayRecipe = text.components(separatedBy: "\n")
            let viewString = NSMutableAttributedString(string: "")
                for element in arrayRecipe {
                    if (!element.contains("Sub:")) {
                        let addInfo: NSMutableAttributedString = NSMutableAttributedString(string: element + "\n")
                        addInfo.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: addInfo.length))
                        viewString.append(addInfo)
                    } else  {
                        let bold = NSMutableAttributedString(string: element + "\n")
                        bold.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)], range: NSRange(location: 0, length: element.count))
                        viewString.append(bold)
                    }
                }
                self.info.attributedText = viewString
                
    }
                
    // ALTERING A RECIPE - RANDOM GENERATION IN DATABASE
    @IBAction func alterClick(_ sender: Any) {
        self.collDoc = replaceString.components(separatedBy: "_")
        if (self.collDoc.count > 0) { self.collDoc.removeLast() }
        self.replaceString = ""
        self.infoString = self.info.attributedText.string
        var count = 0
        while (count < collDoc.count) {
            let replaceArray = collDoc[count].components(separatedBy: "^")
            let docRef = (db as AnyObject).collection(replaceArray[0]).document(replaceArray[1])
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let randomInt = Int.random(in: 1...(document.get("fieldCount") as! Int))
                    let substituteVal = (document.get(String(randomInt)) as! String).components(separatedBy: ",")
                    let newTip = substituteVal[0]  + "\n"
                    var newLine = replaceArray[4].replacingOccurrences(of: replaceArray[2], with: newTip)
                    var newQuantity = ""
                    
                    if (newLine.contains("*")) {
                        newLine = newLine.replacingOccurrences(of: replaceArray[3], with: substituteVal[1])
                    } else {
                        let value = replaceArray[5]
                        
                        var quantity: Double = 0.0
                        for num in value.components(separatedBy: " ") {
                            if (num.contains("/")) {
                                let frac = num.components(separatedBy: "/")
                                let numerator = Double(frac[0])
                                let denominator = Double(frac[1])
                                if (numerator != nil && denominator != nil) {
                                    quantity += numerator!/denominator!
                                }
                            } else if (Double(num) != nil) {
                                quantity += Double(num)!
                            }
                        }
                        
                        var ratio = 0.0
                        if (substituteVal[1].contains("/")) {
                            let frac = substituteVal[1].components(separatedBy: "/")
                            let numerator = Double(frac[0])
                            let denominator = Double(frac[1])
                            if (numerator != nil && denominator != nil) {
                                ratio = numerator!/denominator!
                            }
                        } else {
                            ratio = Double(substituteVal[1])!
                        }
                    
                        if (quantity != 0.0 && ratio != 0.0) {
                            let frac = self.rationalApproximationOf(x0: quantity * ratio)
                            if (frac.den == 1) {
                                newQuantity = String(frac.num)
                            } else {
                                newQuantity = String(frac.num) + "/" + String(frac.den)
                            }
                        } else {
                            newQuantity = value + "*" + substituteVal[1]
                        }
                        
                        newLine = newLine.replacingOccurrences(of: replaceArray[6], with: newQuantity)
                    }
                    self.infoString = self.infoString.replacingOccurrences(of: replaceArray[4], with: newLine)
                    self.replaceString += replaceArray[0] + "^" + document.documentID + "^" + newTip +
                        "^" + substituteVal[1] + "^" + newLine + "^" + replaceArray[5] + "^" + newQuantity + "^"  + "_"
                    self.makeBold(self.infoString)
                }
            }
            count += 1
        }
    }
    
    func rationalApproximationOf(x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
        var x = x0
        var a = floor(x)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)

        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = floor(x)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
    
    // DELETING A RECIPE - GETTING RID OF IT IN THE DATABASE
    @available(iOS 13.0, *)
    @IBAction func deleteClick(_ sender: Any) {
        if Auth.auth().currentUser != nil {
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
                    var temp = (document.get("recipes") as! [String])
                    //recipes.name = (document.get("username") as! String)
                    recipes.email = self.email
                   
                    var index = 0;
                    for d in (document.get("recipes") as! [String]) {
                        let tempSep = d.components(separatedBy: "#")
                        if (tempSep.contains(self.recipeName.text!)) {
                            temp.remove(at: index)
                            self.db.collection("users").document(self.email).updateData([
                                "recipes" : temp])
                            break
                        }
                        index += 1
                    }
                    recipes.recipeHandles = temp
                    home.email = self.email
                    home.username.text = (document.get("username") as! String)
                    recipes.replaceString = self.replaceString
                    scan.email = self.email
                    scan.diet = (document.get("diet") as! [String])
                    print("Data retrived")
                } else {
                    print("Document does not exist")
                }
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
            
        }
    }
    
    // SAVING A RECIPE - RETURNING TO THE HOMEPAGE
    @available(iOS 13.0, *)
    @IBAction func saveClick(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UITabBarController = storyboard.instantiateViewController(identifier: "tab") as!
            UITabBarController
                    
        let home : HomeViewController = storyboard.instantiateViewController(identifier: "home") as! HomeViewController
        let recipes : RecipesViewController = storyboard.instantiateViewController(identifier: "recipes") as! RecipesViewController
        let scan : ScanViewController = storyboard.instantiateViewController(identifier: "scan") as! ScanViewController
        vc.viewControllers = [home, recipes, scan]

        let addString = self.recipeName.text! + "#" + self.infoString
        let docRef = (db as AnyObject).collection("users").document(self.email)
        docRef.getDocument {  (document, error) in
            if let document = document, document.exists {
                var array = [String]()
                var exists = false
                
                for d in (document.get("recipes") as! [String]) {
                    let tempSep = d.components(separatedBy: "#")
                    if (tempSep[0] == self.recipeName.text!) {
                        exists = true
                        array.append(addString)
                    } else {
                        array.append(d)
                    }
                }
                if (!exists) {
                    array.append(addString)
                }
                
                self.db.collection("users").document(self.email).updateData([
                        "recipes" : array])
                recipes.recipeHandles = array
                home.username.text = (document.get("username") as! String)
                recipes.replaceString = self.replaceString
                recipes.email = self.email
                scan.email = self.email
                home.email = self.email
                scan.diet = (document.get("diet") as! [String])
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
    }

}
