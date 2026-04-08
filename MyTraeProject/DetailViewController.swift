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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeDetailView)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewItem)
        )
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        p0ProgressView.title = "P0"
        p0ProgressView.color = Priority.p0.color
        stackView.addArrangedSubview(p0ProgressView)
        
        p1ProgressView.title = "P1"
        p1ProgressView.color = Priority.p1.color
        stackView.addArrangedSubview(p1ProgressView)
        
        p2ProgressView.title = "P2"
        p2ProgressView.color = Priority.p2.color
        stackView.addArrangedSubview(p2ProgressView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateProgress() {
        let items = trip.items
        
        for priority in Priority.allCases {
            let priorityItems = items.filter { $0.priority == priority }
            let checkedCount = priorityItems.filter { $0.isChecked }.count
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
        
        for priority in Priority.allCases {
            alert.addAction(UIAlertAction(title: priority.title, style: .default) { [weak self] _ in
                self?.showItemNameAlert(priority: priority)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showItemNameAlert(priority: Priority) {
        let alert = UIAlertController(title: "输入物品名称", message: "优先级: \(priority.title)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "物品名称"
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            guard let self = self, let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            let newItem = TripItem(name: name, priority: priority)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trip.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let item = trip.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        trip.items[indexPath.row].isChecked.toggle()
        saveAndUpdate()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            self.trip.items.remove(at: indexPath.row)
            self.saveAndUpdate()
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
        didSet { progressBar.tintColor = color }
    }
    
    var progress: Double = 0 {
        didSet { progressBar.progress = Float(progress) }
    }
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        stack.addArrangedSubview(titleLabel)
        
        stack.addArrangedSubview(UIView())
        
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(subtitleLabel)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            progressBar.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
}

class ItemCell: UITableViewCell {
    private let priorityBadge = UILabel()
    private let nameLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        priorityBadge.font = .systemFont(ofSize: 12, weight: .bold)
        priorityBadge.textColor = .white
        priorityBadge.textAlignment = .center
        priorityBadge.layer.cornerRadius = 4
        priorityBadge.layer.masksToBounds = true
        priorityBadge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priorityBadge)
        
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            priorityBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priorityBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priorityBadge.widthAnchor.constraint(equalToConstant: 36),
            priorityBadge.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: priorityBadge.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with item: TripItem) {
        priorityBadge.text = item.priority.title
        priorityBadge.backgroundColor = item.priority.color
        nameLabel.text = item.name
        nameLabel.textColor = item.isChecked ? .secondaryLabel : .label
        nameLabel.attributedText = item.isChecked ? NSAttributedString(
            string: item.name,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        ) : NSAttributedString(string: item.name)
        checkmarkImageView.isHidden = !item.isChecked
    }
}
