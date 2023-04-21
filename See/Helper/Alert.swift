//
//  Alert.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import UIKit


struct Alert{
    
    static func show(to vc: UIViewController, title: String? = nil, message: String, compeltionHandler: (() -> Void)? = nil){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title ?? "Failure", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                compeltionHandler?()
            }))
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    static func successMessage(to vc: UIViewController, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            vc.present(alert, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}
