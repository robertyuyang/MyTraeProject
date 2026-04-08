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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
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
        
        // 设置导航栏
        setupNavigationBar()
        
        // 设置表格视图
        setupTableView()
        
        // 添加底部导航栏
        setupBottomNavBar()
        
        // 添加浮动操作按钮
        setupFloatingActionButton()
    }
    
    private func setupNavigationBar() {
        // 隐藏默认导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 创建自定义导航栏
        let navBarView = UIView()
        navBarView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBarView)
        
        // 添加应用图标
        let appIcon = UIImageView()
        appIcon.image = UIImage(systemName: "suitcase")
        appIcon.tintColor = .systemBlue
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(appIcon)
        
        // 添加应用标题
        let appTitleLabel = UILabel()
        appTitleLabel.text = "The Editorial Traveler"
        appTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        appTitleLabel.textColor = .black
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(appTitleLabel)
        
        // 添加页面标题
        let pageTitleLabel = UILabel()
        pageTitleLabel.text = "My Trips"
        pageTitleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        pageTitleLabel.textColor = .black
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)
        
        NSLayoutConstraint.activate([
            // 导航栏约束
            navBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 44),
            
            // 应用图标约束
            appIcon.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 16),
            appIcon.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            appIcon.widthAnchor.constraint(equalToConstant: 24),
            appIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // 应用标题约束
            appTitleLabel.leadingAnchor.constraint(equalTo: appIcon.trailingAnchor, constant: 8),
            appTitleLabel.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            
            // 页面标题约束
            pageTitleLabel.topAnchor.constraint(equalTo: navBarView.bottomAnchor, constant: 24),
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
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 100, right: 0) // 为底部导航栏留出空间
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100), // 为导航栏和页面标题留出空间
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBottomNavBar() {
        let tabBarView = UIView()
        tabBarView.backgroundColor = .white
        tabBarView.layer.borderWidth = 1.0
        tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        
        // 使用StackView来管理三个标签项
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(stackView)
        
        // 添加三个标签项
        let tripsItem = createTabBarItem(title: "Trips", isSelected: true)
        let templatesItem = createTabBarItem(title: "Templates", isSelected: false)
        let settingsItem = createTabBarItem(title: "Settings", isSelected: false)
        
        stackView.addArrangedSubview(tripsItem)
        stackView.addArrangedSubview(templatesItem)
        stackView.addArrangedSubview(settingsItem)
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createTabBarItem(title: String, isSelected: Bool) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        let label = UILabel()
        
        // 设置图标
        switch title {
        case "Trips":
            imageView.image = UIImage(systemName: "suitcase")
        case "Templates":
            imageView.image = UIImage(systemName: "doc.text")
        case "Settings":
            imageView.image = UIImage(systemName: "gear")
        default:
            imageView.image = UIImage(systemName: "circle")
        }
        
        // 设置颜色
        let color = isSelected ? UIColor.systemBlue : UIColor.secondaryLabel
        imageView.tintColor = color
        label.textColor = color
        
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        return stackView
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
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100), // 调整位置，避免被底部导航栏遮挡
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
            
            self.viewModel.createNewTrip(name: tripName) {}
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
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340 // 调整高度以适应卡片布局
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16 // 设置顶部间距
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16 // 设置卡片之间的间距
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

// MARK: - DetailViewControllerDelegate

extension TripsViewController2: DetailViewControllerDelegate {
    func detailViewController(_ controller: DetailViewController, didUpdateTrip trip: Trip, at index: Int) {
        viewModel.updateTrip(trip, at: index)
    }
}

// MARK: - TripCell

class TripCell: UITableViewCell {
    private let statusLabel = UILabel()
    private let nameLabel = UILabel()
    private let p0ProgressLabel = UILabel()
    private let p0ProgressTextLabel = UILabel()
    private let p0ProgressBar = UIProgressView(progressViewStyle: .default)
    private let totalProgressLabel = UILabel()
    private let totalProgressTextLabel = UILabel()
    private let totalProgressBar = UIProgressView(progressViewStyle: .default)
    private let tripImageView = UIImageView()
    
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
        
        // 名称标签
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
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
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // 状态标签
            statusLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // 名称标签
            nameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
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
