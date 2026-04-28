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
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
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
            guard let self = self else { return }
            self.template.items = self.itemListVC.items
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
    
    @objc private func doneTapped() {
        var updatedTemplate = template
        updatedTemplate.items = itemListVC.items
        onSave?(updatedTemplate)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
