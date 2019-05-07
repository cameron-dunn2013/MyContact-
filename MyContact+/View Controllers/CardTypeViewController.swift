//
//  CardTypeViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/20/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import UIKit

class CardTypeViewController: UIViewController {
    var model : Model?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "NewPersonalCardSegue"){
            let destination = segue.destination as! PersonalViewController
            destination.model = self.model
            destination.cardEditing = false
        }else if(segue.identifier == "NewBusinessCardSegue"){
            let destination = segue.destination as! BusinessViewController
            destination.model = self.model
            destination.cardEditing = false
        }
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
