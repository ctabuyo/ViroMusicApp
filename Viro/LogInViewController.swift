//
//  LogInViewController.swift
//  BiroTKTransitionSubmitButton
//
//  Created by Gonzalo Duarte  on 8/8/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit
import Parse
import StoreKit
import SCLAlertView


class LogInViewController: UIViewController,UITextFieldDelegate, UIViewControllerTransitioningDelegate{
    
    //MARK: - LOCALIZABLE VARIABLES
    let Title = NSLocalizedString("login_title", comment: "")
    let noAccountTitle = NSLocalizedString("noacc_title", comment: "")
    let noAccount = NSLocalizedString("noacc", comment: "")
    let errorTitle = NSLocalizedString("error_title", comment: "")
    let errorMessage = NSLocalizedString("error_message", comment: "")
    let warningTitle = NSLocalizedString("warning_title", comment: "")
    let warningMessage = NSLocalizedString("warning_Mesage", comment: "")
    let wrongPasswordTitle = NSLocalizedString("wrong_Pass_title", comment: "")
    let wrongPasswordMessage = NSLocalizedString("wrong_Pass_message", comment: "")
    let welcome = NSLocalizedString("welcome_Title", comment: "")
    let welcomeMessage = NSLocalizedString("welcome_Message", comment: "")
    //MARK: - IB OUTLET
    
