//
//  RecipesViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 25/6/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RecipesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var email = ""
    var name = ""
    var recipeHandles = [String]()
    var searchRecipe: [String]!
    
    var searching = false
    let identifier = "cell"
    var replaceString = ""
    
    @IBOutlet weak var username : UILabel!
    @IBOutlet weak var allRecipes: UITableView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var recipes: UILabel!
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let docRef = (db as AnyObject).collection("users").document(self.email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.username.text = (document.get("username") as! String)
            }
        }
        searchRecipe = self.recipeHandles
        
        self.allRecipes.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        self.allRecipes.delegate = self
        self.allRecipes.dataSource = self
        self.search.delegate = self
        recipes.center.x = self.view.center.x
        username.center.x = self.view.center.x
        allRecipes.center.x = self.view.center.x
        allRecipes.center.y = self.view.center.y
        search.center.x = self.view.center.x
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRecipe = searchText.isEmpty ? searchRecipe : searchRecipe.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        allRecipes.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.search.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            search.showsCancelButton = false
            search.text = ""
            search.resignFirstResponder()
            searchRecipe = self.recipeHandles
        allRecipes.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.allRecipes.dequeueReusableCell(withIdentifier: identifier)
        let title = (self.searchRecipe[indexPath.row].components(separatedBy: "#") as! [String])
        cell?.textLabel?.text = title[0]
        return cell!
    }
    
    // OPENING UP A RECIPE THAT HAS ALREADY BEEN SAVED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let vc : EditViewController  = storyboard.instantiateViewController(identifier: "edit") as!
                EditViewController
            var title = (self.searchRecipe[indexPath.row].components(separatedBy: "#") as! [String])
            vc.email = self.email
            vc.name = title[0]
            vc.infoString = title[1]
            vc.replaceString = self.replaceString
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


