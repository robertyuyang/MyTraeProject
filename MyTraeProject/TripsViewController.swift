//
//  TripsViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import UIKit

class TripsViewController: UIViewController {
    
    private var lists: [TravelList] = []
    private let tableView = UITableView()
    private let imageGenerator = AIImageGenerator()
    
    // 辅助方法：计算某个清单的P0进度
    private func p0Progress(for list: TravelList) -> (checked: Int, total: Int, percentage: Double) {
        let p0Items = list.items.filter { $0.priority == .p0 }
        let checkedCount = p0Items.filter { $0.isChecked }.count
        let totalCount = p0Items.count
        let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
        return (checkedCount, totalCount, percentage)
    }
    
    // 辅助方法：计算总进度
    private func totalProgress(for list: TravelList) -> (checked: Int, total: Int, percentage: Double) {
        let checkedCount = list.items.filter { $0.isChecked }.count
        let totalCount = list.items.count
        let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
        return (checkedCount, totalCount, percentage)
    }
    
    // 辅助方法：获取旅行状态
    private func getTripStatus(for list: TravelList) -> String {
        let p0Progress = self.p0Progress(for: list)
        let totalProgress = self.totalProgress(for: list)
        
        if p0Progress.percentage < 1.0 && totalProgress.percentage > 0 {
            return "URGENT"
        } else if totalProgress.percentage > 0 && totalProgress.percentage < 1.0 {
            return "PLANNING"
        } else {
            return "CONCEPT"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "My Trips"
        view.backgroundColor = UIColor.systemBackground
        
        // 设置导航栏
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        // 添加浮动加号按钮
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = UIColor.systemBlue
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 30
        addButton.clipsToBounds = true
        addButton.addTarget(self, action: #selector(createNewList), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 添加底部导航栏
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 这里可以设置底部导航栏，实际项目中可能需要在SceneDelegate中配置
        // 暂时添加一个简单的底部视图模拟
        let tabBarView = UIView()
        tabBarView.backgroundColor = .white
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        
        // 添加三个标签
        let tripsLabel = UILabel()
        tripsLabel.text = "Trips"
        tripsLabel.textAlignment = .center
        tripsLabel.font = .systemFont(ofSize: 12)
        tripsLabel.textColor = .systemBlue
        tripsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let templatesLabel = UILabel()
        templatesLabel.text = "Templates"
        templatesLabel.textAlignment = .center
        templatesLabel.font = .systemFont(ofSize: 12)
        templatesLabel.textColor = .secondaryLabel
        templatesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let settingsLabel = UILabel()
        settingsLabel.text = "Settings"
        settingsLabel.textAlignment = .center
        settingsLabel.font = .systemFont(ofSize: 12)
        settingsLabel.textColor = .secondaryLabel
        settingsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tabBarView.addSubview(tripsLabel)
        tabBarView.addSubview(templatesLabel)
        tabBarView.addSubview(settingsLabel)
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 60),
            
            tripsLabel.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            tripsLabel.trailingAnchor.constraint(equalTo: tabBarView.centerXAnchor),
            tripsLabel.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            tripsLabel.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            
            templatesLabel.leadingAnchor.constraint(equalTo: tabBarView.centerXAnchor),
            templatesLabel.trailingAnchor.constraint(equalTo: settingsLabel.leadingAnchor),
            templatesLabel.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            templatesLabel.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            
            settingsLabel.leadingAnchor.constraint(equalTo: templatesLabel.trailingAnchor),
            settingsLabel.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            settingsLabel.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            settingsLabel.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor)
        ])
        
        // 调整tableView的底部约束
        tableView.bottomAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
    }
    
    private func loadData() {
        lists = DataManager.shared.loadLists()
        tableView.reloadData()
        
        // 为没有图片的清单生成图片
        generateMissingImages()
    }
    
    private func generateMissingImages() {
        for (index, list) in lists.enumerated() {
            if list.imageUrl == nil {
                let prompt = "横版风景照片，与'\(list.name)'相关的旅行场景，高清，真实感"
                imageGenerator.generateImage(for: prompt) { [weak self] imageUrl, error in
                    guard let self = self, let imageUrl = imageUrl else { return }
                    
                    DispatchQueue.main.async {
                        // 更新列表中的图片URL
                        self.lists[index].imageUrl = imageUrl
                        self.saveData()
                        // 只更新当前这一行
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }
        }
    }
    
    private func saveData() {
        DataManager.shared.saveLists(lists)
    }
    
    @objc private func createNewList() {
        showNameAlert(title: "创建新清单", message: "请输入清单名称") { [weak self] name in
            guard let self = self, !name.isEmpty else { return }
            var newList = TravelList(name: name)
            
            // 生成与清单名称相关的图片
            let prompt = "横版风景照片，与'\(name)'相关的旅行场景，高清，真实感"
            self.imageGenerator.generateImage(for: prompt) { [weak self] imageUrl, error in
                DispatchQueue.main.async {
                    if let imageUrl = imageUrl {
                        newList.imageUrl = imageUrl
                    }
                    self?.lists.append(newList)
                    self?.saveData()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func showNameAlert(title: String, message: String, currentName: String? = nil, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentName
            textField.placeholder = "清单名称"
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            completion(alert.textFields?.first?.text ?? "")
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension TripsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        let list = lists[indexPath.row]
        let p0Progress = self.p0Progress(for: list)
        let totalProgress = self.totalProgress(for: list)
        let status = getTripStatus(for: list)
        cell.configure(name: list.name, status: status, p0Checked: p0Progress.checked, p0Total: p0Progress.total, p0Percentage: p0Progress.percentage, totalChecked: totalProgress.checked, totalTotal: totalProgress.total, totalPercentage: totalProgress.percentage, imageUrl: list.imageUrl)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = DetailViewController()
        detailVC.travelList = lists[indexPath.row]
        detailVC.index = indexPath.row
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300 // 调整高度以适应新的布局
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            self.lists.remove(at: indexPath.row)
            self.saveData()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        let renameAction = UIContextualAction(style: .normal, title: "重命名") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let list = self.lists[indexPath.row]
            self.showNameAlert(title: "重命名", message: "请输入新名称", currentName: list.name) { newName in
                guard !newName.isEmpty else { return }
                self.lists[indexPath.row].name = newName
                self.saveData()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            completion(true)
        }
        renameAction.backgroundColor = UIColor.systemBlue
        
        let copyAction = UIContextualAction(style: .normal, title: "复制") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let originalList = self.lists[indexPath.row]
            var copiedList = TravelList(name: originalList.name + " (副本)")
            copiedList.items = originalList.items
            self.lists.insert(copiedList, at: indexPath.row + 1)
            self.saveData()
            self.tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .automatic)
            completion(true)
        }
        copyAction.backgroundColor = UIColor.systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, renameAction, copyAction])
    }
}

extension TripsViewController: DetailViewControllerDelegate {
    func detailViewController(_ controller: DetailViewController, didUpdateList list: TravelList, at index: Int) {
        lists[index] = list
        saveData()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// 自定义列表单元格
class ListCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let p0ProgressLabel = UILabel()
    private let p0ProgressBar = UIProgressView(progressViewStyle: .default)
    private let totalProgressLabel = UILabel()
    private let totalProgressBar = UIProgressView(progressViewStyle: .default)
    private let listImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        // 状态标签
        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // 名称标签
        nameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // P0进度标签
        p0ProgressLabel.font = .systemFont(ofSize: 12)
        p0ProgressLabel.textColor = .secondaryLabel
        p0ProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(p0ProgressLabel)
        
        // P0进度条
        p0ProgressBar.tintColor = .systemRed
        p0ProgressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(p0ProgressBar)
        
        // 总进度标签
        totalProgressLabel.font = .systemFont(ofSize: 12)
        totalProgressLabel.textColor = .secondaryLabel
        totalProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalProgressLabel)
        
        // 总进度条
        totalProgressBar.tintColor = .systemGray
        totalProgressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalProgressBar)
        
        // 图片视图
        listImageView.contentMode = .scaleAspectFill
        listImageView.clipsToBounds = true
        listImageView.layer.cornerRadius = 12
        listImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(listImageView)
        
        NSLayoutConstraint.activate([
            // 状态标签
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // 名称标签
            nameLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // P0进度标签
            p0ProgressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            p0ProgressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // P0进度条
            p0ProgressBar.topAnchor.constraint(equalTo: p0ProgressLabel.bottomAnchor, constant: 4),
            p0ProgressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            p0ProgressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            p0ProgressBar.heightAnchor.constraint(equalToConstant: 6),
            
            // 总进度标签
            totalProgressLabel.topAnchor.constraint(equalTo: p0ProgressBar.bottomAnchor, constant: 8),
            totalProgressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // 总进度条
            totalProgressBar.topAnchor.constraint(equalTo: totalProgressLabel.bottomAnchor, constant: 4),
            totalProgressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            totalProgressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            totalProgressBar.heightAnchor.constraint(equalToConstant: 6),
            
            // 图片视图
            listImageView.topAnchor.constraint(equalTo: totalProgressBar.bottomAnchor, constant: 12),
            listImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            listImageView.heightAnchor.constraint(equalToConstant: 150),
            listImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(name: String, status: String, p0Checked: Int, p0Total: Int, p0Percentage: Double, totalChecked: Int, totalTotal: Int, totalPercentage: Double, imageUrl: String?) {
        nameLabel.text = name
        
        // 设置状态标签
        statusLabel.text = status
        switch status {
        case "URGENT":
            statusLabel.textColor = .systemRed
        case "PLANNING":
            statusLabel.textColor = .systemOrange
        case "CONCEPT":
            statusLabel.textColor = .systemGray
        default:
            statusLabel.textColor = .systemGray
        }
        
        // 设置进度信息
        p0ProgressLabel.text = "CRITICAL ESSENTIALS (P0)"
        p0ProgressBar.progress = Float(p0Percentage)
        
        totalProgressLabel.text = "TOTAL PREPARATION"
        totalProgressBar.progress = Float(totalPercentage)
        
        // 加载图片
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.listImageView.image = image
                    }
                }
            }.resume()
        } else {
            listImageView.image = nil
        }
    }
}

