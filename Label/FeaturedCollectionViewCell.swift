//
//  FeaturedCollectionViewCell.swift
//  Label
//
//  Created by Anthony on 13/01/2018.
//  Copyright © 2018 Anthony Gordon. All rights reserved.
//

import UIKit

class FeaturedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var viewContainerLoader: UIView!
    
    var product:storeItem! {
        didSet {
            
            guard let name = product?.title,
                let price = product?.price else {
                    self.lblProductTitle.text = ""
                    self.lblProductPrice.text = ""
                    return
            }

            self.self.lblProductTitle.text = name
            self.self.lblProductPrice.text = price.formatToPrice()
            if price == "" {
                self.self.lblProductPrice.text = "0.00".formatToPrice()
            }
        }
    }
}
