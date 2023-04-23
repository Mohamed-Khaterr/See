//
//  RatingSection.swift
//  See
//
//  Created by Khater on 3/31/23.
//

import UIKit

protocol RatingSectionDelegate: AnyObject {
    func ratingSection(didSelectRate rate: Double?)
}


class RatingSection: NSObject, TableViewSection {
    
    
    // MARK: - Variables
    public weak var delegate: RatingSectionDelegate?
    
    
    private let rates: [Double] = [0, 9, 8, 7, 6, 5, 4, 3]
    
    // MARK: - UI Components
    private let textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.addDoneButton()
        return textField
    }()
    
    private let pickerView = UIPickerView()
    
    
    init(selectedRate rate: Double?) {
        super.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        textField.inputView = pickerView
        textField.text = (rate != nil) ? "\(rate!)+" : "Not Selected"
    }
    
    
    // MARK: - DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Rating"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        textField.frame = cell.bounds
        textField.frame.origin.x += 18
        cell.addSubview(textField)
        return cell
    }
    
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textField.becomeFirstResponder()
    }
}


// MARK: - UIPickerView DataSource
extension RatingSection: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rates.count
    }
}



// MARK: - UIPickerView Delegate
extension RatingSection: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Not Selected" : "\(rates[row])+"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            textField.text = "Not Selected"
            delegate?.ratingSection(didSelectRate: nil)
        } else {
            textField.text = "\(rates[row])+"
            delegate?.ratingSection(didSelectRate: rates[row])
        }
    }
}
