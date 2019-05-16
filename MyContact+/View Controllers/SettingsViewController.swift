//
//  SettingsViewController.swift
//  MyContact+
//
//  Created by Cameron Dunn on 5/7/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
class SettingsViewController: UIViewController {

    
    @IBAction func removeAdsButtonTapped(_ sender: Any) {
        SwiftyStoreKit.purchaseProduct("RemoveAdvertisements", quantity: 1, atomically: true){result in
            switch result{
            case .success(let purchase):
                print("Purchase success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "PremiumUser")
                let alert = UIAlertController(title: "Thank you!", message: "Thank you for your purchase of the premium MyContact+, please force close the app and relaunch to see without ads.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Restart", style: .destructive, handler: {_ in
                    fatalError()
                }))
            case .error(let error):
                switch error.code{
                case .unknown: print("Unkown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
            
        }
    }
    @IBAction func restorePurchaseTapped(_ sender: Any) {
        SwiftyStoreKit.retrieveProductsInfo(["RemoveAdvertisements"]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    // handle result (same as above)
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}


//Extension for SwiftyStoreKit
extension SettingsViewController{
    func retrieveProductInfo(){
        SwiftyStoreKit.retrieveProductsInfo(["RemoveAdvertisements"]){result in
            if let product = result.retrievedProducts.first{
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first{
                print("Invalid product identifier: \(invalidProductId)")
            }else{
                print("Error: \(result.error!)")
            }
        }
    }
}
