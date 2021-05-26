//
//  ScanViewController.swift
//  fixipe
//
//  Created by Ananya Ravi on 24/5/21.
//  Copyright © 2021 Ananya Ravi. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var takePhoto: UIButton!
    @IBOutlet var choosePhoto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            imgView.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
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
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

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
        
    }

}
    
    
    



