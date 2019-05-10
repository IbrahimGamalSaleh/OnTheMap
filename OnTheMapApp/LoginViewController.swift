//
//  LoginViewController.swift
//  OnTheMapApp
//
//  Created by IbrahimGamal on 4/20/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var loginbtn: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    var appDelegate: AppDelegate!
    var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        // Do any additional setup after loading the view, typically from a nib.
        username.delegate=self
        password.delegate=self
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
    
        dismissKeyboard()
       
        LoginToUdacity()
        spinner=showSpinner()
        spinner.hidesWhenStopped=true
    }
    func LoginToUdacity() {
        UdacityAPI.sharedInstance().UdacityLogin(username: username.text!, password: password.text!) { (success, errorMessage, error) in
            if success {
                // i'm calling this method to set the student info in appdelagte shared variables
                
                UdacityAPI.sharedInstance().SingleStudentData(userID: self.appDelegate.userID) { (success, error) in
                    if success {
                     //   UdacityAPI.sharedInstance().isNewStudent(uniqueKey: self.appDelegate.uniqueKey)
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                            let dest = self.storyboard!.instantiateViewController(withIdentifier: "TabBarMapController") as! UITabBarController
                            self.present(dest, animated: true, completion: nil)
                            
                        } }
                    else {
                        
                            UdacityAPI.sharedInstance().alertMaker(self, error: "Network Connection Is Offline!")
                        
                            
                        }
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    UdacityAPI.sharedInstance().alertMaker(self, error: errorMessage!)
                    
                }
            }
        }
        
    }
    
  
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        username.resignFirstResponder()
        password.resignFirstResponder()
        
        return true
    }
   
    @objc func keyboardWillShow(_ notification:Notification) {
        if password.isEditing
        {
            view.frame.origin.y -= (0.5*getKeyboardHeight(notification))
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    
}

