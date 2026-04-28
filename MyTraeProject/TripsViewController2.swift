//
//  TripsViewController2.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/7.
//

import UIKit

class TripsViewController2: UIViewController {
    
    private let tableView = UITableView()
    private let viewModel = TripViewModel()
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.loadData()
        
        // 监听从模板创建trip的通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTripCreatedFromTemplate),
            name: NSNotification.Name("TripCreatedFromTemplate"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保导航栏始终隐藏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleTripCreatedFromTemplate() {
        viewModel.loadData()
    }
    
    private func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.reloadRow = { [weak self] index in
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .automatic)
        }
    }
    
    private func setupUI() {
        // 设置背景颜色
        view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        // 添加页面标题
        setupPageTitle()
        
        // 设置表格视图
        setupTableView()
        
        // 添加浮动操作按钮
        setupFloatingActionButton()
    }
    
    private func setupPageTitle() {
        // 添加页面标题
        let pageTitleLabel = UILabel()
        pageTitleLabel.text = "My Trips"
        pageTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        pageTitleLabel.textColor = .black
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)
        
        NSLayoutConstraint.activate([
            // 页面标题约束
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TripCell.self, forCellReuseIdentifier: "TripCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFloatingActionButton() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 30
        addButton.clipsToBounds = true
        addButton.addTarget(self, action: #selector(createNewTrip), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func createNewTrip() {
        // 实现创建新旅行的逻辑
        let alert = UIAlertController(title: "Create New Trip", message: "Enter trip name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Trip name"
        }
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self, let tripName = alert.textFields?.first?.text, !tripName.isEmpty else { return }
            
            // 显示loading
            self.loadingView.show(in: self.view, message: "Creating trip...")
            
            self.viewModel.createNewTrip(name: tripName) {
                // 创建完成，隐藏loading
                self.loadingView.hide()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TripsViewController2: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfTrips()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripCell
        let trip = viewModel.trip(at: indexPath.section)
        cell.configure(trip: trip, viewModel: viewModel)
        cell.onMenuTapped = { [weak self] in
            self?.showOverflowMenu(for: indexPath.section, from: cell)
        }
        cell.onNameEdited = { [weak self] newName in
            self?.viewModel.renameTrip(at: indexPath.section, newName: newName)
        }
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 实现点击卡片的逻辑
        let trip = viewModel.trip(at: indexPath.section)
        let detailVC = DetailViewController()
        detailVC.trip = trip
        detailVC.index = indexPath.section
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Overflow Menu

extension TripsViewController2 {
    func showOverflowMenu(for sectionIndex: Int, from cell: TripCell) {
        let menuView = OverflowMenuView()
        
        menuView.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .editName:
                self.handleEditName(at: sectionIndex)
            case .duplicate:
                self.viewModel.copyTrip(at: sectionIndex)
            case .saveAsTemplate:
                self.handleSaveAsTemplate(at: sectionIndex)
            case .delete:
                self.handleDelete(at: sectionIndex)
            }
        }
        
        let cellFrame = cell.convert(cell.bounds, to: view)
        let anchorPoint = CGPoint(x: cellFrame.maxX - 12, y: cellFrame.minY + 44)
        menuView.show(in: view, anchorPoint: anchorPoint)
    }
    
    private func handleEditName(at index: Int) {
        let indexPath = IndexPath(row: 0, section: index)
        guard let cell = tableView.cellForRow(at: indexPath) as? TripCell else { return }
        cell.beginEditingName()
    }
    
    private func handleSaveAsTemplate(at index: Int) {
        let trip = viewModel.trip(at: index)
        let alert = UIAlertController(title: "Save as Template", message: "Enter template name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = trip.name
        }
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let templateName = alert.textFields?.first?.text, !templateName.isEmpty else { return }
            
            let template = trip.toTemplate(name: templateName)
            var templates = DataManager.shared.loadTemplates()
            templates.insert(template, at: 0)
            DataManager.shared.saveTemplates(templates)
            
            let successAlert = UIAlertController(title: "Saved", message: "Trip saved as template successfully!", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func handleDelete(at index: Int) {
        let trip = viewModel.trip(at: index)
        let alert = UIAlertController(
            title: "Delete Trip",
            message: "Are you sure you want to delete \"\(trip.name)\"?",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTrip(at: index)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - DetailViewControllerDelegate

extension TripsViewController2: DetailViewControllerDelegate {
    func detailViewController(_ controller: DetailViewController, didUpdateTrip trip: Trip, at index: Int) {
        viewModel.updateTrip(trip, at: index)
    }
}

// MARK: - TripCell

class TripCell: UITableViewCell, UITextFieldDelegate {
    private let statusLabel = UILabel()
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let p0ProgressLabel = UILabel()
    private let p0ProgressTextLabel = UILabel()
    private let p0ProgressBar = UIProgressView(progressViewStyle: .default)
    private let totalProgressLabel = UILabel()
    private let totalProgressTextLabel = UILabel()
    private let totalProgressBar = UIProgressView(progressViewStyle: .default)
    private let tripImageView = UIImageView()
    private let menuButton = UIButton(type: .system)
    
    private var editingOverlay: UIView?
    
    var onMenuTapped: (() -> Void)?
    var onNameEdited: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置卡片样式
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 创建卡片容器
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowRadius = 4
        cardView.layer.masksToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // 延迟设置shadowPath，确保cardView有正确的bounds
        DispatchQueue.main.async {
            cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16).cgPath
        }
        
        // 状态标签
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(statusLabel)
        
        // 菜单按钮
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        cardView.addSubview(menuButton)
        
        // 名称标签
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // 名称编辑框
        nameTextField.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameTextField.textColor = .black
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = .clear
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameTextField)
        
        // P0进度标签和文本
        let p0StackView = UIStackView()
        p0StackView.axis = .horizontal
        p0StackView.alignment = .center
        p0StackView.distribution = .fill
        p0StackView.spacing = 8
        p0StackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(p0StackView)
        
        p0ProgressLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        p0ProgressLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0) // systemRed
        p0ProgressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        p0ProgressTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        p0ProgressTextLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0) // systemRed
        p0ProgressTextLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        p0StackView.addArrangedSubview(p0ProgressLabel)
        p0StackView.addArrangedSubview(p0ProgressTextLabel)
        
        // P0进度条
        p0ProgressBar.tintColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0) // systemRed
        p0ProgressBar.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // systemGray6
        p0ProgressBar.layer.cornerRadius = 3
        p0ProgressBar.clipsToBounds = true
        p0ProgressBar.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(p0ProgressBar)
        
        // 总进度标签和文本
        let totalStackView = UIStackView()
        totalStackView.axis = .horizontal
        totalStackView.alignment = .center
        totalStackView.distribution = .fill
        totalStackView.spacing = 8
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(totalStackView)
        
        totalProgressLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        totalProgressLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0) // systemGray
        totalProgressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        totalProgressTextLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        totalProgressTextLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0) // systemGray
        totalProgressTextLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        totalStackView.addArrangedSubview(totalProgressLabel)
        totalStackView.addArrangedSubview(totalProgressTextLabel)
        
        // 总进度条
        totalProgressBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0) // systemBlue
        totalProgressBar.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // systemGray6
        totalProgressBar.layer.cornerRadius = 3
        totalProgressBar.clipsToBounds = true
        totalProgressBar.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(totalProgressBar)
        
        // 图片视图
        tripImageView.contentMode = .scaleAspectFill
        tripImageView.clipsToBounds = true
        tripImageView.layer.cornerRadius = 12
        tripImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(tripImageView)
        
        NSLayoutConstraint.activate([
            // 卡片容器约束
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // 状态标签
            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 菜单按钮
            menuButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            menuButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            menuButton.widthAnchor.constraint(equalToConstant: 32),
            menuButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 名称标签
            nameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // 名称编辑框
            nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            // P0进度标签和文本
            p0StackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            p0StackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            p0StackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // P0进度条
            p0ProgressBar.topAnchor.constraint(equalTo: p0StackView.bottomAnchor, constant: 4),
            p0ProgressBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            p0ProgressBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            p0ProgressBar.heightAnchor.constraint(equalToConstant: 6),
            
            // 总进度标签和文本
            totalStackView.topAnchor.constraint(equalTo: p0ProgressBar.bottomAnchor, constant: 12),
            totalStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            totalStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // 总进度条
            totalProgressBar.topAnchor.constraint(equalTo: totalStackView.bottomAnchor, constant: 4),
            totalProgressBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            totalProgressBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            totalProgressBar.heightAnchor.constraint(equalToConstant: 6),
            
            // 图片视图
            tripImageView.topAnchor.constraint(equalTo: totalProgressBar.bottomAnchor, constant: 16),
            tripImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tripImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            tripImageView.heightAnchor.constraint(equalToConstant: 160),
            tripImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func menuButtonTapped() {
        onMenuTapped?()
    }
    
    func beginEditingName() {
        nameTextField.text = nameLabel.text
        nameTextField.isHidden = false
        nameLabel.isHidden = true
        nameTextField.becomeFirstResponder()
        
        guard let window = window else { return }
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .clear
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlay.addGestureRecognizer(tap)
        window.addSubview(overlay)
        editingOverlay = overlay
    }
    
    @objc private func overlayTapped() {
        commitEditingName()
    }
    
    private func commitEditingName() {
        guard !nameTextField.isHidden else { return }
        let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        nameTextField.isHidden = true
        nameLabel.isHidden = false
        nameTextField.resignFirstResponder()
        editingOverlay?.removeFromSuperview()
        editingOverlay = nil
        if !newName.isEmpty && newName != nameLabel.text {
            nameLabel.text = newName
            onNameEdited?(newName)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitEditingName()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        commitEditingName()
    }
    
    func configure(trip: Trip, viewModel: TripViewModel) {
        // 设置名称
        nameLabel.text = trip.name
        
        // 计算进度和状态
        let p0Progress = viewModel.p0Progress(for: trip)
        let totalProgress = viewModel.totalProgress(for: trip)
        let status = viewModel.getTripStatus(for: trip)
        
        // 设置状态标签
        statusLabel.text = status.rawValue
        statusLabel.textColor = status.color
        statusLabel.backgroundColor = status.backgroundColor
        statusLabel.layer.cornerRadius = 3
        statusLabel.clipsToBounds = true
        statusLabel.textAlignment = .center
        statusLabel.sizeToFit()
        statusLabel.frame.size.width += 16
        statusLabel.frame.size.height = 20
        
        // 设置P0进度
        p0ProgressLabel.text = "Critical Essentials (P0)"
        p0ProgressTextLabel.text = "\(p0Progress.checked)/\(p0Progress.total)"
        p0ProgressBar.progress = Float(p0Progress.percentage)
        
        // 设置总进度
        totalProgressLabel.text = "Total Preparation"
        totalProgressTextLabel.text = "\(totalProgress.checked)/\(totalProgress.total)"
        totalProgressBar.progress = Float(totalProgress.percentage)
        
        // 加载图片
        if let imageUrl = trip.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.tripImageView.image = image
                    }
                } else {
                    // 图片加载失败，使用默认图片
                    DispatchQueue.main.async {
                        self?.tripImageView.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
                    }
                }
            }.resume()
        } else {
            // 没有图片URL，使用默认图片
            tripImageView.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
    }
}

