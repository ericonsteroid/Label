//
//  FeaturedCollectionReusableView.swift
//  Label
//
//  Created by Anthony on 14/01/2018.
//  Copyright © 2018 Anthony Gordon. All rights reserved.
//

import UIKit

class FeaturedCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewProductStatus: UIView!
    @IBOutlet weak var lblProductStatus: UILabel!
    
    // MARK: STORE PRODUCT
    var product:storeItem? {
        didSet {
            
            self.viewProductStatus.isHidden = true
            
            guard let name = product?.title,
                let price = product?.price else {
                    self.lblProductTitle.text = ""
                    self.lblProductPrice.text = ""
                    return
            }
            
            // FEATURED
            if (product?.featured)! {
                self.viewProductStatus.isHidden = false
                self.viewProductStatus.backgroundColor = UIColor.black
                self.lblProductStatus.textColor = UIColor.white
                self.viewProductStatus.layer.borderWidth = 0
                self.lblProductStatus.text = NSLocalizedString("Featured.text", comment: "Featured (Text)")
            } else if (product?.onSale)! {
                self.viewProductStatus.isHidden = false
                self.viewProductStatus.backgroundColor = UIColor.white
                self.viewProductStatus.layer.borderColor = UIColor.black.cgColor
                self.viewProductStatus.layer.borderWidth = 1
                self.lblProductStatus.textColor = UIColor.black
                self.lblProductStatus.text = NSLocalizedString("On Sale.text", comment: "On Sale (Text)")
            }
            
            if price == "" && product!.variation.count > 0 {
                self.lblProductTitle.text = name
                self.lblProductPrice.text = self.product?.price.formatToPrice()

            } else {
                self.lblProductTitle.text = name
                
                if product!.variation.count > 0 && product!.variation[0].price != "" {

                    self.lblProductPrice.text = self.product?.price.formatToPrice()
                } else {
                    if (product?.onSale)! {
                        if product?.regularPrice != product?.price {
                            
                            self.lblProductPrice.attributedText = LabelFontFormatter().sale(regularPrice: (product?.regularPrice)!, price: (product?.price)!)
                        } else {
                            self.lblProductPrice.text = price.formatToPrice()
                        }
                    } else {
                        self.lblProductPrice.text = price.formatToPrice()
                    }
                }
            }
        }
    }
}
