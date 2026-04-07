//  NaturalLanguageInputViewController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import UIKit

protocol NaturalLanguageInputDelegate: AnyObject {
    func naturalLanguageInput(_ controller: NaturalLanguageInputViewController, didAddItems items: [(name: String, priority: Priority)])
}

class NaturalLanguageInputViewController: UIViewController {
    
    weak var delegate: NaturalLanguageInputDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let exampleLabel = UILabel()
    private let textView = UITextView()
    private let parseButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    
    private var parsedItems: [(name: String, priority: Priority)] = [] {
        didSet {
            tableView.reloadData()
            addButton.isEnabled = !parsedItems.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        title = "智能添加物品"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        titleLabel.text = "用自然语言描述你想添加的物品"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        exampleLabel.text = "例如：\n“我必须带牙刷牙膏内裤，眼罩最好带上”"
        exampleLabel.font = .systemFont(ofSize: 14)
        exampleLabel.textColor = .secondaryLabel
        exampleLabel.numberOfLines = 0
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(exampleLabel)
        
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        
        parseButton.setTitle("解析", for: .normal)
        parseButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        parseButton.addTarget(self, action: #selector(parseText), for: .touchUpInside)
        parseButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(parseButton)
        
        tableView.register(ParsedItemCell.self, forCellReuseIdentifier: "ParsedItemCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        addButton.setTitle("添加全部", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addButton.addTarget(self, action: #selector(addItems), for: .touchUpInside)
        addButton.isEnabled = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            exampleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            exampleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            exampleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: exampleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 120),
            
            parseButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            parseButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: parseButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            addButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func parseText() {
        guard let text = textView.text, !text.isEmpty else {
            showError(message: "请输入要添加的物品")
            return
        }
        
        parsedItems = NaturalLanguageParser.shared.parse(text: text)
        
        if parsedItems.isEmpty {
            showError(message: "未能从您的输入中解析出任何物品，请重新输入。")
        }
    }
    
    @objc private func addItems() {
        guard !parsedItems.isEmpty else { return }
        delegate?.naturalLanguageInput(self, didAddItems: parsedItems)
        dismiss(animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

extension NaturalLanguageInputViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParsedItemCell", for: indexPath) as! ParsedItemCell
        let item = parsedItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class ParsedItemCell: UITableViewCell {
    private let priorityBadge = UILabel()
    private let nameLabel = UILabel()
    
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
        
        NSLayoutConstraint.activate([
            priorityBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priorityBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priorityBadge.widthAnchor.constraint(equalToConstant: 36),
            priorityBadge.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: priorityBadge.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with item: (name: String, priority: Priority)) {
        priorityBadge.text = item.priority.title
        priorityBadge.backgroundColor = item.priority.color
        nameLabel.text = item.name
    }
}