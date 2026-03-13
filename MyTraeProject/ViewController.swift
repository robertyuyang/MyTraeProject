//
//  ViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import UIKit

class ListViewController: UIViewController {
    
    private var lists: [TravelList] = []
    private let tableView = UITableView()
    
    // 辅助方法：计算某个清单的P0进度
    private func p0Progress(for list: TravelList) -> (checked: Int, total: Int, percentage: Double) {
        let p0Items = list.items.filter { $0.priority == .p0 }
        let checkedCount = p0Items.filter { $0.isChecked }.count
        let totalCount = p0Items.count
        let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
        return (checkedCount, totalCount, percentage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "旅行清单"
        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createNewList)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        lists = DataManager.shared.loadLists()
        tableView.reloadData()
    }
    
    private func saveData() {
        DataManager.shared.saveLists(lists)
    }
    
    @objc private func createNewList() {
        showNameAlert(title: "创建新清单", message: "请输入清单名称") { [weak self] name in
            guard let self = self, !name.isEmpty else { return }
            let newList = TravelList(name: name)
            self.lists.append(newList)
            self.saveData()
            self.tableView.reloadData()
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

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        let list = lists[indexPath.row]
        let progress = p0Progress(for: list)
        cell.configure(name: list.name, checkedCount: progress.checked, totalCount: progress.total, percentage: progress.percentage)
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

extension ListViewController: DetailViewControllerDelegate {
    func detailViewController(_ controller: DetailViewController, didUpdateList list: TravelList, at index: Int) {
        lists[index] = list
        saveData()
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// 自定义列表单元格
class ListCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let progressLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = .secondaryLabel
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressLabel)
        
        progressBar.tintColor = Priority.p0.color
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            progressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            progressBar.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 4),
            progressBar.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
    
    func configure(name: String, checkedCount: Int, totalCount: Int, percentage: Double) {
        nameLabel.text = name
        progressLabel.text = "P0: \(checkedCount)/\(totalCount)"
        progressBar.progress = Float(percentage)
    }
}

