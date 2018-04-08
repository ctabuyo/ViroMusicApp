//
//  CreatePlaylistViewController.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 24/9/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class CreatePlaylistViewController: UIViewController {
    
    //MARK: - LOCALIZABLE VARIABLES
    let cancelTitle = NSLocalizedString("cancel_title", comment: "")
    let takePictureTitle = NSLocalizedString("take_picture_title", comment: "")
    let libraryTitle = NSLocalizedString("library_title", comment: "")
    
    //MARK: - IB OUTLETS

    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var nameTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func addImageBtn(_ sender: AnyObject) {
        showPhotoMenu()
    }

    @IBAction func createPlaylistBtn(_ sender: AnyObject) {
        
        if nameTxtField.text != ""{
            ParseAPIManager().createPlaylistManager(nameTxtField.text!, image: playlistImage.image!)
            performSegue(withIdentifier: "returnSegue2", sender: self)
        }
    }
}


extension CreatePlaylistViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func pickerPhoto(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
            
        }else{
            choosePhotoFromLibrary()
        }
        
    }
    
    func showPhotoMenu(){
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: takePictureTitle, style: .default) { (alert) -> Void in
            self.takePhotoWithCamera()
        }
        let chooseFromLibrary = UIAlertAction(title: libraryTitle, style: .default) { (action) -> Void in
            self.choosePhotoFromLibrary()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibrary)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromLibrary(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        playlistImage.image = image
        
        dismiss(animated: true, completion: nil)
        
        
        
        
    }
    
    
}