    @IBOutlet weak var registerSpinner: UIActivityIndicatorView!
    @IBOutlet weak var registerRepeatPass: UITextField!
    @IBOutlet weak var registerCloseBtnOutlet: UIButton!
    @IBOutlet weak var registerUsername: UITextField!
    @IBOutlet weak var registerPassfield: UITextField!
    @IBOutlet weak var regiterEmail: UITextField!
    @IBOutlet weak var registerBtnOutlet: UIButton!
    @IBOutlet weak var forgotPassOutlet: UIButton!
    @IBOutlet weak var logInCloseBtnOutlet: UIButton!
    @IBOutlet weak var logInUsername: UITextField!
    @IBOutlet weak var logInPassfield: UITextField!
    @IBOutlet weak var logInSpinner: UIActivityIndicatorView!
    @IBOutlet weak var logInBtnOutlet: UIButton!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var logInView: UIView!
    @IBOutlet weak var probsLbl: UILabel!
    @IBOutlet weak var displeyRegisterBtnOutlet: UIButton!
    @IBOutlet weak var displayLogInBtnOutlet: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    //MARK: - OVERRIDE FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        
        UserDefaults.standard.set(DismissButton, forKey: "DismissButton")
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        registerView.isHidden = true
        registerView.alpha = 0
        logInView.isHidden = true
        logInView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // probsLbl.font = UIFont.boldSystemFont(ofSize: 30.0)
        probsLbl.text = "This \nis \nViro."
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If user is loged in, go to the next view
        if PFUser.current() != nil{
            self.performSegue(withIdentifier: "goToAppFromLogIn", sender: self)
            print(" the current user is NOT nil")
        }else{
            print("the user is nil")
        }
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customLogInUI()
        customRegisterUI()
    }

   
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MY FUNCTIONS
    func customRegisterUI(){
        self.registerUsername.borderStyle = .none
        self.registerPassfield.borderStyle = .none
        self.registerRepeatPass.borderStyle = .none
        self.regiterEmail.borderStyle = .none
        
        self.registerUsername.leftViewMode = UITextFieldViewMode.always
        self.registerPassfield.leftViewMode = UITextFieldViewMode.always
        self.registerRepeatPass.leftViewMode = UITextFieldViewMode.always
        self.regiterEmail.leftViewMode = UITextFieldViewMode.always
        
        self.registerUsername.delegate = self
        self.registerPassfield.delegate = self
        self.registerRepeatPass.delegate = self
        self.regiterEmail.delegate = self
        
        let border = CALayer()
        let border1 = CALayer()
        let border2 = CALayer()
        let border3 = CALayer()
        
        let width = CGFloat(1.5)
        let width1 = CGFloat(1.5)
        let width2 = CGFloat(1.5)
        let width3 = CGFloat(1.5)
        
        border.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
        border1.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
        border2.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
        border3.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
        
        border.frame = CGRect(x: 0, y: registerUsername.frame.size.height - width, width:  registerUsername.frame.size.width, height: registerUsername.frame.size.height)
        border1.frame = CGRect(x: 0, y: registerPassfield.frame.size.height - width1, width:  registerPassfield.frame.size.width, height: registerPassfield.frame.size.height)
        border2.frame = CGRect(x: 0, y: registerRepeatPass.frame.size.height - width2, width:  registerRepeatPass.frame.size.width, height: registerRepeatPass.frame.size.height)
        border3.frame = CGRect(x: 0, y: regiterEmail.frame.size.height - width3, width:  regiterEmail.frame.size.width, height: regiterEmail.frame.size.height)
        
        border.borderWidth = width
        border1.borderWidth = width1
        border2.borderWidth = width2
        border3.borderWidth = width3
        
        registerUsername.layer.addSublayer(border)
        registerPassfield.layer.addSublayer(border1)
        registerRepeatPass.layer.addSublayer(border2)
        regiterEmail.layer.addSublayer(border3)
    }
    
    
    func customLogInUI(){
        
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
    
        // Customize UserField
        
        
        self.logInUsername.borderStyle = .none
        self.logInUsername.leftViewMode = UITextFieldViewMode.always
        logInUsername.delegate = self
        border.frame = CGRect(x: 0, y: logInUsername.frame.size.height - width, width:  logInUsername.frame.size.width, height: logInUsername.frame.size.height)
        
        border.borderWidth = width
        logInUsername.layer.addSublayer(border)
        //Customize Button
        
        
        logInBtnOutlet.clipsToBounds = true
        
        // Customize PassField
        
        
        logInPassfield.borderStyle = .none
        self.logInPassfield.leftViewMode = UITextFieldViewMode.always
        logInPassfield.delegate = self
        let border1 = CALayer()
        let width1 = CGFloat(1.5)
        border1.borderColor = UIColor(red: 46.0/255.0, green: 66.0/255.0 , blue: 92.0/255.0, alpha: 1.0).cgColor
        border1.frame = CGRect(x: 0, y: logInPassfield.frame.size.height - width, width:  logInPassfield.frame.size.width, height: logInPassfield.frame.size.height)
        
        border1.borderWidth = width1
        logInPassfield.layer.addSublayer(border1)
    
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
        let alertAct = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(alertAct)
        present(alertVC, animated: true, completion: nil)
        
    }
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    
    //MARK: - IB ACTIONS
    
    @IBAction func logInButton(_ sender: AnyObject) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        logInSpinner.startAnimating()
        logInBtnOutlet.setTitle("", for: .normal)
        PFUser.logInWithUsername(inBackground: self.logInUsername.text!, password:self.logInPassfield.text!) {
            (user: PFUser?, loginError: Error?) -> Void in
            if user != nil {
                print("The user has accessed!!")
                UserDefaults.standard.set(false, forKey: "noAccount")
                self.performSegue(withIdentifier: "goToAppFromLogIn", sender: self)
                self.logInUsername.text = ""
                self.logInPassfield.text = ""
                self.logInSpinner.stopAnimating()
                self.logInBtnOutlet.setTitle("Log In", for: .normal)
                
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                if let errorData = loginError {
                    
                    //Checking if there's an error. In affirmative case, display it to the user.
                    if let errorString = errorData.localizedDescription as NSString! {
                        let alertView = SCLAlertView()
                        alertView.showError("Error", subTitle: errorString as String)
                        self.logInSpinner.stopAnimating()
                        self.logInBtnOutlet.setTitle("Log In", for: .normal)
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        
                    }else{
                        let alertView = SCLAlertView()
                        alertView.showError("Error", subTitle: "Error")
                        self.logInSpinner.stopAnimating()
                        self.logInBtnOutlet.setTitle("Log In", for: .normal)
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                }
            }
        }
    }
    
    @IBAction func registerCloseBtnAction(_ sender: Any) {
        dismissKeyboard()
        self.displayLogInBtnOutlet.isHidden = false
        self.displeyRegisterBtnOutlet.isHidden = false
        self.probsLbl.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.registerView.alpha = 0
            self.probsLbl.alpha = 1
            self.displeyRegisterBtnOutlet.alpha = 1
            self.displayLogInBtnOutlet.alpha = 1
        })
        delay(0.3){
            self.registerView.isHidden = true
        }
    }
    
    @IBAction func logInCloseBtnAction(_ sender: Any) {
        dismissKeyboard()
        self.displayLogInBtnOutlet.isHidden = false
        self.displeyRegisterBtnOutlet.isHidden = false
        self.probsLbl.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.logInView.alpha = 0
            self.probsLbl.alpha = 1
            self.displeyRegisterBtnOutlet.alpha = 1
            self.displayLogInBtnOutlet.alpha = 1
        })
        delay(0.3){
            self.logInView.isHidden = true
        }
    }
    
    @IBAction func displayRegisterAction(_ sender: Any) {
        self.registerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.registerView.alpha = 1
            self.probsLbl.alpha = 0
            self.displeyRegisterBtnOutlet.alpha = 0
            self.displayLogInBtnOutlet.alpha = 0
        })
        delay(0.3){
            self.displayLogInBtnOutlet.isHidden = true
            self.displeyRegisterBtnOutlet.isHidden = true
            self.probsLbl.isHidden = true
        }
    }
    
    @IBAction func displayLogInAction(_ sender: Any) {
        self.logInView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.logInView.alpha = 1
            self.probsLbl.alpha = 0
            self.displeyRegisterBtnOutlet.alpha = 0
            self.displayLogInBtnOutlet.alpha = 0
        })
        delay(0.3){
            self.displayLogInBtnOutlet.isHidden = true
            self.displeyRegisterBtnOutlet.isHidden = true
            self.probsLbl.isHidden = true
        }
    }
    
    @IBAction func registerBtnAction(_ sender: Any) {
        registerSpinner.isHidden = false
        registerSpinner.startAnimating()
        registerBtnOutlet.setTitle("", for: .normal)
        let user = PFUser()
        if registerPassfield.text != "" && regiterEmail.text != "" && registerUsername.text != "" && registerRepeatPass.text != "" {
            UIApplication.shared.beginIgnoringInteractionEvents()
            if self.registerPassfield.text == self.registerRepeatPass.text{
                user.username = self.registerUsername.text
                user.password = self.registerPassfield.text
                user.email = self.regiterEmail.text
                
                user.signUpInBackground {
                    (succeeded: Bool, signUpError: Error?) -> Void in
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let errorData = signUpError {
                        
                        if let errorString = errorData as? NSString{
                            let alertView = SCLAlertView()
                            
                            alertView.showError(self.errorTitle, subTitle: errorString as String)
                            self.registerSpinner.stopAnimating()
                            self.registerBtnOutlet.setTitle("Register", for: .normal)
                        }else{
                            self.dismissKeyboard()
                            let alertView = SCLAlertView()
                            
                            alertView.showNotice(self.errorTitle, subTitle: self.errorMessage)
                            self.registerSpinner.stopAnimating()
                            self.registerBtnOutlet.setTitle("Register", for: .normal)
                        }
                        
                        
                    } else {
                        
                        self.dismissKeyboard()
                        
                        let alertView = SCLAlertView()
                        alertView.addButton("Register!") {
                            ParseAPIManager().postDataFromNewUser()
                            self.registerUsername.text = ""
                            self.registerPassfield.text = ""
                            self.registerRepeatPass.text = ""
                            self.regiterEmail.text = ""
                            self.performSegue(withIdentifier: "goToAppFromLogIn", sender: self)
                        }
                        self.registerSpinner.stopAnimating()
                        self.registerBtnOutlet.setTitle("Register", for: .normal)
                        alertView.showNotice(self.welcome, subTitle: self.welcomeMessage)
                    }
                    
                }
            }else{
                let alertView = SCLAlertView()
                
                
                alertView.showError(self.wrongPasswordTitle, subTitle: self.wrongPasswordMessage)
                self.registerSpinner.stopAnimating()
                self.registerBtnOutlet.setTitle("Register", for: .normal)
                
            }
        }else{
            let alertView = SCLAlertView()
            
            
            alertView.showError(self.warningTitle, subTitle: self.warningMessage)
            self.registerSpinner.stopAnimating()
            self.registerBtnOutlet.setTitle("Register", for: .normal)
            
        }
        
    }
    
    @IBAction func proceedNoAccount(_ sender: Any) {
        let alertView = SCLAlertView()
        alertView.addButton(proceedNoCount) {
            self.performSegue(withIdentifier: "goToAppFromLogIn", sender: self)
            UserDefaults.standard.set(true, forKey: "noAccount")
        }
        alertView.showInfo(noAccountTitle, subTitle: noAccount)
        
       
    }
    
    @IBAction func buyIAP(_ sender: Any) {
        
    }
    
    
    @IBAction func unwindToLogInFromMain(_ segue: UIStoryboardSegue) {
        PFUser.logOut()
    }
 
}
