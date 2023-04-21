//
//  ReleaseYearSection.swift
//  See
//
//  Created by Khater on 4/3/23.
//

import UIKit


protocol ReleaseYearSectionDelegate: AnyObject {
    func releaseYearSection(didSelectYear year: Int?)
}


final class ReleaseYearSection: NSObject, TableViewSection {
    
    
    // MARK: - Variables
    public weak var delegate: ReleaseYearSectionDelegate?
    private var years: [Int] = Array(1990...Constant.currentYear)
    
    
    // MARK: - UI Components
    private let texField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.addDoneButton()
        return textField
    }()
    
    private let pickerView = UIPickerView()
    
    
    // MARK: - Life Cycle
    init(selectedReleaseYear year: Int?) {
        super.init()
        years.append(0)
        years.reverse()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        texField.inputView = pickerView
        texField.text = (year != nil) ? String(year!) : "Not Selected"
    }
    
    
    // MARK: DataSource
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Release Year"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        texField.frame = cell.bounds
        texField.frame.origin.x += 18
        cell.addSubview(texField)
        return cell
    }
    
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        texField.becomeFirstResponder()
    }
}





// MARK: - UIPickerView DataSource
extension ReleaseYearSection: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
}




// MARK: - UIPickerView Delegate
extension ReleaseYearSection: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (years[row] == 0) ? "Not Selected" : String(years[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if years[row] == 0 {
            delegate?.releaseYearSection(didSelectYear: nil)
            texField.text = "Not Selected"
            
        } else {
            texField.text = String(years[row])
            delegate?.releaseYearSection(didSelectYear: years[row])
        }
    }
}
