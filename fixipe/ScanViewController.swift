//
//  ScanViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 24/5/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import Firebase
import FirebaseAuth

@available(iOS 13.0, *)
class ScanViewController: UIViewController {
    
    typealias Rational = (num : Int, den : Int)
    var email = ""
    var diet = [String]()
    var ingredients = [String]()
    var measurements = ["cup", "cups", "teaspoon", "teaspoons", "tablespoon", "tablespoons",
                        "oz", "grams", "gram", "large", "medium", "egg", "eggs", "ml", "l", "gm"]
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet var choosePhoto: UIButton!
    @IBOutlet weak var editPhoto: UIButton!
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            imgView.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        choosePhoto.layer.cornerRadius = 18
        takePhoto.layer.cornerRadius = 18
        editPhoto.layer.cornerRadius = 18
        editPhoto.center.x = self.view.center.x
    }
    
    @IBAction func takeButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    @IBAction func chooseClick(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // PICTURE TAKEN -> READS ALL THE INGREDIENTS + USES DIETARY RESTRICTIONS TO FIND REPLACEMENTS
    @available(iOS 13.0, *)
    @IBAction func editClick(_ sender: Any) {
        if imgView.image == nil {
            let alert = UIAlertController(title: "Image needs to be picked", message: "Please choose an image before continuing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : EditViewController  = storyboard.instantiateViewController(identifier: "edit") as!
            EditViewController
        vc.email = self.email
        let docRef = (db as AnyObject).collection("users").document(self.email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let imgVal = (document.get("image") as! String).components(separatedBy: "#")
                vc.infoString = imgVal[0]
                vc.replaceString = imgVal[1]
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    func recognizeImage() {
        guard let cgImage = imgView.image?.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
       
        do {
            try requestHandler.perform([request])
            self.getText(request)
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    
    func getText(_ request: VNRecognizeTextRequest) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        _ = observations.compactMap { item in
            let i: String = item.topCandidates(1).first!.string
            self.ingredients.append(i)
        }
        
        self.storeSubs()
    }

    func storeSubs() {
        var infoString = ""
        var replaceString = ""
        for ingredient in ingredients {
            
            let tempArray = ingredient.components(separatedBy: " ")
            var value = ""
            for element in tempArray {
                if (self.measurements.contains(element.lowercased())) {
                        break
                }
                value += element
            }
            
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
            
            if (tempArray.count == 1) {
                // do nothing
            } else {
                var substitute = false
                for d in self.diet {
                    let dbRef = (db as AnyObject).collection(d)
                    dbRef.getDocuments() { (querySnapshot, error) in
                        for document in querySnapshot!.documents {
                            if (ingredient.contains(document.documentID) || ingredient.contains(document.documentID.lowercased())) {
                                let substituteVal = (document.get("1") as! String).components(separatedBy: ",")
                                
                                var newIngredient = ""
                                for word in (document.get("words") as! [String]) {
                                    if (ingredient.contains(word)) {
                                        newIngredient = ingredient.replacingOccurrences(of: word, with: "")
                                    }
                                }
                                
                                var change = [String]()
                                if (newIngredient.contains(document.documentID)) {
                                    change = newIngredient.components(separatedBy: document.documentID)
                                } else {
                                    change = newIngredient.components(separatedBy: document.documentID.lowercased())
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
                            
                                var newQuantity = ""
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

                                change[0] = change[0].replacingOccurrences(of: value, with: "")
                                let subTip = substituteVal[0] + "\n"
                                let newLine = "Sub: " + newQuantity + " " + change[0] + " " + subTip
                                infoString += newLine
                                replaceString += d + "^" + document.documentID + "^" + subTip + "^" + substituteVal[1] +
                                    "^" + newLine + "^" + value + "^" + newQuantity + "^" + "_"
                                substitute = true
                            } else if (!infoString.contains(ingredient) && !substitute) {
                                infoString += ingredient + "\n"
                            }
                        }
                        if (substitute) {
                            infoString = infoString.replacingOccurrences(of: ingredient + "\n", with: "")
                        }
                        self.db.collection("users").document(self.email).updateData([
                            "image" : infoString + "#" + replaceString])
                   }
                }
            }
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
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

@available(iOS 13.0, *)
extension ScanViewController :  UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerEditedImage] as?
                UIImage else {
            return
        }
        imgView.image = image;
        self.recognizeImage()
        
    }
    
}






