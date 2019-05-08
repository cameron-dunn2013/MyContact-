//
//  PersonalViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/19/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//
import Foundation
import UIKit
import Photos

class PersonalViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var model : Model?
    var cardEditing : Bool?
    var redirected : Bool = false
    var contact : PersonalCard = PersonalCard()
    let picker = UIImagePickerController()
    var imageUploaded : Data?
    @IBOutlet weak var cardNameEntry: UITextField!
    @IBOutlet weak var firstNameEntry: UITextField!
    @IBOutlet weak var lastNameEntry: UITextField!
    @IBOutlet weak var phoneNumberEntry: UITextField!
    @IBOutlet weak var emailEntry: UITextField!
    @IBOutlet weak var websiteEntry: UITextField!
    @IBOutlet weak var streetAddressEntry: UITextField!
    @IBOutlet weak var cityEntry: UITextField!
    @IBOutlet weak var stateEntry: UITextField!
    @IBOutlet weak var socialEntry: UITextField!
    @IBOutlet weak var socialStack: UIStackView!
    @IBOutlet weak var facebookButton : UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var snapchatButton: UIButton!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var textFieldStack: UIStackView!
    @IBOutlet weak var contactImage: UIImageView!
    
    @objc func tapGestureTap() {
        self.view.frame.origin.y = 0
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardNameEntry.delegate = self
        firstNameEntry.delegate = self
        lastNameEntry.delegate = self
        phoneNumberEntry.delegate = self
        emailEntry.delegate = self
        websiteEntry.delegate = self
        streetAddressEntry.delegate = self
        cityEntry.delegate = self
        stateEntry.delegate = self
        socialEntry.delegate = self
        picker.delegate = self
        updateViews()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        let tapRecognizer :UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureTap))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        // Do any additional setup after loading the view.
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if(self.view.frame.origin.y == 0){
                UIView.animate(withDuration: 0.2){
                    self.view.frame.origin.y -= keyboardHeight - 100
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        facebookButton.layer.cornerRadius = facebookButton.frame.height / 2
        twitterButton.layer.cornerRadius = twitterButton.frame.height / 2
        instagramButton.layer.cornerRadius = instagramButton.frame.height / 2
        snapchatButton.layer.cornerRadius = snapchatButton.frame.height / 2
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.frame.origin.y = 0
        textField.resignFirstResponder()
        saveSocials()
        return false
    }
    
    @IBAction func changeTapped(){
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({_ in
                let alert = UIAlertController(title: "Continue", message: "If you just granted permisson you'll need to tap the button again to be taken to image selection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert,animated: true)
                return
            })
        }else{
            if PHPhotoLibrary.authorizationStatus() == .authorized{
                picker.allowsEditing = true
                self.present(self.picker, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "You have not granted this app permission to your photo gallery. Please do so in your settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image : UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        contactImage.image = image
        let imageData = image.jpegData(compressionQuality: 1)
        imageUploaded = imageData
        picker.dismiss(animated: true, completion: nil)
    }
    @IBAction func facebook_tapped(sender: UIButton){
        saveSocials()
        if(contact.facebookURL != nil){
            socialEntry.text = contact.facebookURL
        }else{
            socialEntry.text = ""
        }
        model!.currentAccount = .facebook
        socialStack.isHidden = false
        socialEntry.placeholder = "Enter Facebook URL..."
    }
    @IBAction func twitter_tapped(sender: UIButton){
        saveSocials()
        if(contact.twitterHandle != nil){
            socialEntry.text = contact.twitterHandle
        }else{
            socialEntry.text = ""
        }
        model!.currentAccount = .twitter
        socialStack.isHidden = false
        socialEntry.placeholder = "Enter Twitter username..."
    }
    @IBAction func insta_tapped(sender: UIButton){
        saveSocials()
        if(contact.instagramHandle != nil){
            socialEntry.text = contact.instagramHandle
        }else{
            socialEntry.text = ""
        }
        model!.currentAccount = .instagram
        socialStack.isHidden = false
        socialEntry.placeholder = "Enter Instagram username..."
    }
    @IBAction func snap_tapped(sender: UIButton){
        saveSocials()
        if(contact.snapchatHandle != nil){
            socialEntry.text = contact.snapchatHandle
        }else{
            socialEntry.text = ""
        }
        model!.currentAccount = .snapchat
        socialStack.isHidden = false
        socialEntry.placeholder = "Enter Snapchat username..."
    }
    func saveSocials() {
        guard let current = model!.currentAccount else {return}
        switch current{
        case .snapchat:
            contact.snapchatHandle = socialEntry.text
        case .twitter:
            contact.twitterHandle = socialEntry.text
        case .instagram:
            contact.instagramHandle = socialEntry.text
        case .facebook:
            contact.facebookURL = socialEntry.text
        }
        socialStack.isHidden = true
    }
    func updateViews(){
        if(contact.cardName != nil){cardNameEntry.text = contact.cardName}
        if(contact.firstName != nil){firstNameEntry.text = contact.firstName}
        if(contact.lastName != nil){lastNameEntry.text = contact.lastName}
        if(contact.phoneNumber != nil){phoneNumberEntry.text = contact.phoneNumber}
        if(contact.email != nil){emailEntry.text = contact.email}
        if(contact.website != nil){websiteEntry.text = contact.website}
        if(contact.address.streetAddress != nil){streetAddressEntry.text = contact.address.streetAddress}
        if(contact.address.city != nil){cityEntry.text = contact.address.city}
        if(contact.address.state != nil){stateEntry.text = contact.address.state}
        if(contact.birthday != nil){birthdayPicker.date = (contact.birthday)!}
        guard let imageData = contact.image else {return}
        guard let newContactImage = UIImage(data: imageData) else {return}
        contactImage.image = newContactImage
        
    }
    @IBAction func save(_ sender: Any) {
        //set a variable equal to model.saveContact and test to see if it contains a value, if it does then present the
        //UIAlertController
        let contact = Contact()
        contact.personalContact = self.contact
        guard let alert = model?.saveContact(sender: .personal, contact: contact, cardNameEntry: cardNameEntry, streetAddressEntry: streetAddressEntry, cityEntry: cityEntry, imageUploaded: imageUploaded, presentImage: self.contact.image, stateEntry: stateEntry, emailEntry: emailEntry, websiteEntry: websiteEntry, firstNameEntry: firstNameEntry, lastNameEntry: lastNameEntry, phoneNumberEntry: phoneNumberEntry, redirected: redirected) else {
        navigationController?.popToRootViewController(animated: true)
            return
        }
        self.present(alert,animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
