//
//  CreateEmailView.swift
//  Zouqiba
//
//  Created by Miibox on 8/31/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit


class CreateEmailViewController: BasicViewController, UITextFieldDelegate{
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        EmailTextField.delegate = self
        ConfirmBtn.layer.cornerRadius = 5
        ConfirmBtn.isEnabled = false
        ConfirmBtn.backgroundColor = UIColor.init(rgb: 0xb9a6d4)
        
        TitleLabel.text = "Please enter your email address".localized()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CreateEmailViewController.closeKeyboard))
        self.view.addGestureRecognizer(singleTap)
    }
    
    
    @IBAction func ClickConfirmBtn(_ sender: AnyObject) {
        let email = EmailTextField.text!
        localStorage.set(email, forKey: localStorageKeys.UserEmail)
        if let _ = localStorage.object(forKey: localStorageKeys.UserPhone){
            finishLoginAlert("Success".localized(), message: email + " Logined".localized())
        } else{
            createProfileAlert()
        }
        
    }
    
    func closeKeyboard(){
        EmailTextField.resignFirstResponder()
    }
    
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text! as NSString
        let text = userEnteredString.replacingCharacters(in: range, with: string)
        
        if isValidEmail(text){
            ConfirmBtn.isEnabled = true
            ConfirmBtn.backgroundColor = UIColor.init(rgb: 0x744eaa)
            textField.backgroundColor = UIColor.clear
        } else {
            ConfirmBtn.isEnabled = false
            ConfirmBtn.backgroundColor = UIColor.init(rgb: 0xb9a6d4)
            textField.backgroundColor = UIColor.yellow
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ClickConfirmBtn(ConfirmBtn)

        return true
    }
}

