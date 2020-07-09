//
//  RegisterViewController.swift
//  iOSProject
//
//  Created by Roger Arroyo on 4/11/20.
//  Copyright © 2020 Eduardo Huerta. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PopupDialog
import FirebaseStorage
import FirebaseAuth

enum RegisterState {
    case unnowError
    case firstEmpty
    case lastEmpty
    case emailEmpty
    case emailDomainError(domain: String)
    case emailFormatError
    case passwordEmpty
    case universityEmpty
    case passwordMinimun
    case succes(user: User)
}

protocol RegisterDelegate: class {
    func fetchUniversity(university: University)
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var universityLabel: UITextField!
    @IBOutlet weak var tutorSwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private var university: University?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.makeRounded()
    }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        var error = ""
        
        switch validateForm() {
        case .unnowError:
            error = ""
            break
        case .firstEmpty:
            error = "Please complete First name"
            popupShow(message: error)
            break
        case .lastEmpty:
            error = "Please complete Last name"
            popupShow(message: error)
            break
        case .emailEmpty:
            error = "Please complete Email"
            popupShow(message: error)
            break
        case .emailDomainError(let domain):
            error = "Invalid email domain, The allowed domain is example@\(domain)"
            popupShow(message: error)
            break
        case .emailFormatError:
            error = "Invalid email format "
            popupShow(message: error)
            break
        case .passwordEmpty:
            error = "Please complete Password"
            popupShow(message: error)
            break
        case .passwordMinimun:
            error = "The password must be 6 characters long or more"
            popupShow(message: error)
        case .universityEmpty:
            error = "Please complete University"
            popupShow(message: error)
            break
        case .succes(let user):
            registerUser(user: user)
            break
        
        }
        
    }
    
    
    func validateForm() -> RegisterState {
        
        var firstName = "", lastName = "", emailUser = "", passwordUser = "", universityCode = ""
        
        if let first = firstNameLabel.text, first != "" {
            firstName = first
        }else{
            return .firstEmpty
        }
        
        if let last = lastNameLabel.text, last != "" {
            lastName = last
        }else{
            return .lastEmpty
        }
        
        if let university = universityLabel.text, university != "" {
            universityCode = (self.university?.document!.documentID)!
        } else {
            return .universityEmpty
        }
        
        if let email = emailLabel.text, email != "" {
            emailUser = email
        }else {
            return .emailEmpty
        }
        
        if !emailUser.contains("@") {
            return .emailFormatError
        }
        
        if let university = self.university, university.domain != "" {
            if !emailUser.contains("@\(university.domain)") {
                return .emailDomainError(domain: university.domain)
            }
        }else{
            return .universityEmpty
        }
        
        if let password = passwordLabel.text, password != "" {
            passwordUser = password
        }else{
            return .passwordEmpty
        }
        
        if let password = passwordLabel.text, password.count > 5 {
            passwordUser = password
        }else{
            return .passwordMinimun
        }
 
        if firstName != "" && lastName != "" && emailUser != ""  && passwordUser != ""{
            
            var user = User(first: firstName, last: lastName, description: "To start to be a tutor, please edit your price, description and courses.", email: emailUser, password: passwordUser,imagePath: "", price:"0.0", ratingNumber: 1, ratingAverage: 5, courses: ["00000000000000000000"], university: universityCode, fcmToken: ".", country: ".")
            user.image = userImageView
            return .succes(user: user)
        }
        
        return .unnowError
        
    }
    
    func registerUser(user: User){
        
        if self.tutorSwitch.isOn {
            self.performSegue(withIdentifier: "registerDetailSegue", sender: user)
        }else{
            
            let loader = Loader(forView: self.view)
            loader.showLoading()
            
            Auth.auth().createUser(withEmail: user.email, password: user.password) { authResult, error in
                guard let userAuth = authResult?.user, error == nil else {
                    self.popupShow(message: error?.localizedDescription ?? "Unnowed error")
                    loader.hideLoading()
                    return
                }
                print("\(userAuth.email!) created")
                
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

                if let uploadData = self.userImageView.image?.jpegData(compressionQuality: 0.1) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                        if let error = error {
                            self.popupShow(message: error.localizedDescription )
                            loader.hideLoading()
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            if let error = error {
                                self.popupShow(message: error.localizedDescription )
                                loader.hideLoading()
                                return
                            }
                            guard let photoUrl = url else { return }
                            
                            var updateUser:User = User(dictionary: user.dictionary)!
                            updateUser.password = "."
                            updateUser.imagePath = photoUrl.absoluteString
                           
                            var ref: DocumentReference? = nil
                            Firestore.firestore().collection("users").document(userAuth.uid).setData(updateUser.dictionary)  { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                    loader.hideLoading()
                                    self.popupShow(message: "Error adding user")
                                } else {
                                    ref = Firestore.firestore().collection("users").document(userAuth.uid)
                                    print("Document added with ID: \(ref!.documentID)")
                                    updateUser.document = ref
                                    
                                    userAuth.sendEmailVerification (completion: { (error) in
                                        // Notify the user that the mail has sent or couldn't because of an error.
                                        if let err = err {
                                            loader.hideLoading()
                                            print("Error adding document: \(err)")
                                        }else{
                                            loader.hideLoading()
                                            let popup =  PopupDialog(title: "Account Created", message: "Verify your email for login in Tasap app")
                                            
                                            let buttonOne = CancelButton(title: "OK") {
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                            
                                            popup.addButton(buttonOne)
                                            self.present(popup, animated: true, completion: nil)
                                            
                                        }
                                    })
                                }
                            }
                            
                        })
                    })
                }
                
            }
        }
    }
   
    @IBAction func uploadImageButtonTapped(_ sender: UIButton) {
        
        ImagePickerManager().pickImage(self){ image in
            self.userImageView.image = image
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func universityButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "universitySegue", sender: nil)
    }
    
    
    func popupShow(message: String){
        
        let popup =  PopupDialog(title: "Info", message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    func popupShow(title:String, message: String){
        
        let popup =  PopupDialog(title: title, message: message)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You ok popup tapped")
        }
        
        popup.addButton(buttonOne)
        self.present(popup, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "registerDetailSegue" {

            let user = sender as! User
            let destinationVC = segue.destination as! RegisterDetailViewController
            destinationVC.user = user
            
        }else if segue.identifier == "universitySegue" {

            let destinationVC = segue.destination as! UniversityViewController
            destinationVC.delegate = self

        }
            
    }

}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == emailLabel{
            topConstraint.constant = -20
        }
        
        if textField == passwordLabel{
            topConstraint.constant = -50
        }
        
        self.view.layoutIfNeeded()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordLabel || textField == emailLabel{
            topConstraint.constant = 35
            self.view.layoutIfNeeded()
        }
    }
    
}

extension RegisterViewController: RegisterDelegate {
    func fetchUniversity(university: University) {
        self.university = university
        self.universityLabel.text = university.name
    }
}

