//
//  HomeViewController.swift
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
import SDWebImage
import AlamofireImage
import Alamofire
import Spring
import ElasticTransition
import PinterestSegment

class HomeViewController: ParentLabelVC, LabelBootstrap {
    
    // MARK: VARS
    var group:DispatchGroup!
    var isSearching:Bool! = false
    var hasViewed:Bool! = false
    var viewingCatergories = false
    var selectedCategory:Int! = Int()
    var selectedCategoryName:String! = ""
    var isMenuOpen:Bool = false
    var activityLoader:NVActivityIndicatorView!
    var catParent:[sCategory]? = [sCategory]()
    var selectedStoreItem:storeItem!
    var categoryProducts:[storeItem]!
    var storeItems:[storeItem]! = []
    
    var featuredItems:[storeItem]! = []
    var activeItems:[storeItem]! = []
    var segment:PinterestSegment!
    var i:Int! = 0
    
    // MARK: UI OUTLETS
    
    @IBOutlet weak var viewContainerHeaderCategory: UIView!
    @IBOutlet weak var viewContainerSearchBtnIcon: UIView!
    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var viewContainerCategory: UIView!
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var viewProductLoader: UIView!
    @IBOutlet weak var viewContainerMenu: SpringView!
    @IBOutlet weak var viewMenuViewBasket: UIView!
    @IBOutlet weak var viewMenuOrders: UIView!
    @IBOutlet weak var viewMenuAbout: UIView!
    @IBOutlet weak var viewMenuAccount: UIView!
    @IBOutlet weak var ivMenuBar: UIImageView!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var viewContainerSearch: SpringView!
    @IBOutlet weak var ivStoreIcon: UIImageView!
    @IBOutlet weak var viewContainerContent: UIView!
    
    @IBOutlet weak var lblTextMenu: UILabel!
    @IBOutlet weak var lblTextBasket: UILabel!
    @IBOutlet weak var lblTextOrders: UILabel!
    @IBOutlet weak var lblTextAbout: UILabel!
    @IBOutlet weak var lblTextAccount: UILabel!
    
    @IBOutlet weak var lblTextNewArrivals: UILabel!
    @IBOutlet weak var btnShopAll: UIButton!
    @IBOutlet weak var viewContainerFeaturedCollection: UIView!
    
    // MARK: UI ACTIONS
    
