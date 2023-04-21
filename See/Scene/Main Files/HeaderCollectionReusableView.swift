//
//  HeaderCollectionReusableView.swift
//  See
//
//  Created by Khater on 3/22/23.
//

import UIKit


protocol HeaderCollectionReusableViewDelegate: AnyObject {
    func headerCollectionViewButtonPressed()
}


class HeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Variables
    static let identifier = "HeaderCollectionReusableView"
    static let kind = "header"
    
    weak var delegate: HeaderCollectionReusableViewDelegate?
    
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title Label"
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont(name: "Inter-SemiBold", size: 17)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.isHidden = true
        button.isEnabled = false
        return button
    }()
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubviews()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - AddSubviews
    private func addSubviews(){
        [titleLabel, button].forEach({ addSubview($0) })
    }
    
    
    
    // MARK: - LayoutUI
    private func layoutUI() {
        setupTitleLabelConstraints()
        setupButtonConstraints()
    }
    
    private func setupTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 45),
            button.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    @objc private func buttonPressed() {
        delegate?.headerCollectionViewButtonPressed()
    }
    
    
    // MARK: - UpdateUI Functions
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    public func setButton(_ title: String?, image: UIImage?) {
        button.isEnabled = true
        button.isHidden = false
        button.setImage(image, for: .normal)
        
        if let title = title {
            button.setTitle(title, for: .normal)
        }
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
}
