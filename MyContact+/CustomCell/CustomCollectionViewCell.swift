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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func shareButtonPressed(_ sender: Any) {
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

