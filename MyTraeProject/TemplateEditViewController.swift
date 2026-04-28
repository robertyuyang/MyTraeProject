//
//  TemplateEditViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

class TemplateEditViewController: UIViewController {
    
    private var template: TripTemplate
    private let itemListVC = ItemListViewController()
    
    var onSave: ((TripTemplate) -> Void)?
    
    init(template: TripTemplate) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupItemList()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "编辑模板"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func setupItemList() {
        itemListVC.items = template.items
        itemListVC.isEditingMode = true
        itemListVC.showsAddButton = true
        
        // 设置闭包
        itemListVC.configureAddItemVC = { [weak self] addVC in
            guard let self = self else { return }
            addVC.tripName = self.template.name
        }
        itemListVC.onDataChange = { [weak self] in
            self?.saveAndUpdate()
        }
        
        addChild(itemListVC)
        itemListVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(itemListVC.view)
        itemListVC.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            itemListVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            itemListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemListVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func saveAndUpdate() {
        template.items = itemListVC.items
        onSave?(template)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
