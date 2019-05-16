//
//  PersonalViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/14/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class CollectionViewController : UIViewController,GADBannerViewDelegate, ShareButtonDelegate, DeleteButtonDelegate{
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial : GADInterstitial!
    
    
    
    func deleteButtonTapped(sender: CustomCollectionViewCell) {
        guard let indexPath = sender.indexPath else {return}
        
        switch indexPath.section{
        case 0:
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete '\(model.personalCards[indexPath.row].cardName ?? "[Unknown Card]")'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
                self.stopEditing()
                self.model.personalCards.remove(at: indexPath.row)
                self.collectionView.reloadData()
                let totalCards: Int = self.model.businessCards.count + self.model.personalCards.count
                if totalCards == 0{
                    self.collectionView.isHidden = true
                }
                self.model.savePersonalCards()
            }))
            self.present(alert,animated: true)
        case 1:
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete '\(model.businessCards[indexPath.row].cardName ?? "[Unknown Card]")'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {_ in
                self.stopEditing()
                self.model.businessCards.remove(at: indexPath.row)
                self.collectionView.reloadData()
                let totalCards: Int = self.model.businessCards.count + self.model.personalCards.count
                if totalCards == 0{
                    self.collectionView.isHidden = true
                }
                self.model.saveBusinessCards()
            }))
            self.present(alert,animated: true)
        default:
            print("Default case was hit")
        }
    }
    
    
    var isEditingCollection : Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    

    
    var model = Model()
    var indexPath : IndexPath?
    
    @IBAction func editTapped(_ sender: Any) {
        beginEditing()
    }
    
    
    @objc func stopEditing(){
        isEditingCollection = false
        collectionView.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(beginEditing))
    }
    
    
    @objc func beginEditing(){
        isEditingCollection = true
        collectionView.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(stopEditing))
    }
    
    func shareButtonTapped(sender: CustomCollectionViewCell) {
        switch sender.indexPath?.section{
        case 0:
            guard let personalContact = sender.personalContact else {
                let alert = UIAlertController(title: "Error", message: "Something went wrong, no contact information was found.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let contactVCF = model.createPersonalContact(withContact: personalContact)
            let activityController = model.shareContact(contact: contactVCF)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController!.popoverPresentationController?.sourceView = self.view
                activityController!.popoverPresentationController?.sourceRect = sender.shareButton.frame
            }
            self.present(activityController!, animated: true)
            
        case 1:
            guard let businessContact = sender.businessContact else{
                let alert = UIAlertController(title: "Error", message: "Something went wrong, no contact information was found.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            let contactVCF = model.createBusinessContact(withContact: businessContact)
            let activityController = model.shareContact(contact: contactVCF)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController!.popoverPresentationController?.sourceView = self.view
                activityController!.popoverPresentationController?.sourceRect = sender.shareButton.frame
            }
            self.present(activityController!, animated: true)
        default:
            print("Default case was hit")
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            self.indexPath = indexPath
            self.performSegue(withIdentifier: "EditPersonalSegue", sender: nil)
        case 1:
            self.indexPath = indexPath
            self.performSegue(withIdentifier: "EditBusinessSegue", sender: nil)
        default:
            print("Default case hit")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CardTypeSegue"){
            let destination = segue.destination as! CardTypeViewController
            destination.model = self.model
        }else if(segue.identifier == "EditPersonalSegue"){
            let destination = segue.destination as! PersonalViewController
            destination.model = self.model
            destination.redirected = true
            destination.contact = model.personalCards[indexPath!.row]
            destination.title = model.personalCards[indexPath!.row].cardName
        }else if(segue.identifier == "EditBusinessSegue"){
            let destination = segue.destination as! BusinessViewController
            destination.model = self.model
            destination.redirected = true
            destination.contact = model.businessCards[indexPath!.row]
            destination.title = model.businessCards[indexPath!.row].cardName
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        model.loadAllCards()
        collectionView.reloadData()
        if(model.businessCards.count == 0 && model.personalCards.count == 0){
            collectionView.isHidden = true
        }
        if(model.businessCards.count > 0 || model.personalCards.count > 0){
            collectionView.isHidden = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if premiumUser{
            return
        }
        if showAds{
            if interstitial.isReady{
                interstitial.present(fromRootViewController: self)
                showAds = false
            }
        }
        bannerView.load(GADRequest())
        
    }
    override func viewDidLoad() {
        super.viewDidAppear(true)
        model.loadPremiumUser()
        if(premiumUser == false){
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-6327624401500144/1986032457")
            let request = GADRequest()
            interstitial.load(request)
            bannerView.delegate = self
            bannerView.adUnitID = "ca-app-pub-6327624401500144/7554532830"
            bannerView.rootViewController = self
        }else{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushNewCardSegue))]
        }
        
    }
    @objc func pushNewCardSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CardType")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}





//Collection view functions here
extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var returnInt = 0
        if section == 0{
            returnInt = model.personalCards.count
        }
        if section == 1{
            returnInt = model.businessCards.count
        }
        return returnInt
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCollectionViewCell
        switch indexPath.section{
        case 0:
            cell.contactImage.image = UIImage(data: model.personalCards[indexPath.row].image!)
            cell.personalContact = model.personalCards[indexPath.row]
            cell.cardNameLabel.text = model.personalCards[indexPath.row].cardName
            cell.typeLabel.text = "Personal"
            cell.shareDelegate = self
            cell.deleteDelegate = self
            cell.indexPath = indexPath
            if(isEditingCollection){
                cell.deleteButton.isHidden = false
            }else{
                cell.deleteButton.isHidden = true
            }
            
        case 1:
            cell.businessContact = model.businessCards[indexPath.row]
            cell.contactImage.image = UIImage(data: model.businessCards[indexPath.row].image!)
            cell.cardNameLabel.text = model.businessCards[indexPath.row].cardName
            cell.typeLabel.text = "Business"
            cell.shareDelegate = self
            cell.deleteDelegate = self
            cell.indexPath = indexPath
            if(isEditingCollection){
                cell.deleteButton.isHidden = false
            }else{
                cell.deleteButton.isHidden = true
            }
        default:
            print("Default was hit. Something went wrong")
            
        }
        return cell
    }
}
