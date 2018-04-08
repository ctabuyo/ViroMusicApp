//
//  ResetPasswordViewController.swift
//  Viro
//
//  Created by Gonzalo Duarte  on 6/10/16.
//  Copyright © 2016 Gonzalo Duarte . All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    let emailSent = NSLocalizedString("email_sent", comment: "")
    let error = NSLocalizedString("email_not_sent", comment: "")
    

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var introLbl: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitBtnAction(_ sender: AnyObject) {
        if emailTxtField.text != ""{
        ParseAPIManager().lostPassword(emailTxtField.text!)
            
            introLbl.text = emailSent
        }else{
            introLbl.text = error
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
