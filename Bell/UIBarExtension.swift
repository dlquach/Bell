//  UINavigationController.swift
//  Created by Ricardo López Rey on 16/7/15.

import Foundation
import UIKit

struct UINavigationControllerExtension {
    static var hideShadowKey : String = "HideShadow"
    static let backColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1.0)
}

extension UINavigationController {
    
    var hideShadow : Bool {
        get {
            if let ret =  objc_getAssociatedObject(self, &UINavigationControllerExtension.hideShadowKey) as? Bool {
                return ret
            } else {
                return false
            }
            
            
        }
        set {
            objc_setAssociatedObject(self,&UINavigationControllerExtension.hideShadowKey,newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if newValue {
                
                
                self.navigationBar.setBackgroundImage(solidImage(UINavigationControllerExtension.backColor), forBarMetrics: UIBarMetrics.Default)
                
                self.navigationBar.shadowImage = solidImage(UIColor.clearColor())
            } else {
                self.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
            }
        }
    }
    
    private func solidImage(color: UIColor, size: CGSize = CGSize(width: 1,height: 1)) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    

}