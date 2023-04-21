//
//  UITextField+Extension.swift
//  See
//
//  Created by Khater on 4/12/23.
//

import UIKit


extension UITextField {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .label
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(UITextField.resignFirstResponder))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(UITextField.resignFirstResponder))
        toolBar.items = [space, doneButton]
        toolBar.sizeToFit()
        // Add toolbar to textField
        inputAccessoryView = toolBar
    }
}
