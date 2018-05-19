//
//  BrowseViewController.swift
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
import Spring
import ElasticTransition
import PinterestSegment

class BrowseViewController: ParentLabelVC, LabelBootstrap {
    
    var dispatchGroup:DispatchGroup!
    var prodItem:String! = String()
    var selectedFilter:String! = String()
    var selectedStoreItem:storeItem!
    var isFilteringOpen:Bool = false
    var activityLoader:NVActivityIndicatorView!
    var activityLoaderNV:NVActivityIndicatorView!
    
    var storeItems:[storeItem]! = []
    var activeItems:[storeItem]! = []
    
    var categoryName:String! = ""
    var categoryID:Int! = Int()
    var subCats:[sCategory]! = []
    
    var sortOptions = [NSLocalizedString("rD0-1Q-7Sh.text", comment: "Sort (Text)"),NSLocalizedString("Price: Low to High.text", comment: "Price: Low to High (Text)"),NSLocalizedString("Price: High to Low.text", comment: "Price: High to Low (Text)")]
    var subCategories:[sCategory]! = []
    
    @IBOutlet weak var viewContainerLoader: UIView!
    @IBOutlet weak var lblCategoryInfo: UILabel!
    @IBOutlet weak var viewProductLoader: UIView!
    @IBOutlet weak var viewContainerSearchBtnIcon: UIView!
    @IBOutlet weak var tfSearchView: UITextField!
    @IBOutlet weak var viewContainerSearch: SpringView!
    @IBOutlet weak var lblCartValue: UILabel!
    @IBOutlet weak var viewFilterResults: SpringView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnApplyChanges: UIButton!
    @IBOutlet weak var viewContainerSubCategories: UIView!
    @IBOutlet weak var lblRefineText: UILabel!
    @IBOutlet weak var lblSearchText: UILabel!
    @IBOutlet weak var viewContainerRefine: UIView!
    
    @IBAction func filterResults(_ sender: UIButton) {
        if isFilteringOpen {
            isFilteringOpen = false
            viewFilterResults.animation = "fadeOut"
            viewFilterResults.animate()
        } else {
            viewFilterResults.animation = "fadeInUp"
            viewFilterResults.animate()
            isFilteringOpen = true
        }
    }
    
    @IBAction func openSearchView(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomIn"
        viewContainerSearch.animate()
        tfSearchView.becomeFirstResponder()
    }
    @IBAction func dismissSearch(_ sender: UIButton) {
        viewContainerSearch.animation = "zoomOut"
        viewContainerSearch.animate()
        view.endEditing(true)
    }
    @IBAction func searchProducts(_ sender: UIButton) {
        if let search = tfSearchView.text {
            var sortType = ""
            switch selectedFilter {
            case sortOptions[1]:
                sortType = sortOptions[1]
                break
            case sortOptions[2]:
                sortType = sortOptions[2]
                break
            default:
                break
            }
            self.searchWith(search: search, categoryID: categoryID, sortType: sortType)
        }
    }
    
    @IBOutlet weak var pvFilter: UIPickerView!
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchWith(search:String!,categoryID:Int,sortType:String!) {
        
        if search == "" {
            self.activeItems = self.storeItems
            self.browseCollectionView.reloadData()
            
            self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
            self.viewContainerSearch.animation = "zoomOut"
            self.viewContainerSearch.animate()
            self.view.endEditing(true)
            return
        }
        
        if categoryID == 0 {
            self.oAwCore.getSearchResultsAll(search: search, completion: { (products) in
                if products != nil {
                    self.activeItems = products
                    self.browseCollectionView.reloadData()
                    self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
                    self.viewContainerSearch.animation = "zoomOut"
                    self.viewContainerSearch.animate()
                    self.view.endEditing(true)
                }
            })
        } else {
            
            self.activeItems = []
            for i in 0..<storeItems.count {
                if storeItems[i].title.doesMatches("((?i)" + self.tfSearchView.text! + ")") {
                    self.activeItems.append(storeItems[i])
                }
            }
            self.browseCollectionView.reloadData()
            self.viewContainerSearch.animation = "zoomOut"
            self.viewContainerSearch.animate()
            self.view.endEditing(true)
        }
    }
    
    @IBAction func filterApplyChanges(_ sender: UIButton) {
        switch selectedFilter {
        case sortOptions[1]:
            self.activeItems.sort{(Double($0.price) ?? 0 < Double($1.price) ?? 0)}
            self.browseCollectionView.reloadData()
            break
        case sortOptions[2]:
            self.activeItems.sort{(Double($0.price) ?? 0 > Double($1.price) ?? 0)}
            self.browseCollectionView.reloadData()
            break
        default:
            break
        }
        isFilteringOpen = false
        viewFilterResults.animation = "fadeOut"
        viewFilterResults.animate()
    }
    
