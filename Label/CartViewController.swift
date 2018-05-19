//
//  CartViewController.swift
//  Label
//
//  Created by Anthony Gordon on 18/11/2016.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit
import NVActivityIndicatorView
import SwiftyJSON
import ElasticTransition
import Spring
import Toast_Swift

class CartViewController: ParentLabelVC, LabelBootstrap {

    var basket:[sBasket]!
    
    // MARK: IB OUTLETS
    
    @IBOutlet weak var btnApplyCoupon: UIButton!
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var CartCollectionView: UICollectionView!
    @IBOutlet weak var lblSubTotal: UILabel!
    @IBOutlet weak var barBtnClearAll: UIBarButtonItem!
    @IBOutlet weak var viewContainerCoupons: SpringView!
    @IBOutlet weak var tfCoupon: UITextField!
    @IBOutlet weak var lblApplyCouponText: UILabel!
    
    
    @IBAction func applyCouponTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func clearAllCart(_ sender: UIBarButtonItem) {
        oAwCore.clearBasket()
        self.basket = getBasket()
        updateTotal()
        self.CartCollectionView.reloadData()
        self.view.makeToast(NSLocalizedString("Basket cleared.text", comment: "Basket cleared (Text)"), duration: 1.5, position: .center)
    }
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showCouponTapped(_ sender: UIButton) {
        self.viewContainerCoupons.animation = "fadeIn"
        self.viewContainerCoupons.animate()
        self.tfCoupon.becomeFirstResponder()
    }
    
    @IBAction func dismissApplyCoupon(_ sender: UIButton) {
        self.viewContainerCoupons.animation = "fadeOut"
        self.viewContainerCoupons.animate()
        self.view.endEditing(true)
    }
    
    
    @IBAction func checkoutView(_ sender: UIButton) {
        if self.basket.count != 0 {
            if labelCore().useLabelLogin {
                
                if sDefaults().isLoggedIn() {
                    self.performSegue(withIdentifier: "seguePaymentView", sender: self)
                } else {
                    self.performSegue(withIdentifier: "SignupLoginSegue", sender: self)
                }
                
            } else {
                self.performSegue(withIdentifier: "seguePaymentView", sender: self)
            }
        } else {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Your cart is empty.text", comment: "Your cart is empty (Text)"), vc: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        setDelegate()
        
        // CART
        self.basket = getBasket()
        
        updateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.basket.count == 0 {
            LabelAlerts().openAlertWithImg(title: NSLocalizedString("Ohh .text", comment: "Ooh (Text)"), desc: NSLocalizedString("Your basket is empty.text", comment: "Your basket is empty (Text)"), image: "commerce-2", vc: self)
        }
    }
    
    func localizeStrings() {
       
        self.title = NSLocalizedString("MeH-Ns-eFY.title", comment: "Cart (Title)")
        self.barBtnClearAll.title = NSLocalizedString("nXn-ef-wGK.title", comment: "Clear all (UIBarButtonItem)")
        self.btnCheckout.setTitle(NSLocalizedString("FjQ-tR-dCw.normalTitle", comment: "Checkout (UIButton)"), for: .normal)
        self.lblSubTotal.text = NSLocalizedString("Lhg-dM-14X.text", comment: "Subtotal (UILabel))")
    }
    
    func setDelegate() {
        self.CartCollectionView.delegate = self
        self.CartCollectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .rotate
        transition.edge = .right
        
        if segue.identifier == "seguePaymentView" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.viewControllers[0] as! OrderConfirmationSetViewController
            destination.basket = basket
            
            nav.transitioningDelegate = transition
            nav.modalPresentationStyle = .custom
        } else if segue.identifier == "SignupLoginSegue" {
            let destination = segue.destination as! LoginSignUpViewController
            destination.isBasketView = true
        }
    }

}

// MARK: UICOLLECTIONVIEW DELEGATE

extension CartViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return basket.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CartCollectionView.dequeueReusableCell(withReuseIdentifier: "CartCollectionCell", for: indexPath) as! CartCollectionViewCell
        
        let basketItem = basket[indexPath.row]
        
        cell.item = basketItem
        
        // SET QUANTITY
        
        cell.stepperQuantity.minimumValue = 1
        
        if basket[indexPath.row].storeItem.manageStock == true {
            cell.stepperQuantity.maximumValue = Double(basket[indexPath.row].storeItem.qty) ?? 0
        }
        
        cell.stepperQuantity.tag = indexPath.row
        cell.stepperQuantity.addTarget(self, action: #selector(updateCartQuantity(sender:)), for: .touchUpInside)
        
        cell.lblOrderSubTotal.text = NSLocalizedString("Total: .text", comment: "Total:  (Text)") + self.oAwCore.woItemSubtotal(basketItem: basket[indexPath.row]).formatToPrice()
        
        // DOWNLOAD IMG
        let productImages = self.oAwCore.sortImagePostions(images: self.basket[indexPath.row].storeItem.image)
        if let mainImgSrc = productImages[0].src {
            if mainImgSrc != "" {
                cell.ivProdMain.contentMode = .scaleAspectFit
                cell.ivProdMain.sd_setShowActivityIndicatorView(true)
                cell.sd_setIndicatorStyle(.gray)
                cell.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
            }
        }
        
        cell.btnRemoveProd.tag = indexPath.row
        cell.btnRemoveProd.addTarget(self, action: #selector(removeCart(sender:)), for: .touchUpInside)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 30, height: 230)
    }
    
    @objc func updateCartQuantity(sender:UIStepper) {
        let cellIndx = sender.tag
        
        if Int(sender.value) != 0 {
        
        // UPDATE CART VALUE
        basket[cellIndx].qty = Int(sender.value)
        self.CartCollectionView.reloadData()
        
        let data = try? JSONEncoder().encode(basket)
        sDefaults().pref.set(data, forKey: sDefaults().userBasket)
        
            updateTotal()
        } else if Int(sender.value) == Int(basket[cellIndx].storeItem.qty) {
            LabelAlerts().openWarning(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("You have reached this item's maximum quantity..text", comment: "You have reached this item's maximum quantity. (Text)"), vc: self)
        }
    }
    
    @objc func removeCart(sender:UIButton) {
        sDefaults().removeFromBasket(index: sender.tag)
        self.basket = getBasket()
        self.CartCollectionView.reloadData()
        
        let data = try? JSONEncoder().encode(basket)
        sDefaults().pref.set(data, forKey: sDefaults().userBasket)
        
        updateTotal()
    }
    
    func updateTotal() {
        self.lblSubtotal.text = oAwCore.woSubtotal(sBasket: self.basket)
        self.lblTotalPrice.text = NSLocalizedString("Total: .text", comment: "Total: (Text)") + oAwCore.woBasketTotal(sBasket: self.basket)
    }
}

extension CartViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCoupon {
            // CHECK FOR COUPON
        }
        return true
    }
    
}