// MARK: - OverflowMenuView

enum OverflowMenuAction {
    case editName
    case duplicate
    case saveAsTemplate
    case delete
}

class OverflowMenuView: UIView {
    
    var onAction: ((OverflowMenuAction) -> Void)?
    private let backgroundOverlay = UIButton(type: .custom)
    
    init() {
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
        
        let editButton = createMenuItem(
            icon: "pencil",
            title: "Edit Name",
            titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
            action: #selector(editNameTapped),
            bottomPadding: 12
        )
        let duplicateButton = createMenuItem(
            icon: "doc.on.doc",
            title: "Duplicate",
            titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
            action: #selector(duplicateTapped),
            bottomPadding: 12
        )
        let saveButton = createMenuItem(
            icon: "bookmark",
            title: "Save as Template",
            titleColor: UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0),
            action: #selector(saveAsTemplateTapped),
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
            title: "Delete",
            titleColor: UIColor(red: 188/255, green: 0/255, blue: 10/255, alpha: 1.0),
            action: #selector(deleteTapped),
            topPadding: 16,
            bottomPadding: 12
        )
        
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(duplicateButton)
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(dividerContainer)
        stackView.addArrangedSubview(deleteButton)
        
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
    
    @objc private func editNameTapped() {
        dismiss()
        onAction?(.editName)
    }
    
    @objc private func duplicateTapped() {
        dismiss()
        onAction?(.duplicate)
    }
    
    @objc private func saveAsTemplateTapped() {
        dismiss()
        onAction?(.saveAsTemplate)
    }
    
    @objc private func deleteTapped() {
        dismiss()
        onAction?(.delete)
    }
}
