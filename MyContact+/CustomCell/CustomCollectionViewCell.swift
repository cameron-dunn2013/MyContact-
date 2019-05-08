//
//  CustomTableViewCell.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/19/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardNameLabel : UILabel!
    @IBOutlet weak var contactImage : UIImageView!
    @IBOutlet weak var button : UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func shareButtonPressed(sender: UIButton){
        shareDelegate?.shareButtonTapped(sender: self)
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deleteDelegate?.deleteButtonTapped(sender: self)
    }
    
    var shareDelegate : ShareButtonDelegate?
    var deleteDelegate : DeleteButtonDelegate?
    var indexPath : IndexPath?
    var personalContact : PersonalCard?
    var businessContact : BusinessCard?
    var headerRow : Int = 0
}

