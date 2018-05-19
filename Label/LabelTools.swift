//
//  LabelTools.swift
//  Label
//
//  Created by Anthony Gordon on 18/10/2017.
//  Copyright © 2016 Anthony Gordon. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import Foundation
import NVActivityIndicatorView
import Spring
import PMAlertController

// MARK: UIVIEWCONTROLLER

extension UIViewController {
    
    func getBasket() -> [sBasket] {
        let basket = sDefaults().getUserBasket()
        return basket
    }
}

// MARK: UIVIEW

extension UIView {
    func getFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func getFrameButton() -> CGRect {
        return CGRect(x: self.frame.origin.x / 2, y: self.frame.origin.y / 2, width: self.frame.width, height: self.frame.height)
    }
}

// MARK: STRING

extension String {
    func encodeURL(str:String) -> String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        
        if let escapedString = str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString
        } else {
            return ""
        }
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
    func formatToPrice() -> String {
        let price = Double(self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: labelCore().appLocaleID)
        return formatter.string(from: (price ?? 0) as NSNumber) ?? ""
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    func doesMatches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

}

// MARK: LOADER

class viewLoader:SpringView {
    
    private var activityLoader:NVActivityIndicatorView!
    private var startAnimation:String!
    private var stopAnimation:String!
    
    init(frame:CGRect,type:NVActivityIndicatorType?,color:UIColor? = .black, padding:CGFloat?, startAnimation:String = "fadeInUp",stopAnimation:String = "fadeOut") {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.startAnimation = startAnimation
        self.stopAnimation = stopAnimation
        
        // LOADER
        self.activityLoader = NVActivityIndicatorView(frame: frame, type: type, color: color, padding: padding)
        self.autohide = true
        self.addSubview(activityLoader)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loader() -> viewLoader {
        return self
    }
    
    func startLoader() {
        self.activityLoader.startAnimating()
        self.animation = self.startAnimation
        self.animate()
        
    }
    func stopLoader() {
        self.animation = self.stopAnimation
        self.animate()
        self.activityLoader.stopAnimating()
    }
}

// MARK: ALERTS

struct LabelAlerts {
    
    public func openDefaultError() -> PMAlertController {
        return openWarningController(title: NSLocalizedString("Oops...text", comment: "Oops.. (Text)"), desc: NSLocalizedString("Something went wrong, please try again.", comment: "Something went wrong, please try again. (Text)"))
    }
    
    public func openWithCallback(title:String, desc:String, action: @escaping() -> Void, vc:UIViewController) {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named:"002-man"), style: .alert)
        
        let positiveAction = PMAlertAction(title: NSLocalizedString("Yes.text", comment: "Yes (Text)"), style: .cancel, action: action)
        
        let negativeAction = PMAlertAction(title: NSLocalizedString("No.text", comment: "No (Text)"), style: .default) {
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(positiveAction)
        alertVC.addAction(negativeAction)
        
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    public func openWithAction(title:String, desc:String, action: @escaping() -> Void, vc:UIViewController) {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named:"002-man"), style: .alert)
        
        let positiveAction = PMAlertAction(title: NSLocalizedString("OK.text", comment: "OK (Text)"), style: .cancel) {
            alertVC.dismiss(animated: true, completion: action)
        }
        
        alertVC.addAction(positiveAction)
        
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    public func openWarning(title:String!, desc:String!, vc:UIViewController) {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named: "warning.png"), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: NSLocalizedString("OK.text", comment: "OK (Text)"), style: .cancel, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    public func openWarningController(title:String!, desc:String!) -> PMAlertController {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named: "warning.png"), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: NSLocalizedString("OK.text", comment: "OK (Text)"), style: .cancel, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        return alertVC
    }
    
    public func openMoreInfo(title:String!, desc:String!, vc:UIViewController) {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named: ""), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: NSLocalizedString("AYf-ie-dRHsK.text", comment: "Done (Text)"), style: .cancel, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        
        vc.present(alertVC, animated: true, completion: nil)
    }
    
    public func openAlertWithImg(title:String,desc:String,image:String,vc:UIViewController) {
        let alertVC = PMAlertController(title: title, description: desc, image: UIImage(named: image), style: .alert)
        
        alertVC.addAction(PMAlertAction(title: NSLocalizedString("OK.text", comment: "OK (Text)"), style: .cancel, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
            
        }))
        
        vc.present(alertVC, animated: true, completion: nil)
    }
}

// MARK: LOGGING

struct LabelFontFormatter {
    func sale(regularPrice:String, price:String) -> NSAttributedString {
        let tmpPrice:NSMutableAttributedString! = NSMutableAttributedString()
        
        let fontStylePrice:UIFont! = UIFont(name: "AmsiPro-Semibold", size: 18)
        let fontStyleRegularPrice:UIFont! = UIFont(name: "AmsiPro-Semibold", size: 11)
        
        let storePrice = NSMutableAttributedString(string: price.formatToPrice())
        storePrice.addAttribute(NSAttributedStringKey.font, value:fontStylePrice , range: NSMakeRange(0, storePrice.length))
        
        tmpPrice.append(storePrice)
        
        tmpPrice.append(NSMutableAttributedString(string: "\n"))
        
        let underlinePrice:NSMutableAttributedString! =  NSMutableAttributedString(string: regularPrice.formatToPrice())
        underlinePrice.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, underlinePrice.length))
        underlinePrice.addAttribute(NSAttributedStringKey.font, value: fontStyleRegularPrice, range: NSMakeRange(0, underlinePrice.length))
        underlinePrice.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, underlinePrice.length))
        
        let wasFont:NSMutableAttributedString! = NSMutableAttributedString(string: "Was: ")
        wasFont.addAttribute(NSAttributedStringKey.font, value: fontStyleRegularPrice, range: NSMakeRange(0, wasFont.length))
        wasFont.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, wasFont.length))
        
        tmpPrice.append(wasFont)
        
        tmpPrice.append(underlinePrice)
        
        return tmpPrice
    }
}

struct LabelLog {
    func output(log:String) {
        if labelCore().labelDebug {
            print("LABEL : " + log)
            print("")
        }
    }
}

protocol LabelBootstrap {
    func localizeStrings() // LOCALIZED STORYBOARD STRINGS/TEXTFIELDS
}
