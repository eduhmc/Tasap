//
//  ViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/1/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import PopupDialog
import TweeTextField

class ViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: TweeAttributedTextField!
    
    @IBOutlet weak var passwordTextField: TweeAttributedTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let ud = UserDefaults.standard
        if let userData = ud.value(forKey: "currentUser") as? Data,
            let credentialsDictionary = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(userData) as! [String: Any]{
            let credentials = User.Credentials(dictionary: credentialsDictionary)!
            self.login(with: credentials)
        }else{
           setup()
        }

    }
    
    func setup() {
        
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
          self.popupShow(message:"email/password can't be empty")
          return
        }

        let credencial = User.Credentials(email: email, password: password)
        self.login(with: credencial)

    }
    
    private func login(with credencial: User.Credentials) {
        
        let loader = Loader(forView: self.view)
        loader.showLoading()
        
        AuthenticationManager.shared.login(with: credencial){ [weak self] result in
            
            guard let strongSelf = self else {
                loader.hideLoading()
                return
            }
            
            switch result {
            case .success(let user):
                
                if let documentID = user.document?.documentID {
                    let pushManager = PushNotificationManager(userID: documentID)
                    pushManager.registerForPushNotifications()
                }
                
                loader.hideLoading()
                strongSelf.performSegue(withIdentifier: "homeSegue", sender: user)
            case .failure(let error):
                loader.hideLoading()
                
                strongSelf.popupShow(message: error.message)
            }
            
        }
        
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSegue", sender: self)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
       
        guard let email = self.emailTextField.text else {
          self.popupShow(message:"email can't be empty")
          return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.popupShow(message: error.localizedDescription)
                return
            }
            
            self.popupShow(message: "We'll send you email to reset your password")
        }
        
    }
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Info", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              
        if segue.identifier == "homeSegue" {

            let user = sender as! User
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let navCtrl: UINavigationController = tabCtrl.viewControllers![0] as! UINavigationController
            let destinationVC = navCtrl.viewControllers[0] as! HomeController
            destinationVC.user = user

        }

    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
