//DetailViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ controller: DetailViewController, didUpdateTrip trip: Trip, at index: Int)
}

class DetailViewController: UIViewController {
    
    weak var delegate: DetailViewControllerDelegate?
    var trip: Trip!
    var index: Int!
    
    private let stackView = UIStackView()
    private let p0ProgressView = ProgressView()
    private let p1ProgressView = ProgressView()
    private let p2ProgressView = ProgressView()
    private let tableView = UITableView()

    private let floatingActionButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 确保导航栏可见
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        updateProgress()
    }
    
    private func setupUI() {
        title = trip.name
        view.backgroundColor = .systemBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 添加返回按钮
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(closeDetailView), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        p0ProgressView.title = "P0 Essentials"
        p0ProgressView.subtitle = "85%"
        p0ProgressView.color = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
        p0ProgressView.isDominant = true
        p0ProgressView.progress = 0.85
        stackView.addArrangedSubview(p0ProgressView)
        
        p1ProgressView.title = "Core (P0+P1)"
        p1ProgressView.subtitle = "62%"
        p1ProgressView.color = UIColor(red: 255/255, green: 160/255, blue: 140/255, alpha: 1.0)
        p1ProgressView.isCompact = true
        p1ProgressView.progress = 0.62
        stackView.addArrangedSubview(p1ProgressView)
        
        p2ProgressView.title = "All Items"
        p2ProgressView.subtitle = "48%"
        p2ProgressView.color = UIColor(red: 255/255, green: 190/255, blue: 175/255, alpha: 1.0)
        p2ProgressView.isCompact = true
        p2ProgressView.progress = 0.48
        stackView.addArrangedSubview(p2ProgressView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 设置浮动操作按钮
        floatingActionButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingActionButton.tintColor = .white
        floatingActionButton.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0) // 红色
        floatingActionButton.layer.cornerRadius = 28
        floatingActionButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        floatingActionButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingActionButton.layer.shadowOpacity = 1
        floatingActionButton.layer.shadowRadius = 8
        floatingActionButton.translatesAutoresizingMaskIntoConstraints = false
        floatingActionButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
        view.addSubview(floatingActionButton)
        
        // 浮动操作按钮约束
        NSLayoutConstraint.activate([
            floatingActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingActionButton.widthAnchor.constraint(equalToConstant: 56),
            floatingActionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func updateProgress() {
        let items = trip.items
        
        for priority in Priority.allCases {
            let priorityItems = items.filter { trip.priority(for: $0) == priority }
            let checkedCount = priorityItems.filter { trip.isItemChecked($0) }.count
            let totalCount = priorityItems.count
            let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
            
            switch priority {
            case .p0:
                p0ProgressView.progress = percentage
                p0ProgressView.subtitle = "\(checkedCount)/\(totalCount)"
            case .p1:
                p1ProgressView.progress = percentage
                p1ProgressView.subtitle = "\(checkedCount)/\(totalCount)"
            case .p2:
                p2ProgressView.progress = percentage
                p2ProgressView.subtitle = "\(checkedCount)/\(totalCount)"
            }
        }
    }
    
    private func saveAndUpdate() {
        updateProgress()
        tableView.reloadData()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }
    
    @objc private func addNewItem() {
        let alert = UIAlertController(title: "添加物品", message: nil, preferredStyle: .actionSheet)
        
        for category in BuiltInCategory.allCases {
            alert.addAction(UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.showPrioritySelectionAlert(category: category)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showPrioritySelectionAlert(category: Category) {
        let alert = UIAlertController(title: "选择优先级", message: "类别: \(category)", preferredStyle: .actionSheet)
        
        for priority in Priority.allCases {
            alert.addAction(UIAlertAction(title: priority.title, style: .default) { [weak self] _ in
                self?.showItemNameAlert(category: category, priority: priority)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showItemNameAlert(category: Category, priority: Priority) {
        let alert = UIAlertController(title: "输入物品名称", message: "类别: \(category), 优先级: \(priority.title)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "物品名称"
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            guard let self = self, let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            let newItem = TripItem(name: name, defaultPriority: priority, category: category)
            self.trip.items.append(newItem)
            self.saveAndUpdate()
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func closeDetailView() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    // 按类别对物品进行分组
    private var groupedItems: [Category: [TripItem]] {
        return Dictionary(grouping: trip.items) { $0.category }
    }
    
    private var sortedCategories: [Category] {
        let grouped = groupedItems
        let builtIn = BuiltInCategory.allCases.filter { grouped[$0] != nil }
        let custom = grouped.keys.filter { !BuiltInCategory.allCases.contains($0) }.sorted()
        return builtIn + custom
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = sortedCategories[section]
        return groupedItems[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = sortedCategories[section]
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let category = sortedCategories[indexPath.section]
        let items = groupedItems[category]!
        let item = items[indexPath.row]
        cell.configure(with: item, priority: trip.priority(for: item), isChecked: trip.isItemChecked(item))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = sortedCategories[indexPath.section]
        let items = groupedItems[category]!
        let item = items[indexPath.row]
        trip.toggleItemChecked(item)
        saveAndUpdate()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let category = self.sortedCategories[indexPath.section]
            let items = self.groupedItems[category]!
            let item = items[indexPath.row]
            if let index = self.trip.items.firstIndex(where: { $0.id == item.id }) {
                self.trip.items.remove(at: index)
                self.saveAndUpdate()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

class ProgressView: UIView {
    var title: String = "" {
        didSet { titleLabel.text = title }
    }
    
    var subtitle: String = "" {
        didSet { subtitleLabel.text = subtitle }
    }
    
    var color: UIColor = .systemBlue {
        didSet {
            progressBar.tintColor = color
            if isDominant {
                backgroundColor = color.withAlphaComponent(0.1)
            }
        }
    }
    
    var progress: Double = 0 {
        didSet { progressBar.progress = Float(progress) }
    }
    
    var isDominant: Bool = false {
        didSet {
            if isDominant {
                backgroundColor = color.withAlphaComponent(0.1)
                layer.cornerRadius = 12
                layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowOpacity = 1
                layer.shadowRadius = 4
                titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
                subtitleLabel.font = .systemFont(ofSize: 18, weight: .heavy)
            } else {
                backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
                layer.cornerRadius = 12
                layer.shadowColor = nil
            }
        }
    }
    
    var isCompact: Bool = false {
        didSet { rebuildLayout() }
    }
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        layer.cornerRadius = 12
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        subtitleLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressViewStyle = .default
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
        addSubview(progressBar)
        
        rebuildLayout()
    }
    
    private func rebuildLayout() {
        NSLayoutConstraint.deactivate(layoutConstraints)
        
        if isCompact {
            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
            subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            layoutConstraints = [
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
                subtitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                subtitleLabel.widthAnchor.constraint(equalToConstant: 36),
                
                progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 160),
                progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                progressBar.centerYAnchor.constraint(equalTo: centerYAnchor),
                progressBar.heightAnchor.constraint(equalToConstant: 6),
                
                heightAnchor.constraint(equalToConstant: 40)
            ]
        } else {
            layoutConstraints = [
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                
                subtitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                
                progressBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                progressBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
                progressBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                progressBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
                progressBar.heightAnchor.constraint(equalToConstant: 8)
            ]
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
}

class ItemCell: UITableViewCell {
    private let containerView = UIView()
    private let priorityBadge = UILabel()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 容器视图
        containerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // 优先级标签
        priorityBadge.font = .systemFont(ofSize: 12, weight: .bold)
        priorityBadge.textColor = .white
        priorityBadge.textAlignment = .center
        priorityBadge.layer.cornerRadius = 6
        priorityBadge.layer.masksToBounds = true
        priorityBadge.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(priorityBadge)
        
        // 名称标签
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // 描述标签
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // 勾选图标
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // 优先级标签约束
            priorityBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            priorityBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            priorityBadge.widthAnchor.constraint(equalToConstant: 36),
            priorityBadge.heightAnchor.constraint(equalToConstant: 24),
            
            // 名称标签约束
            nameLabel.leadingAnchor.constraint(equalTo: priorityBadge.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            
            // 描述标签约束
            descriptionLabel.leadingAnchor.constraint(equalTo: priorityBadge.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // 勾选图标约束
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with item: TripItem, priority: Priority, isChecked: Bool) {
        priorityBadge.text = priority.title
        
        switch priority {
        case .p0:
            priorityBadge.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
        case .p1:
            priorityBadge.backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0)
        case .p2:
            priorityBadge.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        }
        
        nameLabel.attributedText = nil
        nameLabel.text = item.name
        nameLabel.textColor = isChecked ? UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0) : UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        
        if item.name == "Universal Power Adapter" {
            descriptionLabel.text = "Type A/B for Japan outlets"
        } else {
            descriptionLabel.text = ""
        }
        
        checkmarkImageView.isHidden = !isChecked
    }
}
