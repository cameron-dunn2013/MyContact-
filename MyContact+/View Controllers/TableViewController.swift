//
//  PersonalViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/14/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit


class TableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, ButtonDelegate{

    
    var model = Model()
    var indexPath : IndexPath?
    @IBOutlet weak var tableView : UITableView!
    
    
    func shareButtonTapped(sender: CustomTableViewCell) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return model.personalCards.count
        case 1:
            return model.businessCards.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        switch indexPath.section{
        case 0:
            cell.label.text = model.personalCards[indexPath.row].cardName
            guard let cellImageData = model.personalCards[indexPath.row].image else {
                cell.personalContact = model.personalCards[indexPath.row]
                cell.headerRow = 0
                cell.delegate = self
                return cell
            }
            cell.contactImage.image = UIImage(data: cellImageData)
            cell.personalContact = model.personalCards[indexPath.row]
            cell.headerRow = 0
            cell.delegate = self
        case 1:
            cell.label.text = model.businessCards[indexPath.row].cardName
            guard let cellImageData = model.businessCards[indexPath.row].image else {
                cell.businessContact = model.businessCards[indexPath.row]
                cell.headerRow = 1
                cell.delegate = self
                return cell
            }
            cell.contactImage.image = UIImage(data: cellImageData)
            cell.businessContact = model.businessCards[indexPath.row]
            cell.headerRow = 1
            cell.delegate = self
        default:
            print("Something went wrong, attempted to insert cell into section \(indexPath.section)")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Personal"
        case 1:
            return "Business"
        default:
            return ""
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: nil)
            if(indexPath.section == 0){
                model.personalCards.remove(at: indexPath.row)
                model.savePersonalCards()
            }else if(indexPath.section == 1){
                model.businessCards.remove(at: indexPath.row)
                model.saveBusinessCards()
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        if(indexPath.section == 0){
            self.performSegue(withIdentifier: "EditPersonalSegue", sender: indexPath)
        }else if(indexPath.section == 1){
            self.performSegue(withIdentifier: "EditBusinessSegue", sender: indexPath)
        }
    }
    @IBAction func editTable(_ sender: Any) {
        tableView.setEditing(true, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewDidLoad() {
        model.loadAllCards()
    }
    
}
