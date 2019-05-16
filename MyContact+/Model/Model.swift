//
//  Model.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/19/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit
import Contacts

enum SenderCases{
    case personal
    case business
}

var showAds: Bool = false
var premiumUser : Bool = false
extension CNContactVCardSerialization {
    internal class func vcardDataAppendingPhoto(vcard: Data, photoAsBase64String photo: String) -> Data? {
        let vcardAsString = String(data: vcard, encoding: .utf8)
        let vcardPhoto = "PHOTO;TYPE=JPEG;ENCODING=BASE64:".appending(photo)
        let vcardPhotoThenEnd = vcardPhoto.appending("\nEND:VCARD")
        if let vcardPhotoAppended = vcardAsString?.replacingOccurrences(of: "END:VCARD", with: vcardPhotoThenEnd) {
            return vcardPhotoAppended.data(using: .utf8)
        }
        return nil
        
    }
    class func data(jpegPhotoContacts: [CNContact]) throws -> Data {
        var overallData = Data()
        for contact in jpegPhotoContacts {
            let data = try CNContactVCardSerialization.data(with: [contact])
            if contact.imageDataAvailable {
                if let base64imageString = contact.imageData?.base64EncodedString(),
                    let updatedData = vcardDataAppendingPhoto(vcard: data, photoAsBase64String: base64imageString) {
                    overallData.append(updatedData)
                }
            } else {
                overallData.append(data)
            }
        }
        return overallData
    }
}
    
    
class Model{
    var personalCards : [PersonalCard] = []
    var businessCards : [BusinessCard] = []
    var redirected : Bool = false
    enum accounts{
        case facebook
        case instagram
        case snapchat
        case twitter
    }
    func test(completion: @escaping (Void?, Error?) -> Void){
        completion(nil, nil)
    }
    
    
    var currentAccount : accounts?
    func calculateDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let returnDate = dateFormatter.string(from: date)
        return returnDate
    }
    
    func loadPremiumUser(){
        premiumUser = UserDefaults.standard.bool(forKey: "PremiumUser")
        
    }
    
    
    func loadAllCards(){
        loadSavedBusinessCards()
        loadSavedPersonalCards()
    }
    /*
     extension CNContactVCardSerialization {
     internal class func vcardDataAppendingPhoto(vcard: Data, photoAsBase64String photo: String) -> Data? {
     let vcardAsString = String(data: vcard, encoding: .utf8)
     let vcardPhoto = "PHOTO;TYPE=JPEG;ENCODING=BASE64:".appending(photo)
     let vcardPhotoThenEnd = vcardPhoto.appending("\nEND:VCARD")
     if let vcardPhotoAppended = vcardAsString?.replacingOccurrences(of: "END:VCARD", with: vcardPhotoThenEnd) {
     return vcardPhotoAppended.data(using: .utf8)
     }
     return nil
     
     }
     class func data(jpegPhotoContacts: [CNContact]) throws -> Data {
     var overallData = Data()
     for contact in jpegPhotoContacts {
     let data = try CNContactVCardSerialization.data(with: [contact])
     if contact.imageDataAvailable {
     if let base64imageString = contact.imageData?.base64EncodedString(),
     let updatedData = vcardDataAppendingPhoto(vcard: data, photoAsBase64String: base64imageString) {
     overallData.append(updatedData)
     }
     } else {
     overallData.append(data)
     }
     }
     return overallData
     }
     }
     */
    
    
    //The next two functions create and send the contact info
    func shareContact(contact: CNContact) -> UIActivityViewController?{
        let contactArray : [CNContact] = [contact]
        
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return nil
        }
        let filename = NSUUID().uuidString
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        var activityVC : UIActivityViewController?
        do{
            let data = try CNContactVCardSerialization.data(jpegPhotoContacts: contactArray)
            try data.write(to: fileURL, options: [.atomicWrite])
            activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        }catch{
            print("An error was caught \(error)")
        }
        return activityVC
    }
    
    
    func saveContact(sender: SenderCases, contact: Contact, cardNameEntry : UITextField, streetAddressEntry : UITextField, cityEntry: UITextField, imageUploaded: Data?, presentImage : Data?, stateEntry : UITextField, emailEntry : UITextField, websiteEntry : UITextField, firstNameEntry : UITextField, lastNameEntry : UITextField, phoneNumberEntry : UITextField, redirected : Bool) -> UIAlertController?{
        self.redirected = redirected
        switch sender{
        case .personal:
        if(cardNameEntry.text != ""){
            contact.personalContact!.cardName = cardNameEntry.text
        }else{
            let alert = UIAlertController(title: "Error", message: "Card name field cannot be blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            return alert
        }
        if(imageUploaded != nil){
            contact.personalContact!.image = imageUploaded
        }else if(presentImage != nil){
            contact.personalContact!.image = presentImage
        }else{
            contact.personalContact!.image = UIImage(named: "Person.png")?.jpegData(compressionQuality: 1)
        }
        if streetAddressEntry.text != ""{
            contact.personalContact!.address.streetAddress = streetAddressEntry.text!
        }
        if cityEntry.text != ""{
            contact.personalContact!.address.city = cityEntry.text!
        }
        if stateEntry.text != ""{
            contact.personalContact!.address.state = stateEntry.text!
        }
        if emailEntry.text != ""{
            contact.personalContact!.email = emailEntry.text
        }
        if websiteEntry.text != ""{
            contact.personalContact!.website = websiteEntry.text
        }
        if firstNameEntry.text != ""{
            contact.personalContact!.firstName = firstNameEntry.text
        }else{
            let alert = UIAlertController(title: "Error", message: "You cannot leave the first name field blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            return alert
        }
        if lastNameEntry.text != ""{
            contact.personalContact!.lastName = lastNameEntry.text
        }else{
            let alert = UIAlertController(title: "Error", message: "You cannot leave the last name field blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            return alert
        }
        if phoneNumberEntry.text != ""{
            contact.personalContact!.phoneNumber = phoneNumberEntry.text
        }
        if redirected{
            var counter = 0
            for index in personalCards{
                if(index.uuid == contact.personalContact!.uuid){
                    personalCards[counter] = contact.personalContact!
                }
                counter += 1
                self.redirected = false
            }
            
        }else{
            personalCards.append(contact.personalContact!)
        }
        savePersonalCards()
        case .business:
            if(cardNameEntry.text != ""){
                contact.businessContact!.cardName = cardNameEntry.text
            }else{
                let alert = UIAlertController(title: "Error", message: "Card name field cannot be blank.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }
            if(imageUploaded != nil){
                contact.businessContact!.image = imageUploaded
            }else if(presentImage != nil){
                contact.businessContact!.image = presentImage
            }else{
                contact.businessContact!.image = UIImage(named: "Person.png")?.jpegData(compressionQuality: 1)
            }
            if streetAddressEntry.text != ""{
                contact.businessContact!.address.streetAddress = streetAddressEntry.text!
            }
            if cityEntry.text != ""{
                contact.businessContact!.address.city = cityEntry.text!
            }
            if stateEntry.text != ""{
                contact.businessContact!.address.state = stateEntry.text!
            }
            if emailEntry.text != ""{
                contact.businessContact!.email = emailEntry.text
            }
            if websiteEntry.text != ""{
                contact.businessContact!.website = websiteEntry.text
            }
            if firstNameEntry.text != ""{
                contact.businessContact!.firstName = firstNameEntry.text
            }else{
                let alert = UIAlertController(title: "Error", message: "You cannot leave the first name field blank.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }
            if lastNameEntry.text != ""{
                contact.businessContact!.lastName = lastNameEntry.text
            }else{
                let alert = UIAlertController(title: "Error", message: "You cannot leave the last name field blank.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                return alert
            }
            if phoneNumberEntry.text != ""{
                contact.businessContact!.phoneNumber = phoneNumberEntry.text
            }
            if redirected{
                var counter = 0
                for index in businessCards{
                    if(index.uuid == contact.businessContact!.uuid){
                        businessCards[counter] = contact.businessContact!
                    }
                    counter += 1
                    self.redirected = false
                }
                
            }else{
                businessCards.append(contact.businessContact!)
            }
            saveBusinessCards()
        }
        return nil
    }
    
    func createPersonalContact(withContact specifiedContact: PersonalCard) -> CNContact{
        
        let contact = CNMutableContact()
        contact.imageData = specifiedContact.image
        contact.givenName = specifiedContact.firstName!
        contact.familyName = specifiedContact.lastName!
        if(specifiedContact.birthday != nil){
            contact.birthday = Calendar.current.dateComponents([.year,.month,.day], from: specifiedContact.birthday!)
        }
        if(specifiedContact.email != nil){
            contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: specifiedContact.email! as NSString)]
        }
        if(specifiedContact.phoneNumber != nil){
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: specifiedContact.phoneNumber!))]
        }
        if(specifiedContact.website != nil){
            contact.urlAddresses = [CNLabeledValue(label: CNLabelURLAddressHomePage, value: specifiedContact.website! as NSString)]
        }
        let address = CNMutablePostalAddress()
        if(specifiedContact.address.city != nil){
            address.city = specifiedContact.address.city!
        }
        if(specifiedContact.address.state != nil){
            address.state = specifiedContact.address.state!
        }
        if(specifiedContact.address.streetAddress != nil){
            address.street = specifiedContact.address.streetAddress!
        }
        if(specifiedContact.address.city != nil){
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: address)]
        }
        
        var socialProfiles : [CNLabeledValue<CNSocialProfile>] = []
        if let newSnap = specifiedContact.snapchatHandle{
            let snapchatProfile = CNLabeledValue(label: "Snapchat", value: CNSocialProfile(urlString: "https://snapchat.com/add/\(newSnap)", username: newSnap, userIdentifier: newSnap, service: "Snapchat"))
            socialProfiles.append(snapchatProfile)
        }
        if let newFacebook = specifiedContact.facebookURL{
            let facebookProfile = CNLabeledValue(label: CNSocialProfileServiceFacebook, value: CNSocialProfile(urlString: "https://facebook.com/\(newFacebook)", username: newFacebook, userIdentifier: newFacebook, service: CNSocialProfileServiceFacebook))
            socialProfiles.append(facebookProfile)
        }
        if let newTwitter = specifiedContact.twitterHandle{
            let twitterProfile = CNLabeledValue(label: CNSocialProfileServiceTwitter, value: CNSocialProfile(urlString: "https://twitter.com/\(newTwitter)", username: newTwitter, userIdentifier: newTwitter, service: CNSocialProfileServiceTwitter))
            socialProfiles.append(twitterProfile)
        }
        if let newInsta = specifiedContact.instagramHandle{
            let instaProfile = CNLabeledValue(label: "Instagram", value: CNSocialProfile(urlString: "https://instagram.com/\(newInsta)", username: newInsta, userIdentifier: newInsta, service: "Instagram"))
            socialProfiles.append(instaProfile)
        }
        contact.socialProfiles = socialProfiles
        return contact
    }
    
    
    func createBusinessContact(withContact specifiedContact: BusinessCard) -> CNContact{
        
        let contact = CNMutableContact()
        contact.imageData = specifiedContact.image
        contact.givenName = specifiedContact.firstName!
        contact.familyName = specifiedContact.lastName!
        if(specifiedContact.email != nil){
            contact.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: specifiedContact.email! as NSString)]
        }
        if(specifiedContact.phoneNumber != nil){
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: specifiedContact.phoneNumber!))]
        }
        if(specifiedContact.website != nil){
            contact.urlAddresses = [CNLabeledValue(label: CNLabelURLAddressHomePage, value: specifiedContact.website! as NSString)]
        }
        let address = CNMutablePostalAddress()
        if(specifiedContact.address.city != nil){
            address.city = specifiedContact.address.city!
        }
        if(specifiedContact.address.state != nil){
            address.state = specifiedContact.address.state!
        }
        if(specifiedContact.address.streetAddress != nil){
            address.street = specifiedContact.address.streetAddress!
        }
        if(specifiedContact.address.city != nil){
            contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: address)]
        }
        
        var socialProfiles : [CNLabeledValue<CNSocialProfile>] = []
        if let newSnap = specifiedContact.snapchatHandle{
            let snapchatProfile = CNLabeledValue(label: "Snapchat", value: CNSocialProfile(urlString: "https://snapchat.com/add/\(newSnap)", username: newSnap, userIdentifier: newSnap, service: "Snapchat"))
            socialProfiles.append(snapchatProfile)
        }
        if let newFacebook = specifiedContact.facebookURL{
            let facebookProfile = CNLabeledValue(label: CNSocialProfileServiceFacebook, value: CNSocialProfile(urlString: "https://facebook.com/\(newFacebook)", username: newFacebook, userIdentifier: newFacebook, service: CNSocialProfileServiceFacebook))
            socialProfiles.append(facebookProfile)
        }
        if let newTwitter = specifiedContact.twitterHandle{
            let twitterProfile = CNLabeledValue(label: CNSocialProfileServiceTwitter, value: CNSocialProfile(urlString: "https://twitter.com/\(newTwitter)", username: newTwitter, userIdentifier: newTwitter, service: CNSocialProfileServiceTwitter))
            socialProfiles.append(twitterProfile)
        }
        if let newInsta = specifiedContact.instagramHandle{
            let instaProfile = CNLabeledValue(label: "Instagram", value: CNSocialProfile(urlString: "https://instagram.com/\(newInsta)", username: newInsta, userIdentifier: newInsta, service: "Instagram"))
            socialProfiles.append(instaProfile)
        }
        contact.socialProfiles = socialProfiles
        return contact
    }
    
    //The next 6 functions will save/load the cards.
    func loadSavedPersonalCards(){
        guard let url = personalFileURL else {return}
        do{
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            personalCards = try decoder.decode([PersonalCard].self, from: data)
        }catch{
            print(error)
        }
    }
    func savePersonalCards(){
        guard let url = personalFileURL else {return}
        do{
            let data = try PropertyListEncoder().encode(personalCards)
            try data.write(to: url)
        }catch{
            print(error)
        }
        
    }
    func loadSavedBusinessCards(){
        guard let url = businessFileURL else {return}
        do{
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            businessCards = try decoder.decode([BusinessCard].self, from: data)
        }catch{
            print(error)
        }
    }
    func saveBusinessCards(){
        guard let url = businessFileURL else {return}
        do{
            let data = try PropertyListEncoder().encode(businessCards)
            try data.write(to: url)
        }catch{
            print(error)
        }
        
    }
    private var personalFileURL : URL?{
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let finalLocation = documentsDirectory.appendingPathComponent("personal.plist")
        return finalLocation
    }
    private var businessFileURL : URL?{
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let finalLocation = documentsDirectory.appendingPathComponent("business.plist")
        return finalLocation
    }
    private var medicalFileURL : URL?{
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let finalLocation = documentsDirectory.appendingPathComponent("medical.medi")
        return finalLocation
    }
}
