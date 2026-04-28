//
//  TemplateOverflowMenuView.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

enum TemplateOverflowMenuAction {
    case createTrip
    case duplicate
    case rename
    case delete
}

class TemplateOverflowMenuView: UIView {
    
    var onAction: ((TemplateOverflowMenuAction) -> Void)?
    private let backgroundOverlay = UIButton(type: .custom)
    private let showRenameAndDelete: Bool
    
    init(showRenameAndDelete: Bool = true) {
        self.showRenameAndDelete = showRenameAndDelete
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 193/255, green: 198/255, blue: 215/255, alpha: 0.2).cgColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        let createButton = createMenuItem(
            icon: "plus",
            title: "创建行程",
            titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
            action: #selector(createTripTapped),
            bottomPadding: 12
        )
        stackView.addArrangedSubview(createButton)
        
        if showRenameAndDelete {
            let duplicateButton = createMenuItem(
                icon: "doc.on.doc",
                title: "复制",
                titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
                action: #selector(duplicateTapped),
                bottomPadding: 12
            )
            
            let renameButton = createMenuItem(
                icon: "pencil",
                title: "重命名",
                titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
                action: #selector(renameTapped),
                bottomPadding: 16
            )
            
            let divider = UIView()
            divider.backgroundColor = UIColor(red: 193/255, green: 198/255, blue: 215/255, alpha: 0.15)
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            let dividerContainer = UIView()
            dividerContainer.translatesAutoresizingMaskIntoConstraints = false
            dividerContainer.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: dividerContainer.leadingAnchor, constant: 8),
                divider.trailingAnchor.constraint(equalTo: dividerContainer.trailingAnchor, constant: -8),
                divider.topAnchor.constraint(equalTo: dividerContainer.topAnchor),
                divider.bottomAnchor.constraint(equalTo: dividerContainer.bottomAnchor)
            ])
            
            let deleteButton = createMenuItem(
                icon: "trash",
                title: "删除",
                titleColor: UIColor(red: 188/255, green: 0/255, blue: 10/255, alpha: 1.0),
                action: #selector(deleteTapped),
                topPadding: 16,
                bottomPadding: 12
            )
            
            stackView.addArrangedSubview(duplicateButton)
            stackView.addArrangedSubview(renameButton)
            stackView.addArrangedSubview(dividerContainer)
            stackView.addArrangedSubview(deleteButton)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 224).isActive = true
    }
    
    private func createMenuItem(
        icon: String,
        title: String,
        titleColor: UIColor,
        action: Selector,
        topPadding: CGFloat = 12,
        bottomPadding: CGFloat = 12
    ) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = titleColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = titleColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let tapButton = UIButton(type: .system)
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        tapButton.addTarget(self, action: action, for: .touchUpInside)
        
        container.addSubview(iconView)
        container.addSubview(label)
        container.addSubview(tapButton)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            container.heightAnchor.constraint(equalToConstant: topPadding + 16 + (bottomPadding - 12)),
            
            tapButton.topAnchor.constraint(equalTo: container.topAnchor),
            tapButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    func show(in parentView: UIView, anchorPoint: CGPoint) {
        backgroundOverlay.frame = parentView.bounds
        backgroundOverlay.backgroundColor = .clear
        backgroundOverlay.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        parentView.addSubview(backgroundOverlay)
        
        parentView.addSubview(self)
        
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        let menuWidth: CGFloat = 224
        var x = anchorPoint.x - menuWidth
        let y = anchorPoint.y + 4
        
        if x < 16 { x = 16 }
        if x + menuWidth > parentView.bounds.width - 16 {
            x = parentView.bounds.width - menuWidth - 16
        }
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: y),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: x)
        ])
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.backgroundOverlay.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    @objc private func createTripTapped() {
        dismiss()
        onAction?(.createTrip)
    }
    
    @objc private func duplicateTapped() {
        dismiss()
        onAction?(.duplicate)
    }
    
    @objc private func renameTapped() {
        dismiss()
        onAction?(.rename)
    }
    
    @objc private func deleteTapped() {
        dismiss()
        onAction?(.delete)
    }
}
