//
//  TemplatesViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

class TemplatesViewController: UIViewController {
    
    private let collectionView: UICollectionView
    private let viewModel = TemplateViewModel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 100, right: 16)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(templateCreated), name: NSNotification.Name("TemplateCreated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func templateCreated() {
        viewModel.loadData()
    }
    
    private func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.reloadRow = { [weak self] index in
            self?.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        setupPageTitle()
        setupCollectionView()
        setupFloatingActionButton()
    }
    
    private func setupPageTitle() {
        let pageTitleLabel = UILabel()
        pageTitleLabel.text = "我的模板"
        pageTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        pageTitleLabel.textColor = .black
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)
        
        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFloatingActionButton() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 30
        addButton.clipsToBounds = true
        addButton.addTarget(self, action: #selector(createNewTemplate), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func createNewTemplate() {
        let alert = UIAlertController(title: "创建新模板", message: "请输入模板名称", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "模板名称"
        }
        
        let confirmAction = UIAlertAction(title: "创建", style: .default) { [weak self] _ in
            guard let self = self, let templateName = alert.textFields?.first?.text, !templateName.isEmpty else { return }
            
            let newTemplate = TripTemplate(name: templateName, items: [], isBuiltIn: false)
            self.viewModel.addTemplate(newTemplate)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.editTemplate(at: self.viewModel.numberOfTemplates() - 1)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func editTemplate(at index: Int) {
        let template = viewModel.template(at: index)
        let editVC = TemplateEditViewController(template: template)
        editVC.onSave = { [weak self] updatedTemplate in
            self?.viewModel.updateTemplate(updatedTemplate, at: index)
        }
        let navVC = UINavigationController(rootViewController: editVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func showOverflowMenu(for index: Int, template: TripTemplate) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        menu.addAction(UIAlertAction(title: "使用为行程", style: .default) { [weak self] _ in
            self?.useAsTrip(template: template)
        })
        
        if !template.isBuiltIn {
            menu.addAction(UIAlertAction(title: "复制", style: .default) { [weak self] _ in
                self?.viewModel.duplicateTemplate(at: index)
            })
            
            menu.addAction(UIAlertAction(title: "重命名", style: .default) { [weak self] _ in
                self?.renameTemplate(at: index)
            })
            
            menu.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
                self?.deleteTemplate(at: index)
            })
        }
        
        menu.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(menu, animated: true)
    }
    
    private func renameTemplate(at index: Int) {
        let template = viewModel.template(at: index)
        let alert = UIAlertController(title: "重命名模板", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = template.name
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            guard let self = self, let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            self.viewModel.renameTemplate(at: index, newName: newName)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func useAsTrip(template: TripTemplate) {
        let alert = UIAlertController(title: "使用模板", message: "基于模板创建新行程", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "创建行程", style: .default) { [weak self] _ in
            guard let self = self else { return }
            var newTrip = template.toTrip()
            let nameAlert = UIAlertController(title: "命名行程", message: "请输入行程名称", preferredStyle: .alert)
            nameAlert.addTextField { textField in
                textField.text = newTrip.name
            }
            
            let createAction = UIAlertAction(title: "创建", style: .default) { _ in
                guard let tripName = nameAlert.textFields?.first?.text, !tripName.isEmpty else { return }
                newTrip.name = tripName
                var trips = DataManager.shared.loadTrips()
                trips.insert(newTrip, at: 0)
                DataManager.shared.saveTrips(trips)
                NotificationCenter.default.post(name: NSNotification.Name("TripCreatedFromTemplate"), object: nil)
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            nameAlert.addAction(createAction)
            nameAlert.addAction(cancelAction)
            self.present(nameAlert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func deleteTemplate(at index: Int) {
        let template = viewModel.template(at: index)
        let alert = UIAlertController(
            title: "删除模板",
            message: "确定要删除 \"\(template.name)\" 吗？",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTemplate(at: index)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension TemplatesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfTemplates()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.identifier, for: indexPath) as! TemplateCollectionViewCell
        let template = viewModel.template(at: indexPath.item)
        cell.configure(template: template)
        
        cell.onMenuTapped = { [weak self] in
            self?.showOverflowMenu(for: indexPath.item, template: template)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        let width = (collectionView.bounds.width - spacing * 3) / 2
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        editTemplate(at: indexPath.item)
    }
}

class TemplateCollectionViewCell: UICollectionViewCell {
    static let identifier = "TemplateCollectionViewCell"
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let priorityStackView = UIStackView()
    private let p0Label = UILabel()
    private let p1Label = UILabel()
    private let p2Label = UILabel()
    private let menuButton = UIButton(type: .system)
    private let builtInBadge = UIView()
    
    var onMenuTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        priorityStackView.axis = .horizontal
        priorityStackView.spacing = 8
        priorityStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(priorityStackView)
        
        for (label, color, title) in [(p0Label, UIColor.systemRed, "P0"), (p1Label, UIColor.systemOrange, "P1"), (p2Label, UIColor.systemBlue, "P2")] {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let badge = UIView()
            badge.backgroundColor = color
            badge.layer.cornerRadius = 4
            badge.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(badge)
            
            label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            badge.addSubview(label)
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            titleLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: container.topAnchor),
                badge.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                badge.widthAnchor.constraint(equalToConstant: 28),
                badge.heightAnchor.constraint(equalToConstant: 20),
                
                label.centerXAnchor.constraint(equalTo: badge.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: badge.centerYAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 4),
                titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            
            priorityStackView.addArrangedSubview(container)
        }
        
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        cardView.addSubview(menuButton)
        
        builtInBadge.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.1)
        builtInBadge.layer.cornerRadius = 4
        builtInBadge.translatesAutoresizingMaskIntoConstraints = false
        let builtInLabel = UILabel()
        builtInLabel.text = "内置"
        builtInLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        builtInLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        builtInLabel.translatesAutoresizingMaskIntoConstraints = false
        builtInBadge.addSubview(builtInLabel)
        NSLayoutConstraint.activate([
            builtInLabel.centerXAnchor.constraint(equalTo: builtInBadge.centerXAnchor),
            builtInLabel.centerYAnchor.constraint(equalTo: builtInBadge.centerYAnchor),
            builtInLabel.leadingAnchor.constraint(equalTo: builtInBadge.leadingAnchor, constant: 8),
            builtInLabel.trailingAnchor.constraint(equalTo: builtInBadge.trailingAnchor, constant: -8)
        ])
        builtInBadge.isHidden = true
        cardView.addSubview(builtInBadge)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -8),
            
            priorityStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            priorityStackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            priorityStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            menuButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            menuButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            menuButton.widthAnchor.constraint(equalToConstant: 32),
            menuButton.heightAnchor.constraint(equalToConstant: 32),
            
            builtInBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            builtInBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16)
        ])
    }
    
    @objc private func menuButtonTapped() {
        onMenuTapped?()
    }
    
    func configure(template: TripTemplate) {
        nameLabel.text = template.name
        builtInBadge.isHidden = !template.isBuiltIn
        
        var p0Count = 0
        var p1Count = 0
        var p2Count = 0
        
        for item in template.items {
            switch item.defaultPriority {
            case .p0: p0Count += 1
            case .p1: p1Count += 1
            case .p2: p2Count += 1
            }
        }
        
        p0Label.text = "\(p0Count)"
        p1Label.text = "\(p1Count)"
        p2Label.text = "\(p2Count)"
    }
}