    @IBOutlet weak var browseCollectionView: UICollectionView!
    
    @IBAction func viewCart(_ sender: UIButton) {
        performSegue(withIdentifier: "segueCartView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dispatchGroup = DispatchGroup()
        
        self.localizeStrings()
        
        setDelegates()
        
        viewContainerSearchBtnIcon.layer.cornerRadius = 5
        viewContainerSearchBtnIcon.clipsToBounds = true
        
        // CART
        self.lblCartValue.text = String(self.getBasket().count)
        
        viewContainerLoader.isHidden = true
        activityLoaderNV = NVActivityIndicatorView(frame: viewProductLoader.getFrame(), type: .ballClipRotateMultiple, color: UIColor.lightGray, padding: 0)
        self.viewProductLoader.addSubview(activityLoaderNV)
        
        self.startLoader()
        if categoryID == 0 {
            
            self.getAllProducts()
            
        } else {
            // GET ALL CATEGORIES
            self.getCategoryProducts()
            self.getSubCategories()
        }
    }
    
    func groupEnd() {
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.browseCollectionView.reloadData()
            self.stopLoader()
        }
    }
    
    // MARK: LOADER
    
    func startLoader() {
        activityLoaderNV.startAnimating()
        self.viewContainerLoader.layer.opacity = 0
        self.viewContainerLoader.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewContainerLoader.layer.opacity = 1
        }, completion: { (true) in
            self.viewContainerLoader.isHidden = false
        })
    }
    func stopLoader() {
        activityLoaderNV.stopAnimating()
        
        self.viewContainerLoader.layer.opacity = 1
        self.viewContainerLoader.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.viewContainerLoader.layer.opacity = 0
        }, completion: { (true) in
            self.viewContainerLoader.isHidden = true
        })
    }
    
    func getAllProducts() {
        self.oAwCore.getAllProducts { (products) in
            if products != nil {
                self.storeItems = products
                self.activeItems = self.storeItems
                self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
                self.browseCollectionView.reloadData()
                
                self.viewContainerRefine.isHidden = true
                
                var segment:PinterestSegment!
                
                for view in self.viewContainerSubCategories.subviews {
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
                
                let categoryTitles:[String]! = ["Products"]
                
                segment = PinterestSegment(frame: CGRect(x: 0, y: 0, width: self.viewContainerSubCategories.frame.width, height: self.viewContainerSubCategories.frame.height), segmentStyle: style, titles: categoryTitles)
                
                self.viewContainerSubCategories.addSubview(segment)
                self.stopLoader()
            } else {
                self.stopLoader()
            }
        }
    }
    
    func getSubCategories() {
        self.oAwCore.getSubCats(categoryId: String(categoryID)) { (categories) in
            
            if categories != nil {
                self.subCats = categories
                
                var segment:PinterestSegment!
                
                for view in self.viewContainerSubCategories.subviews {
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
                
                var categoryTitles:[String]! = [self.categoryName]
                for category in (self.subCats ?? []) {
                    categoryTitles.append(category.name.html2String)
                }
                
                segment = PinterestSegment(frame: CGRect(x: 0, y: 0, width: self.viewContainerSubCategories.frame.width, height: self.viewContainerSubCategories.frame.height), segmentStyle: style, titles: categoryTitles)
                
                segment.valueChange = { index in
                    
                    self.activeItems = []
                    self.browseCollectionView.reloadData()
                    
                    if index == 0 {
                        self.activeItems = self.storeItems
                        self.browseCollectionView.reloadData()
                        
                    } else {
                        
                        self.activeItems = []
                        
                        // ACTIVE ITEMS (NEW ARRIVALS)
                        for item in self.storeItems {
                            
                            for category in item.categories {
                                guard let categoryId = category.id else {
                                    continue
                                }
                                if self.subCats != nil {
                                    if self.subCats![index - 1].id == categoryId {
                                        self.activeItems.append(item)
                                    }
                                }
                            }
                        }
                    }
                    self.view.layoutIfNeeded()
                    self.browseCollectionView.reloadData()
                    self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
                    
                }
                self.viewContainerSubCategories.addSubview(segment)
            }
            self.browseCollectionView.reloadData()
        }
    }
    
    func getCategoryProducts() {
        
        self.oAwCore.getCategoryForID(id: self.categoryID) { (response) in
            
            if response != nil {
                
                var cleanResponse:[storeItem] = []
                var found:[String] = []
                for product in response! {
                    if !found.contains(product.id) {
                        cleanResponse.append(product)
                    }
                    found.append(product.id)
                }
                self.storeItems = cleanResponse
                self.activeItems = cleanResponse
                
                self.browseCollectionView.reloadData()
                
                self.lblCategoryInfo.text = String(self.activeItems.count) + NSLocalizedString(" results.text", comment: " results.text (Text)")
                
                self.stopLoader()
            } else {
                self.stopLoader()
                self.present(LabelAlerts().openDefaultError(), animated: true, completion: nil)
            }
        }
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
    }
    
    func setDelegates() {
        browseCollectionView.delegate = self
        browseCollectionView.dataSource = self
        pvFilter.delegate = self
        tfSearchView.delegate = self
    }
    
    func localizeStrings() {
        self.btnSearch.setTitle(NSLocalizedString("utq-uI-eRT.normalTitle", comment: "SEARCH (UIButton))"), for: .normal)
        self.lblSearchText.text = NSLocalizedString("Search.text", comment: "Search (text)")
        self.lblRefineText.text = NSLocalizedString("Refine.text", comment: "Refine (Text)")
        self.btnApplyChanges.setTitle(NSLocalizedString("pah-pm-6h5.normalTitle", comment: "Apply Changes (UIButton)"), for: .normal)
    }
}

// MARK: COLLECITONVIEW DELEGATE
extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = browseCollectionView.dequeueReusableCell(withReuseIdentifier: "browseCollectionView", for: indexPath) as! HomeCollectionViewCell
        
        cell.product = activeItems[indexPath.row]
        
        if let mainImgSrc = activeItems[indexPath.row].image[0].src {
            if mainImgSrc != "" {
                cell.ivProdMain.contentMode = .scaleAspectFit
                cell.ivProdMain.sd_setShowActivityIndicatorView(true)
                cell.ivProdMain.sd_setIndicatorStyle(.gray)
                cell.ivProdMain.sd_setImage(with: URL(string: mainImgSrc))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (browseCollectionView.frame.width / 2) - 5, height: (self.view.frame.size.height / 3.5))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedStoreItem = activeItems[indexPath.row]
        
        if activeItems[indexPath.row].variation.count == 0 {
            performSegue(withIdentifier: "segueDetailProductView", sender: self)
        } else if activeItems[indexPath.row].variation.count == 1 && activeItems[indexPath.row].variation[0].id == 0 {
            performSegue(withIdentifier: "segueDetailProductView", sender: self)
        } else {
            performSegue(withIdentifier: "segueDetailFashView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // CUSTOM TRANSITION
        transition.sticky = true
        transition.showShadow = true
        transition.panThreshold = 0.2
        transition.transformType = .translateMid
        transition.edge = .right
        
        if segue.identifier == "segueDetailFashView" {
            let destination = segue.destination as! FashionDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueDetailProductView" {
            let destination = segue.destination as! ProductDetailViewController
            destination.storeItem = selectedStoreItem
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == "segueCartView" {
            let destination = segue.destination as! UINavigationController
            
            // CUSTOM TRANSITION
            transition.sticky = true
            transition.showShadow = true
            transition.panThreshold = 0.2
            transition.transformType = .rotate
            transition.edge = .right
            
            destination.transitioningDelegate = transition
            destination.modalPresentationStyle = .custom
        }
    }
}

// MARK: PICKERVIEW DELEGATE
extension BrowseViewController:UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        
        pickerLabel.textColor = UIColor.darkGray
        pickerLabel.text = sortOptions[row]
        pickerLabel.font = UIFont(name: "AmsiPro-Regular", size: 18)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sortOptions[row] != NSLocalizedString("rD0-1Q-7Sh.text", comment: "Sort (Text)") {
            selectedFilter = sortOptions[row]
        }
    }
}

// MARK: TEXTFIELD DELEGATE

extension BrowseViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfSearchView {
            if let search = tfSearchView.text {
                var sortType = ""
                switch selectedFilter {
                case sortOptions[1]:
                    sortType = sortOptions[1]
                    break
                case sortOptions[2]:
                    sortType = sortOptions[2]
                    break
                default:
                    break
                }
                self.searchWith(search: search, categoryID: categoryID, sortType: sortType)
            }
        }
        
        return true
    }
}
