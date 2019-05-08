//
//  BusinessCard.swift
//  MyContact+
//
//  Created by Cameron Dunn on 1/19/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import UIKit
class BusinessCard : Codable{
    var uuid : UUID = UUID()
    var cardName : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    var phoneNumber : String?
    var website : String?
    var address : Address = Address()
    var facebookURL : String?
    var twitterHandle : String?
    var instagramHandle : String?
    var snapchatHandle : String?
    var image : Data?
}
class Address: Codable{
    var streetAddress : String?
    var city : String?
    var state : String?
}
