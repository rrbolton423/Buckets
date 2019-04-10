//
//  Extensions.swift
//  Buckets: Basketball Data
//
//  Created by Romell Bolton on 3/8/19.
//  Copyright © 2019 Romell Bolton. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIImageView {
    func loadImageUsingCache(withURL urlString : String) {
        guard let url = URL(string: urlString) else { return }
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    return
                }
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self.image = image
                    }
                }
            }).resume()
        }
    }
    func displayPlaceholderImage() {
        DispatchQueue.main.async { self.image = UIImage(named: "player_placeholder") }
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
}

extension Float {
    func string(fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension UIColor {
    class var separatorColor: UIColor {
        return UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIView {
    @IBInspectable var ignoresInvertColors: Bool {
        get {
            if #available(iOS 11.0, *) {
                return accessibilityIgnoresInvertColors
            }
            return false
        }
        set {
            if #available(iOS 11.0, *) {
                accessibilityIgnoresInvertColors = newValue
            }
        }
    }
}

extension String {
    
    func openInBrowser() {
        if let url = URL(string: self) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension UITableViewController {
    public func unselectSelectedRow() {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    public func removeNavigationBarSeparator() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
}

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("com.romellbolton.Buckets--Basketball-Data.notifications.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("com.romellbolton.Buckets--Basketball-Data.notifications.darkModeDisabled")
}

extension UITableViewCell {
    public func setSelectedColor(color: UIColor) {
        let bgColorView = UIView()
        bgColorView.backgroundColor = color
        self.selectedBackgroundView = bgColorView
    }
}

extension UIColor {
    public class var main: UIColor {
        return UIColor(red: 240.0 / 255.0, green: 101.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    }
    
    public class func main(alpha: CGFloat) -> UIColor {
        return UIColor(red: 240.0 / 255.0, green: 101.0 / 255.0, blue: 8.0 / 255.0, alpha: alpha)
    }
    
    public class var darkBackground: UIColor {
        return UIColor(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0, alpha: 1.0)
    }
    
    public class var lightBackground: UIColor {
        return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    }
    
    public class var greenPastel: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 169.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
    }
    
    public class var redPastel: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 54.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
    }
}

extension UIColor {
    internal class var systemBlue: UIColor {
        return UIButton(type: .system).tintColor
    }
}
//
//extension UIColor {
//    var inverted: UIColor {
//        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
//        UIColor.red.getRed(&r, green: &g, blue: &b, alpha: &a)
//        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a) // Assuming you want the same alpha value.
//    }
//}
