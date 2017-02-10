//
//  ViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/3/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit


class MainViewController: MainBasicViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if QRMessage != nil{
            gotoURL(QRMessage)
        }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func initViews(){
        setNav()
        setMainMenuView()
        setMoreMenu()
        setKKMainWebView()
        
        setupUserImage()
        getCookiesAndRedirect()
        isInit = false
    }
    
    
    func setupUserImage(){
        if let userHeadImgURL = localStorage.object(forKey: localStorageKeys.UserHeadImageURL){
        }else{
            let createImageAlter = UIAlertController(title: "Add Profile", message: "You can add your profile now or later", preferredStyle: .alert)
            let createImageOKAction = UIAlertAction(title: "Setup Now", style: .default, handler: { (UIAlertAction) in
                self.setUserProfile()
            })
            
            let createImageCancelAction = UIAlertAction(title: "Later", style: .cancel, handler:nil)
   
            createImageAlter.addAction(createImageOKAction)
            createImageAlter.addAction(createImageCancelAction)
            DispatchQueue.main.async(execute: {
                self.present(createImageAlter, animated: true, completion: {
                    
                })
            })
        }
    }

    func getCookiesAndRedirect(){
        if LoginHTMLString != nil {
            //mainWebView.loadHTMLString(NetworkErrorMsg, BaseURL: NSURL(string: BaseURL))
            
            let url = URL(string: BaseURL)!
            let request = NSMutableURLRequest(url: url)
            request.addValue(cookieString, forHTTPHeaderField: "Cookie")
            mainWebView.load(request as URLRequest)
            //mainWebView.loadHTMLString(LoginHTMLString, baseURL: url)
            
        } else{
            gotoURL(BaseURL)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


