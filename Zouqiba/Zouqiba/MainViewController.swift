//
//  ViewController.swift
//  zouqiTest2
//
//  Created by Miibox on 8/3/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit
import ImagePicker

class MainViewController: MainBasicViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if QRMessage != nil{
            gotoURL(QRMessage)
        }
    }
    
    func initViews(){
        setNav()
        setupUserImage()
        getCookiesAndRedirect()
        setMainMenuView()
        setMoreMenu()
        setKKMainWebView()
        isInit = false
    }
    
    
    func setupUserImage(){
        if let userHeadImgURL = localStorage.objectForKey(localStorageKeys.UserHeadImageURL){
        }else{
            let createImageAlter = UIAlertController(title: "Add Profile", message: "You can add your profile now or later", preferredStyle: .Alert)
            let createImageOKAction = UIAlertAction(title: "Setup Now", style: .Default, handler: { (UIAlertAction) in
                let imagePickerVC = ImagePickerController()
                imagePickerVC.navigationController?.navigationBar.hidden = true
                imagePickerVC.delegate = self
                imagePickerVC.imageLimit = 1
                
                self.navigationController?.pushViewController(imagePickerVC, animated: true)
            })
            
            let createImageCancelAction = UIAlertAction(title: "Later", style: .Cancel, handler:nil)
            
            
            
            createImageAlter.addAction(createImageOKAction)
            createImageAlter.addAction(createImageCancelAction)
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(createImageAlter, animated: true, completion: {
                    
                })
            })
        }
    }

    func getCookiesAndRedirect(){
        if LoginHTMLString != nil {
            //mainWebView.loadHTMLString(NetworkErrorMsg, BaseURL: NSURL(string: BaseURL))
            
            let url = NSURL(string: BaseURL)!
            let request = NSMutableURLRequest(URL: url)
            request.addValue(cookieString, forHTTPHeaderField: "Cookie")
            mainWebView.loadRequest(request)
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

extension MainViewController: ImagePickerDelegate{
    func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]){
        print("Wrapper")
        //imagePicker.galleryView.collectionView(images)
    }
    
    func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]){
        print("done")
    }
    
    func cancelButtonDidPress(imagePicker: ImagePickerController){
        print("cancel")
    }
}

