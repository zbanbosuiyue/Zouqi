//
//  LoginEnterPwdViewController.swift
//  Zouqiba
//
//  Created by Miibox on 9/6/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

class LoginEnterPwdViewController: BasicViewController, UITextFieldDelegate {
    @IBOutlet weak var LoginPwdTextField: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = false
        
        LoginPwdTextField.delegate = self
        LoginBtn.layer.cornerRadius = 5
        LoginBtn.backgroundColor = UIColor.grayColor()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func ClickLoginBtn(sender: AnyObject) {
        let email = localStorage.objectForKey(localStorageKeys.UserEmail) as! String
        let pwd = LoginPwdTextField.text!
        self.loginToWC(email, pwd: pwd, completion: {(Detail:String, Success: Bool) -> Void in
            if Success{
                print("clicked")
                self.navigationController?.pushViewController(MainViewController(), animated: true)
            } else{
                print(Detail)
            }
        })
    }
    
    func closeKeyboard(){
        LoginPwdTextField.resignFirstResponder()
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        ClickLoginBtn(LoginBtn)
        
        return true
    }
}
