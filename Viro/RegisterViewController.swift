 //
//  RegisterViewController.swift
//  Biro
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class RegisterViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    //LOCALIZABLE VARIABLES
    let errorTitle = NSLocalizedString("error_title", comment: "")
    let errorMessage = NSLocalizedString("error_message", comment: "")
    let warningTitle = NSLocalizedString("warning_title", comment: "")
    let warningMessage = NSLocalizedString("warning_Mesage", comment: "")
    let wrongPasswordTitle = NSLocalizedString("wrong_Pass_title", comment: "")
    let wrongPasswordMessage = NSLocalizedString("wrong_Pass_message", comment: "")
    let welcome = NSLocalizedString("welcome_Title", comment: "")
    let welcomeMessage = NSLocalizedString("welcome_Message", comment: "")
    //MARK: - IB OUTLETS
    @IBOutlet weak var UserField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PassField1: UITextField!
    @IBOutlet weak var PassField2: UITextField!
    
    @IBOutlet weak var SignUpBtn: UIButton!
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.userRegistered),name:NSNotification.Name(rawValue: "newUserCreated"), object: nil) 
        // Customize UserField
        self.UserField.borderStyle = .none
        self.UserField.leftViewMode = UITextFieldViewMode.always
        UserField.layer.cornerRadius = 20
        // Customize EmailField
        self.EmailField.borderStyle = .none
        self.EmailField.leftViewMode = UITextFieldViewMode.always
        EmailField.layer.cornerRadius = 20
        // Customize PassField1
        self.PassField1.borderStyle = .none
        self.PassField1.leftViewMode = UITextFieldViewMode.always
        PassField1.layer.cornerRadius = 20
        // Customize PassField2
        self.PassField2.borderStyle = .none
        self.PassField2.leftViewMode = UITextFieldViewMode.always
        PassField2.layer.cornerRadius = 20
        // Customize SignUpBtn
        SignUpBtn.layer.cornerRadius = 23
        SignUpBtn.clipsToBounds = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidLayoutSubviews() {
    
    }
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    //MARK: - MY FUNCTIONS
    func userRegistered(){
        self.performSegue(withIdentifier: "goToAppFromSignUp", sender: self)
    
    }
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            else {
                
            }
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            else {
                
            }
        }
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func showAlertVC(_ titleData : String, messageData : String ){
        
        let alertVC = UIAlertController(title: titleData, message: messageData, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
            
        }))
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
    //MARK: - IB ACTIONS
    
    //Back buttons
    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBack2(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    //Sign Up button
    @IBAction func registerButton(_ sender: AnyObject) {
        
        let user = PFUser()
        if PassField2.text != "" && EmailField.text != "" && UserField.text != "" && PassField1.text != "" {
            UIApplication.shared.beginIgnoringInteractionEvents()
            if self.PassField1.text == self.PassField2.text{
                user.username = self.UserField.text
                user.password = self.PassField1.text
                user.email = self.EmailField.text
                
                user.signUpInBackground {
                    (succeeded: Bool, signUpError: Error?) -> Void in
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let errorData = signUpError {
                        
                        if let errorString = errorData as? NSString{
                            let alertView = SCLAlertView()
                            
                            alertView.showError(self.errorTitle, subTitle: errorString as String)
                        }else{
                            self.dismissKeyboard()
                            let alertView = SCLAlertView()
                            
                            alertView.showNotice(self.errorTitle, subTitle: self.errorMessage)
                        }
                        
                        
                    } else {
                        self.UserField.text = ""
                        self.PassField1.text = ""
                        self.PassField2.text = ""
                        self.EmailField.text = ""
                        
                        let alertView = SCLAlertView()
                        alertView.addButton("Register!") {
                            ParseAPIManager().postDataFromNewUser()
                        }
                        
                        alertView.showNotice(self.welcome, subTitle: self.welcomeMessage)
                    }
                    
                }
            }else{
                let alertView = SCLAlertView()
                
                
                alertView.showError(self.wrongPasswordTitle, subTitle: self.wrongPasswordMessage)

                
            }
        }else{
            let alertView = SCLAlertView()
            
            
            alertView.showError(self.warningTitle, subTitle: self.warningMessage)

            
        }
        
    }
}
