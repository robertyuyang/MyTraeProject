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