    @IBAction func shopAllTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueBrowseView", sender: selectedCategory)
    }
    
    @objc func dismissSearchView() {
        self.btnShopAll.removeTarget(nil, action: nil, for: .allEvents)
        self.btnShopAll.addTarget(self, action: #selector(self.shopAllTapped(_:)), for: .touchUpInside)
        
        self.isSearching = false
        self.viewContainerHeaderCategory.isHidden = false
        self.viewContainerFeaturedCollection.isHidden = false
        
        self.btnShopAll.setTitle(NSLocalizedString("Shop All", comment: "Shop All (Text)"), for: .normal)
        self.lblTextNewArrivals.text = NSLocalizedString("NEW ARRIVALS.text", comment: "NEW ARRIVALS (Text)")
        
        if let layout = self.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        self.view.layoutIfNeeded()
        
        self.activeItems = []
        self.activeItems = self.storeItems
        self.homeCollectionView.reloadData()
        
        createTabs()
        resetHomeProducts(items: self.storeItems)
    }
    
    @IBAction func openLabelLogin(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LoginSignUpSegue", sender: self)
    }
    
    @IBAction func openSearchView(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomIn"
        viewContainerSearch.animate()
        tfSearch.becomeFirstResponder()
    }
    
    @IBAction func dismissSearch(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomOut"
        viewContainerSearch.animate()
        view.endEditing(true)
        
        // GROUP
        group = DispatchGroup()
        group.enter()
        groupEnd()
    }
    
    @IBAction func searchProducts(_ sender: UIButton) {
        if let search = tfSearch.text {
            self.searchWith(search:search)
        }
    }
    
    @IBAction func viewMenu(_ sender: UIButton) {
        if isMenuOpen {
            viewContainerMenu.animation = "fadeOut"
            viewContainerMenu.animate()
            isMenuOpen = false
        } else {
            viewContainerMenu.animation = "zoomIn"
            viewContainerMenu.animate()
            isMenuOpen = true
        }
    }
    
    @IBAction func viewBasket(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    /* MENU ACTIONS */
    @IBAction func viewOrders(_ sender: UIButton) {
        performSegue(withIdentifier: "segueOrdersView", sender: self)
    }
    
    @IBAction func viewAbout(_ sender: UIButton) {
        performSegue(withIdentifier: "segueAboutView", sender: self)
    }
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizeStrings()
        
        // LOADER
        viewProductLoader.isHidden = false
        activityLoader = NVActivityIndicatorView(frame: viewContainerLoader.getFrame(), type: .ballClipRotateMultiple, color: UIColor.lightGray, padding: 0)
        self.viewContainerLoader.addSubview(activityLoader)
        self.startLoader()
        
        // SETUP UI
        setDelegates()
        setStyling()
        
        group = DispatchGroup()

        awCore.shared().accessToken { (result) in
            if result != nil {
                if result! {
                    self.startDidLoad()
                } else {
                    self.stopLoader()
                    self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                }
            } else {
                self.stopLoader()
                self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
                LabelLog().output(log: "Oops, something went wrong, please check your Woosignal account")
            }
        }
    }
    
    func startDidLoad() {
        // RETURNS PRODUCTS
        group.enter()
        getProds()
        
        // RETURNS CATEGORIES
        group.enter()
        getCats()
        
        // GET NONCE
        if labelCore().useLabelLogin {
            self.oAwCore.getUserNonce(completion: { (nonce) in
                if nonce != nil {
                    sDefaults().setUserNonce(nonce: nonce?.token)
                    LabelLog().output(log: "User Nonce Created: " + (nonce?.token ?? ""))
                }
            })
        }
        
        groupEnd()
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
        
        if labelCore().useLabelLogin {
            self.viewMenuAccount.isHidden = false
        }
    }
    
    func groupEnd() {
        group.notify(queue: DispatchQueue.main) {
            self.homeCollectionView.reloadData()
            self.featuredCollectionView.reloadData()
            self.createTabs()
            self.stopLoader()
        }
    }
    
    func searchWith(search:String!) {
        self.oAwCore.getSearchResultsAll(search: search, completion: { response in
            
            if response?.count == 0 {
                LabelAlerts().openAlertWithImg(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("No results found..text", comment: "No results found. (Text)"), image: "lost-balloon", vc: self)
                
            } else {
                self.isSearching = true
                self.viewContainerHeaderCategory.isHidden = true
                self.viewContainerFeaturedCollection.isHidden = true
                self.btnShopAll.setTitle(NSLocalizedString("Back.text", comment: "Back (Text)"), for: .normal)
                self.btnShopAll.removeTarget(nil, action: nil, for: .allEvents)
                self.btnShopAll.addTarget(self, action: #selector(self.dismissSearchView), for: .touchUpInside)
                self.lblTextNewArrivals.text = NSLocalizedString("Search: .text", comment: "Search: (Text)") + search
                
                if let layout = self.homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                }
                
                self.view.layoutIfNeeded()
                
                self.activeItems = []
                self.activeItems = response
                self.homeCollectionView.reloadData()
                
                self.viewContainerSearch.animation = "zoomOut"
                self.viewContainerSearch.animate()
                self.view.endEditing(true)
            }
        })
    }
    
    func resetHomeProducts(items:[storeItem]?) {
        self.activeItems = []
        self.featuredItems = []
        
        for item in items ?? [] {
            if !item.featured {
                self.activeItems.append(item)
            }
        }
        
        for item in items ?? [] {
            if self.featuredItems.count < 5 {
                
                if item.featured || item.onSale {
                    self.featuredItems.append(item)
                }
            }
        }
        
        if labelCore().useFeaturedHeader {
            // Hide Featured Collection
            if self.featuredItems.count == 0 {
                self.viewContainerFeaturedCollection.isHidden = true
                if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                }
                
            } else {
                self.viewContainerFeaturedCollection.isHidden = false
                
                if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                }
            }
        } else {
            self.viewContainerFeaturedCollection.isHidden = true
            if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
            }
        }
    }
    
    func createTabs() {
        
        for view in self.viewContainerCategory.subviews {
            view.removeFromSuperview()
        }
        
        var style = PinterestSegmentStyle()
        
        style.indicatorColor = UIColor(white: 0.95, alpha: 1)
        style.titleMargin = 15
        style.titlePendingHorizontal = 14
        style.titlePendingVertical = 14
        style.titleFont = UIFont.boldSystemFont(ofSize: 14)
        style.normalTitleColor = UIColor.lightGray
        style.selectedTitleColor = UIColor.darkGray
        
        var categoryTitles:[String]! = [NSLocalizedString("Featured.text", comment: "Featured (Text)")]
        for category in (catParent ?? []) {
            categoryTitles.append(category.name)
        }
        
        segment = PinterestSegment(frame: CGRect(x: 0, y: 0, width: viewContainerCategory.frame.width, height: viewContainerCategory.frame.height), segmentStyle: style, titles: categoryTitles)
        
        segment.valueChange = { index in
            
            self.activeItems = []
            self.featuredItems = []
            self.homeCollectionView.reloadData()
            
            if index == 0 {
                
                self.selectedCategory = 0
                
                self.selectedCategoryName = self.catParent![0].name
                self.btnShopAll.setTitle(NSLocalizedString("Shop All", comment: "Shop All (Text)"), for: .normal)
                
                self.resetHomeProducts(items:self.storeItems)
                
            } else {
                
                self.selectedCategoryName = self.catParent![index - 1].name
                self.selectedCategory = self.catParent![index - 1].id
                self.btnShopAll.setTitle(NSLocalizedString("Shop .text", comment: "Shop (Text)") + self.catParent![index - 1].name, for: .normal)
                
                // FEATURED / ON SALE
                for item in self.storeItems {
                    for category in item.categories {
                        guard let categoryId = category.id else {
                            continue
                        }
                        if self.catParent != nil {
                            if self.catParent![index - 1].id == categoryId {
                                if item.featured || item.onSale {
                                    self.featuredItems.append(item)
                                }
                            }
                        }
                    }
                }
                
                if labelCore().useFeaturedHeader {
                    // Hide Featured Collection
                    if self.featuredItems.count == 0 {
                        self.viewContainerFeaturedCollection.isHidden = true
                    } else {
                        self.viewContainerFeaturedCollection.isHidden = false
                    }
                } else {
                    self.viewContainerFeaturedCollection.isHidden = true
                }
                
                // ACTIVE ITEMS (NEW ARRIVALS)
                for item in self.storeItems {
                    for category in item.categories {
                        guard let categoryId = category.id else {
                            continue
                        }
                        if self.catParent != nil {
                            if self.catParent![(index == 0 ? index : index - 1)].id == categoryId {
                                if !item.featured &&
                                    !self.featuredItems.contains(where: {$0.id == item.id}) {
                                    self.activeItems.append(item)
                                }
                            }
                        }
                    }
                }
            }
            self.view.layoutIfNeeded()
            
            self.featuredCollectionView.reloadData()
            self.homeCollectionView.reloadData()
        }
        
        self.viewContainerCategory.addSubview(segment)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.homeCollectionView.reloadData()
    }
    
    // MARK: METHODS
    
    func setStyling() {
        self.ivStoreIcon.image = UIImage(named: labelCore().storeImage)
        
        self.viewContainerCategory.layer.cornerRadius = 2
        self.viewContainerCategory.clipsToBounds = true
        
        self.addMenuBorder(view:viewMenuViewBasket)
        self.addMenuBorder(view:viewMenuOrders)
        self.addMenuBorder(view:viewMenuAbout)
        self.addMenuBorder(view:viewMenuAccount)
        
        viewContainerSearchBtnIcon.layer.cornerRadius = 5
        viewContainerSearchBtnIcon.clipsToBounds = true
    }
    
    func addMenuBorder(view:UIView) {
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    
    // MARK: SET DELEGATES
    
    func setDelegates() {
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        
        featuredCollectionView.delegate = self
        featuredCollectionView.dataSource = self
        
        tfSearch.delegate = self
    }
    
    // MARK: LOADER
    
    func startLoader() {
        activityLoader.startAnimating()
                
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 1
        }, completion: { (true) in
            self.viewProductLoader.isHidden = false
        })
    }
    func stopLoader() {
        activityLoader.stopAnimating()
        
        self.viewProductLoader.layer.opacity = 1
        self.viewProductLoader.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewProductLoader.layer.opacity = 0
        }, completion: { (true) in
            self.viewProductLoader.isHidden = true
        })
    }
    
    /**
     Gets all the products for the Woocommerce store
     */
    func getProds() {
        self.oAwCore.getAllProducts { (response) in
            
            self.group.leave()
            
            if response != nil {
                self.storeItems = response
                self.resetHomeProducts(items:response)
                
            } else {
                LabelAlerts().openMoreInfo(title: NSLocalizedString("Oops!.text", comment: "Oops! (Text)"), desc: NSLocalizedString("PaE-27-TJR.text", comment: "Please try again later. (Text)"), vc: self)
                
                LabelLog().output(log: "Error, no products found. Please ensure that you have completed the Label setup.")
            }
        }
    }
    
    /**
     Gets all the categories for the Woocommerce store
     */
    func getCats() {
        awCore.shared().getAllCategories { (response) in
            self.group.leave()
            
            guard let categories = response else {
                return
            }
            
            // PARENT CATEGORIES
            for cats in categories {
                if cats.parent == 0 {
                    // HTML CONVERT
                    cats.name = try? cats.name.html2String
                    self.catParent?.append(cats)
                }
            }
            
            // IF EMPTY
            if self.catParent?.count == 0 {
                for category in categories {
                    // HTML CONVERT
                    category.name = category.name.html2String
                    self.catParent?.append(category)
                }
            }
            
        }
    }
    
    func localizeStrings() {
        self.lblTextMenu.text = NSLocalizedString("ObI-BW-eWc.text", comment: "Menu (UILabel))")
        self.lblTextBasket.text = NSLocalizedString("uje-t8-hsj.text", comment: "View Basket (UILabel))")
        self.lblTextOrders.text = NSLocalizedString("WHe-jw-vOm.text", comment: "Orders (UILabel))")
        self.lblTextAbout.text = NSLocalizedString("bct-dG-87c.text", comment: "About (UILabel))")
        self.lblTextAccount.text = NSLocalizedString("QxK-HY-t0F.text", comment: "Account (UILabel)")
        self.lblTextNewArrivals.text = NSLocalizedString("NEW ARRIVALS.text", comment: "NEW ARRIVALS (Text)")
    }
}

