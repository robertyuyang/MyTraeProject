//
//  ItemListConfirmViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

class ItemListConfirmViewController: UIViewController {
    
    var items: [TripItem] = []
    var onConfirm: (([TripItem]) -> Void)?
    
    private let itemListVC = ItemListViewController()
    private let confirmButton = UIButton(type: .system)
    private let bottomBar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupItemListVC()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "确认添加"
    }
    
    private func setupItemListVC() {
        itemListVC.items = items
        itemListVC.isEditingMode = true
        itemListVC.showsAddButton = false
        
        addChild(itemListVC)
        itemListVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(itemListVC.view)
        itemListVC.didMove(toParent: self)
        
        bottomBar.backgroundColor = UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 0.9)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.insertSubview(blurView, at: 0)
        
        confirmButton.backgroundColor = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)
        confirmButton.layer.cornerRadius = 9999
        confirmButton.clipsToBounds = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        bottomBar.addSubview(confirmButton)
        
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .white
        let titleAttr = AttributedString("确认添加", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ]))
        config.attributedTitle = titleAttr
        config.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        config.imagePadding = 12
        config.imagePlacement = .leading
        confirmButton.configuration = config
        
        NSLayoutConstraint.activate([
            itemListVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            itemListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemListVC.view.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100),
            
            blurView.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            
            confirmButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func confirmButtonTapped() {
        // 应用覆盖的优先级到实际物品上
        var finalItems = itemListVC.items
        for (index, item) in finalItems.enumerated() {
            if let override = itemListVC.priorityOverrides[item.id] {
                finalItems[index].defaultPriority = override
            }
        }
        onConfirm?(finalItems)
    }
}
