//
//  UIView + Extension.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation
import UIKit


//@IBDesignable
extension UIView {
    
    // MARK: - IBInspectable
    @IBInspectable
    public var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        
        get {
            self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        
        get {
            self.layer.borderWidth
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        
        get {
            UIColor.clear
        }
    }
    
    
    // MARK: - Borders
//    func addBorder(_ color: UIColor? = nil){
//        self.layer.borderWidth = 1
//        if let color = color{
//            self.layer.borderColor = color.cgColor
//        }else{
//            self.layer.borderColor = UIColor(named: "Gray Color")?.cgColor
//        }
//    }
//    
//    
//    // MARK: - Corner Radius
//    func cornerRadius(_ ratio: CGFloat? = nil){
//        if let ratio = ratio {
//            self.layer.cornerRadius = ratio
//        }else{
//            self.layer.cornerRadius = self.frame.height / 2
//        }
//    }
    
    
    // MARK: - Gradient Layer
    func addGradientLayer(withHeightRatio height: CGFloat) {
        if height > 1 || height < 0 {
            fatalError("Gradient Layer Height must be less than 1 & more than 0")
        }
        
        guard self.layer.sublayers == nil else {
            // if there is sublayers this mean there is gradient layer so return
            // to prevent adding more sublayers
            return
        }
        
        
        // To start from bottom
        let y = self.frame.height - (self.frame.height * height)
        let layerHeight = self.frame.height * height
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: y, width: self.frame.width, height: layerHeight)
        //gradientLayer.backgroundColor = UIColor.red.cgColor
        
        // Gradient Layer Apperance
        gradientLayer.colors = [UIColor.clear, UIColor.black.cgColor]
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        // second number is the space that the white color take
        gradientLayer.locations = [0.0, 0.4]
        
        
        self.clipsToBounds = true
        self.layer.addSublayer(gradientLayer)
    }
}