class TemplateEditViewController: UIViewController, ItemListViewControllerDelegate, CategoryPickerViewControllerDelegate, AddItemViewControllerDelegate {
    
    private var template: TripTemplate
    private let itemListVC = ItemListViewController()
    private var pendingCategoryItem: TripItem?
    
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
        itemListVC.mode = .confirmation
        itemListVC.items = template.items
        itemListVC.isEditingMode = true
        itemListVC.delegate = self
        
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
    
    @objc private func addNewItem() {
        let addVC = AddItemViewController()
        addVC.delegate = self
        addVC.tripName = template.name
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    private func presentCategoryPicker(for item: TripItem) {
        pendingCategoryItem = item
        let picker = CategoryPickerViewController()
        picker.delegate = self
        picker.selectedCategory = item.category
        present(picker, animated: true)
    }
    
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem]) {
        var updatedTemplate = template
        updatedTemplate.items = items
        onSave?(updatedTemplate)
    }
    
    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem) {
        if let index = template.items.firstIndex(where: { $0.id == item.id }) {
            template.items[index] = item
        }
    }
    
    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem]) {
        template.items = items
    }
    
    func itemListViewController(_ controller: ItemListViewController, didRequestNewCategoryForItem item: TripItem) {
        presentCategoryPicker(for: item)
    }
    
    func itemListViewControllerDidRequestAddItem(_ controller: ItemListViewController) {
        addNewItem()
    }
    
    func addItemViewController(_ controller: AddItemViewController, didAddItems items: [TripItem]) {
        for item in items {
            template.items.append(item)
        }
        itemListVC.items = template.items
    }
    
    func categoryPickerViewController(_ controller: CategoryPickerViewController, didSelectCategory category: Category) {
        controller.dismiss(animated: true)
        itemListVC.moveItemToCategory(pendingCategoryItem!, category: category)
        pendingCategoryItem = nil
    }
    
    func categoryPickerViewControllerDidCancel(_ controller: CategoryPickerViewController) {
        controller.dismiss(animated: true)
        pendingCategoryItem = nil
    }
}
