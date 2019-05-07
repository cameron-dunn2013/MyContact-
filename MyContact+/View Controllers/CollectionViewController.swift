//
//  PersonalViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/14/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit


class CollectionViewController : UIViewController, ButtonDelegate{
    
    var isEditingCollection : Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    

    
    var model = Model()
    var indexPath : IndexPath?
    
    @IBAction func editTapped(_ sender: Any) {
    }
    
    func shareButtonTapped(sender: CustomCollectionViewCell) {
//        if UIDevice.current.userInterfaceIdiom == .pad{
//
//        }
        switch sender.headerRow{
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
                activityController!.popoverPresentationController?.sourceRect = sender.button.frame
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
                activityController!.popoverPresentationController?.sourceRect = sender.button.frame
            }
            self.present(activityController!, animated: true)
        default:
            print("Default case was hit")
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
        collectionView.reloadData()
        if(model.businessCards.count > 0 && model.personalCards.count > 0){
            collectionView.isHidden = false
        }
    }
    override func viewDidLoad() {
        model.loadAllCards()
        if(model.businessCards.count == 0 && model.personalCards.count == 0){
            collectionView.isHidden = true
        }
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
            cell.delegate = self
            
        case 1:
            cell.businessContact = model.businessCards[indexPath.row]
            cell.contactImage.image = UIImage(data: model.businessCards[indexPath.row].image!)
            cell.cardNameLabel.text = model.businessCards[indexPath.row].cardName
            cell.typeLabel.text = "Business"
            cell.delegate = self
        default:
            print("Default was hit. Something went wrong")
            
        }
        return cell
    }
}
