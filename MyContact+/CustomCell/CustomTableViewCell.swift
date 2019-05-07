//
//  CustomTableViewCell.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/19/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var contactImage : UIImageView!
    @IBOutlet weak var button : UIButton!
    @IBAction func buttonPressed(sender: UIButton){
        delegate?.shareButtonTapped(sender: self)
    }
    var delegate : ButtonDelegate?
    var personalContact : PersonalCard?
    var businessContact : BusinessCard?
    var headerRow : Int = 0
}