// MARK: UICOLLECTION VIEW DELEGATE

extension HomeViewController:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == homeCollectionView {
            guard let productsCount = activeItems?.count else {
                return 0
            }
            return productsCount
        } else if collectionView == featuredCollectionView {
            guard let productsCount = featuredItems?.count else {
                return 0
            }
            
            return productsCount - 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = featuredCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FeaturedHeaderCell", for: indexPath) as! FeaturedCollectionReusableView
            
            headerView.product = featuredItems.first
            
            if let mainImgSrc = featuredItems.first?.image[0].src {
                if mainImgSrc != "" {
                    headerView.ivProductImage.contentMode = .scaleAspectFit
                    headerView.ivProductImage.sd_setShowActivityIndicatorView(true)
                    headerView.ivProductImage.sd_setIndicatorStyle(.gray)
                    headerView.ivProductImage.sd_setImage(with: URL(string: mainImgSrc))
                }
            } else {
                headerView.ivProductImage.image = UIImage()
            }
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            headerView.addGestureRecognizer(tapRecognizer)
            
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        self.selectedStoreItem = featuredItems.first
        
        if featuredItems.first?.variation.count == 0 {
            performSegue(withIdentifier: "segueDetailProductView", sender: self)
        } else if featuredItems.first?.variation.count == 1 && featuredItems.first?.variation[0].id == 0 {
            performSegue(withIdentifier: "segueDetailProductView", sender: self)
        } else {
            performSegue(withIdentifier: "segueDetailFashView", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == homeCollectionView {
            
            guard let storeProduct = activeItems?[indexPath.row] else {
                return UICollectionViewCell()
            }
            
            let cell = homeCollectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionView", for: indexPath) as! HomeCollectionViewCell
            
            cell.product = storeProduct
            
            if let mainImgSrc = activeItems[indexPath.row].image[0].src {
                if mainImgSrc != "" {
                    cell.ivProdMain.contentMode = .scaleAspectFit
                    cell.ivProdMain.sd_setShowActivityIndicatorView(true)
                    cell.ivProdMain.sd_setIndicatorStyle(.gray)
                    cell.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
                    
                }
            }
            
            return cell
        } else if collectionView == featuredCollectionView {
            let cell = featuredCollectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedCollectionViewCell
            
            guard let storeProduct = featuredItems?[indexPath.row + 1] else {
                return UICollectionViewCell()
            }
            
            cell.product = storeProduct
            
            if let mainImgSrc = featuredItems[indexPath.row + 1].image[0].src {
                if mainImgSrc != "" {
                    cell.ivProductImage.contentMode = .scaleAspectFit
                    cell.ivProductImage.sd_setShowActivityIndicatorView(true)
                    cell.ivProductImage.sd_setIndicatorStyle(.gray)
                    cell.ivProductImage.sd_setImage(with: URL(string: mainImgSrc))
                }
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewContainerFeaturedCollection.isHidden {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: 0, height: self.featuredCollectionView.frame.size.height / 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == homeCollectionView {
            
            if featuredItems.count == 0 {
                if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                }
                return CGSize(width: (homeCollectionView.frame.width / 2) - 5, height: view.frame.height / 3)
            } else {
                
                if self.viewContainerFeaturedCollection.isHidden || isSearching {
                    if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        layout.scrollDirection = .vertical
                    }
                    
                return CGSize(width: (homeCollectionView.frame.width / 2) - 5, height: viewContainerContent.frame.height / 3)
                    
                } else {
                    if let layout = homeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                        layout.scrollDirection = .horizontal
                    }
                    
                    return CGSize(width: (homeCollectionView.frame.width / 2) - 5, height: homeCollectionView.frame.height)
                }
            }
            
        } else {
            
            return CGSize(width: ((featuredCollectionView.frame.width - 10) / 2), height: (featuredCollectionView.frame.height - 10) / 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == homeCollectionView {
            self.selectedStoreItem = activeItems[indexPath.row]
            
            if activeItems[indexPath.row].variation.count == 0 {
                performSegue(withIdentifier: "segueDetailProductView", sender: self)
            } else if activeItems[indexPath.row].variation.count == 1 && activeItems[indexPath.row].variation[0].id == 0 {
                performSegue(withIdentifier: "segueDetailProductView", sender: self)
            } else {
                performSegue(withIdentifier: "segueDetailFashView", sender: self)
            }
        } else if collectionView == featuredCollectionView {
            self.selectedStoreItem = featuredItems[indexPath.row + 1]
            
            if featuredItems[indexPath.row].variation.count == 0 {
                performSegue(withIdentifier: "segueDetailProductView", sender: self)
            } else if featuredItems[indexPath.row].variation.count == 1 && featuredItems[indexPath.row].variation[0].id == 0 {
                performSegue(withIdentifier: "segueDetailProductView", sender: self)
            } else {
                performSegue(withIdentifier: "segueDetailFashView", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .rotate
        
        if segue.identifier == "segueDetailFashView" {
            
            // CUSTOM TRANSITION
            transition.edge = .top
            
            let destination = segue.destination as! FashionDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            
        } else if segue.identifier == "segueDetailProductView" {
            
            // CUSTOM TRANSITION
            transition.edge = .top
            
            let destination = segue.destination as! ProductDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            
        } else if segue.identifier == "segueBrowseView" {
            
            // CUSTOM TRANSITION
            transition.edge = .bottom
            
            let destination = segue.destination as! BrowseViewController
            destination.categoryName = selectedCategoryName
            destination.categoryID = selectedCategory
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueCartView" {
            
            let destination = segue.destination as! UINavigationController
            
            // CUSTOM TRANSITION
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueOrdersView" {
            let destination = segue.destination as! UINavigationController
            
            // CUSTOM TRANSITION
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueAboutView" {
            
            let destination = segue.destination as! AboutViewController
            
            // CUSTOM TRANSITION
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
            
        }
    }
}

// MARK: UITEXTFIELD DELEGATE

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfSearch {
            
            if let search = tfSearch.text {
                self.searchWith(search:search)
            }
        }
        return true
    }
}
