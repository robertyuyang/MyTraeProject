//
//  TemplatesViewController.swift
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
    
    private func showOverflowMenu(for index: Int, template: TripTemplate, from cell: TemplateCollectionViewCell) {
        let menuView = TemplateOverflowMenuView(showRenameAndDelete: !template.isBuiltIn)
        
        menuView.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .createTrip:
                self.createTrip(from: template)
            case .duplicate:
                self.viewModel.duplicateTemplate(at: index)
            case .rename:
                self.renameTemplate(at: index)
            case .delete:
                self.deleteTemplate(at: index)
            }
        }
        
        let cellFrame = cell.convert(cell.bounds, to: view)
        let anchorPoint = CGPoint(x: cellFrame.maxX - 12, y: cellFrame.minY + 44)
        menuView.show(in: view, anchorPoint: anchorPoint)
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
    
    private func createTrip(from template: TripTemplate) {
        let alert = UIAlertController(title: "创建行程", message: "基于模板创建新行程", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "请输入行程名称"
            textField.text = template.name
        }
        
        let confirmAction = UIAlertAction(title: "创建", style: .default) { [weak self] _ in
            guard let self = self, let tripName = alert.textFields?.first?.text, !tripName.isEmpty else { return }
            var newTrip = template.toTrip()
            newTrip.name = tripName
            var trips = DataManager.shared.loadTrips()
            trips.insert(newTrip, at: 0)
            DataManager.shared.saveTrips(trips)
            NotificationCenter.default.post(name: NSNotification.Name("TripCreatedFromTemplate"), object: nil)
            
            let successAlert = UIAlertController(title: "创建成功", message: "行程已创建", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(successAlert, animated: true)
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
        
        cell.onMenuTapped = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.showOverflowMenu(for: indexPath.item, template: template, from: cell)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        let width = (collectionView.bounds.width - spacing * 3) / 2
        return CGSize(width: width, height: 120)
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
    private var p0Container: UIView?
    private var p1Container: UIView?
    private var p2Container: UIView?
    private let totalLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    
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
        
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        priorityStackView.axis = .horizontal
        priorityStackView.spacing = 8
        priorityStackView.alignment = .center
        priorityStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(priorityStackView)
        
        // 创建 P0 容器
        let p0Cont = createPriorityContainer(label: p0Label, color: UIColor.systemRed, title: "P0")
        p0Container = p0Cont
        priorityStackView.addArrangedSubview(p0Cont)
        
        // 创建 P1 容器
        let p1Cont = createPriorityContainer(label: p1Label, color: UIColor.systemOrange, title: "P1")
        p1Container = p1Cont
        priorityStackView.addArrangedSubview(p1Cont)
        
        // 创建 P2 容器
        let p2Cont = createPriorityContainer(label: p2Label, color: UIColor.systemBlue, title: "P2")
        p2Container = p2Cont
        priorityStackView.addArrangedSubview(p2Cont)
        
        totalLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        totalLabel.textColor = .black
        totalLabel.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
        totalLabel.textAlignment = .center
        totalLabel.layer.cornerRadius = 14
        totalLabel.clipsToBounds = true
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(totalLabel)
        
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        cardView.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            menuButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            menuButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            menuButton.widthAnchor.constraint(equalToConstant: 28),
            menuButton.heightAnchor.constraint(equalToConstant: 28),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -6),
            
            priorityStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priorityStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            priorityStackView.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            
            totalLabel.topAnchor.constraint(equalTo: priorityStackView.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            totalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            totalLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            totalLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    @objc private func menuButtonTapped() {
        onMenuTapped?()
    }
    
    private func createPriorityContainer(label: UILabel, color: UIColor, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 6
        container.layer.borderWidth = 1
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "\(title):"
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
        ])
        
        return container
    }
    
    func configure(template: TripTemplate) {
        nameLabel.text = template.name
        
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
        
        let totalCount = p0Count + p1Count + p2Count
        totalLabel.text = "\(totalCount) ITEMS TOTAL"
        
        // 隐藏数量为0的优先级
        p0Container?.isHidden = p0Count == 0
        p1Container?.isHidden = p1Count == 0
        p2Container?.isHidden = p2Count == 0
    }
}

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

// MARK: - ItemListConfirmViewController

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
        onConfirm?(itemListVC.items)
    }
}
