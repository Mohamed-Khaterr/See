//
//  UIPagingHeaderCollectionReusableView.swift
//  PaggingCollectionView
//
//  Created by Khater on 3/22/23.
//

import UIKit



// MARK: - UIPagingHeaderCollectionReusableView Delegate
protocol UIPagingHeaderCollectionReusableViewDelegate: AnyObject {
    func pagingHeaderCollectionReusableView(didPressedButtonAt index: Int)
}



// MARK: - UIPagingHeaderCollectionReusableView
/// Section header view of UIPaingCollectionView that present the buttons for each Sub CollectionView and present line under the selected button
/// - Presenting the buttons
/// - Presenting line under button
/// - Changing the position of line under selected button
final class UIPagingHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Variables
    public static let kind = "header"
    public static let identifier = "UIPagingHeaderCollectionReusableView"
    public weak var delegate: UIPagingHeaderCollectionReusableViewDelegate?
    private var buttonsTitle: [String] = []
    
    
    // MARK: - UI Components
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let backgroundLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // Balck color for Light Mode and White Color for Dark Mode
        view.backgroundColor = .secondaryLabel
        return view
    }()
    
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        [buttonsStackView, backgroundLineView, lineView].forEach({ addSubview($0) })

    }
    
    required init?(coder: NSCoder) {
        fatalError("[UIPagingHeaderCollectionReusableView]: You can't use view in storyboard")
    }
    
    
    // MARK: - Setup UI
    public func addButtonsTitle(_ titles: [String]) {
        buttonsTitle = titles
        setupButtonsStackView()
        setupLayoutConstraints()
    }
    
    private func setupButtonsStackView() {
        guard buttonsStackView.arrangedSubviews.isEmpty else {
             // print("[UIPagingHeaderCollectionReusableView]: Buttons is already added")
            return
        }
        
        // Add Buttons as arranged subViews to buttonsStackView
        for title in buttonsTitle {
            let button = UIButton()
            button.backgroundColor = .systemBackground
            button.setTitle(title, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            buttonsStackView.addArrangedSubview(button)
        }
    }
    
    private func setupLayoutConstraints() {
        // Titles Stack View Constraints
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: self.topAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonsStackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.88)
        ])
        
        // Background Line View Constraints
        NSLayoutConstraint.activate([
            backgroundLineView.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor),
            backgroundLineView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            backgroundLineView.trailingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor),
            backgroundLineView.heightAnchor.constraint(equalToConstant: 2.5)
        ])
        
        
        // Line View Constraints
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: buttonsStackView.leadingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2.5),
            lineView.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor, multiplier: CGFloat(1) / CGFloat(buttonsTitle.count))
        ])
    }
    
    
    /// Function called to scroll line to the selected button specific point
    /// - Line: is the line under the button
    /// - Change x-axis of the line to specific x-axis position of selected button
    /// - Parameter point: Current point of selected button
    public func scrollToButton(at point: CGPoint) {
        // This Function used only in UIPagingCollectionView -> compositionalLayout()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let buttonsCount = self.buttonsStackView.arrangedSubviews.count
            self.lineView.transform.tx = point.x / CGFloat(buttonsCount)
        }
    }
    
    
    // MARK: - Button Action
    @objc private func buttonPressed(_ sender: UIButton) {
        // Animation for Line View
        UIView.animate(withDuration: 0.3) {
            self.lineView.transform.tx = sender.frame.origin.x
        }
        
        // Find index for pressed button
        if let buttonTitle = sender.titleLabel?.text, let index = buttonsTitle.firstIndex(of: buttonTitle) {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.pagingHeaderCollectionReusableView(didPressedButtonAt: index)
            }
        }
    }
}
