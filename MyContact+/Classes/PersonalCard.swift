//
//  Personal.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/14/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit
struct PersonalCard : Codable{
    var uuid : UUID = UUID()
    var cardName : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    var phoneNumber : String?
    var website : String?
    var address : Address = Address()
    var birthday : Date?
    var facebookURL : String?
    var twitterHandle : String?
    var instagramHandle : String?
    var snapchatHandle : String?
    var image : Data?
}
