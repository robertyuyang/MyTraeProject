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
    
    private var isEditingMode = false
    
    private let stackView = UIStackView()
    private let p0ProgressView = ProgressView()
    private let p1ProgressView = ProgressView()
    private let p2ProgressView = ProgressView()
    private let tableView = UITableView()

    private let floatingActionButton = UIButton(type: .system)
    private var dropdownOverlay: UIView?
    
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
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(toggleEditMode))
        editButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = editButton
        
        stackView.axis = .vertical
        stackView.spacing = 6
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
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // 设置浮动操作按钮
        floatingActionButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingActionButton.tintColor = .white
        floatingActionButton.backgroundColor = .systemBlue
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
    
    @objc private func toggleEditMode() {
        isEditingMode.toggle()
        dismissDropdown()
        
        if isEditingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(toggleEditMode))
            navigationItem.rightBarButtonItem?.tintColor = .systemBlue
            floatingActionButton.isHidden = true
            tableView.dragInteractionEnabled = true
        } else {
            let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(toggleEditMode))
            editButton.tintColor = .systemBlue
            navigationItem.rightBarButtonItem = editButton
            floatingActionButton.isHidden = false
            tableView.dragInteractionEnabled = false
            view.endEditing(true)
            saveAndUpdate()
        }
        tableView.reloadData()
    }
    
    @objc private func closeDetailView() {
        if isEditingMode {
            toggleEditMode()
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func dismissDropdown() {
        dropdownOverlay?.removeFromSuperview()
        dropdownOverlay = nil
    }
    
    private func showPriorityDropdown(for item: TripItem, fromCell cell: ItemCell) {
        dismissDropdown()
        
        guard let window = view.window,
              let buttonFrame = cell.priorityButtonFrameInWindow() else { return }
        
        let currentPriority = trip.priority(for: item)
        
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropdownOverlayTapped))
        overlay.addGestureRecognizer(tapGesture)
        window.addSubview(overlay)
        dropdownOverlay = overlay
        
        let menuWidth: CGFloat = 40
        let itemHeight: CGFloat = 30
        let padding: CGFloat = 4
        let menuHeight: CGFloat = CGFloat(Priority.allCases.count) * itemHeight + padding * 2
        
        let menuContainer = UIView()
        menuContainer.backgroundColor = .white
        menuContainer.layer.cornerRadius = 8
        menuContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        menuContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuContainer.layer.shadowOpacity = 1
        menuContainer.layer.shadowRadius = 8
        menuContainer.layer.borderWidth = 0.5
        menuContainer.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).cgColor
        
        let menuX = buttonFrame.midX - menuWidth / 2
        let menuY = buttonFrame.maxY + 4
        menuContainer.frame = CGRect(x: menuX, y: menuY, width: menuWidth, height: menuHeight)
        overlay.addSubview(menuContainer)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.frame = CGRect(x: 0, y: padding, width: menuWidth, height: menuHeight - padding * 2)
        menuContainer.addSubview(stack)
        
        for priority in Priority.allCases {
            let btn = UIButton(type: .system)
            btn.tag = priority.rawValue
            btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
            btn.setTitle(priority.title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 4
            btn.layer.masksToBounds = true
            
            switch priority {
            case .p0:
                btn.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
            case .p1:
                btn.backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0)
            case .p2:
                btn.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            }
            
            if priority == currentPriority {
                btn.alpha = 0.4
            }
            
            btn.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                self.dismissDropdown()
                self.trip.setPriority(priority, for: item)
                self.saveAndUpdate()
            }, for: .touchUpInside)
            
            let heightConstraint = btn.heightAnchor.constraint(equalToConstant: itemHeight - 2)
            heightConstraint.isActive = true
            stack.addArrangedSubview(btn)
        }
        
        menuContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: 0, y: -8))
        menuContainer.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            menuContainer.transform = .identity
            menuContainer.alpha = 1
        }
    }
    
    @objc private func dropdownOverlayTapped() {
        dismissDropdown()
    }
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let category = sortedCategories[indexPath.section]
        let items = groupedItems[category]!
        let item = items[indexPath.row]
        cell.configure(with: item, priority: trip.priority(for: item), isChecked: trip.isItemChecked(item), isEditing: isEditingMode)
        cell.onNameChanged = { [weak self] newName in
            guard let self = self else { return }
            if let idx = self.trip.items.firstIndex(where: { $0.id == item.id }) {
                self.trip.items[idx].name = newName
            }
        }
        cell.onPriorityTapped = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.showPriorityDropdown(for: item, fromCell: cell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isEditingMode { return }
        let category = sortedCategories[indexPath.section]
        let items = groupedItems[category]!
        let item = items[indexPath.row]
        trip.toggleItemChecked(item)
        saveAndUpdate()
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let category = self.sortedCategories[indexPath.section]
            let items = self.groupedItems[category]!
            let item = items[indexPath.row]
            if let index = self.trip.items.firstIndex(where: { $0.id == item.id }) {
                self.trip.items.remove(at: index)
                self.saveAndUpdate()
            }
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1.0)
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return isEditingMode
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceCategory = sortedCategories[sourceIndexPath.section]
        let sourceItems = groupedItems[sourceCategory]!
        let movedItem = sourceItems[sourceIndexPath.row]
        
        guard let globalSourceIndex = trip.items.firstIndex(where: { $0.id == movedItem.id }) else { return }
        trip.items.remove(at: globalSourceIndex)
        
        let destCategory = sortedCategories[destinationIndexPath.section]
        let destItems = trip.items.filter { $0.category == destCategory }
        
        if destinationIndexPath.row >= destItems.count {
            if let lastItem = destItems.last,
               let insertAfter = trip.items.firstIndex(where: { $0.id == lastItem.id }) {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                trip.items.insert(itemToInsert, at: insertAfter + 1)
            } else {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                trip.items.append(itemToInsert)
            }
        } else {
            let targetItem = destItems[destinationIndexPath.row]
            if let insertAt = trip.items.firstIndex(where: { $0.id == targetItem.id }) {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                trip.items.insert(itemToInsert, at: insertAt)
            }
        }
        
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }
}

extension DetailViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard isEditingMode else { return [] }
        let touchPoint = session.location(in: tableView.cellForRow(at: indexPath)!)
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemCell,
              cell.isDragHandleHit(point: touchPoint) else {
            return []
        }
        let category = sortedCategories[indexPath.section]
        let items = groupedItems[category]!
        let item = items[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            guard let sourceIndexPath = item.sourceIndexPath else { continue }
            
            tableView.performBatchUpdates({
                let sourceCategory = sortedCategories[sourceIndexPath.section]
                let sourceItems = groupedItems[sourceCategory]!
                let movedItem = sourceItems[sourceIndexPath.row]
                
                guard let globalSourceIndex = trip.items.firstIndex(where: { $0.id == movedItem.id }) else { return }
                trip.items.remove(at: globalSourceIndex)
                
                let destCategory = sortedCategories[destinationIndexPath.section]
                let destItems = trip.items.filter { $0.category == destCategory }
                
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                
                if destinationIndexPath.row >= destItems.count {
                    if let lastItem = destItems.last,
                       let insertAfter = trip.items.firstIndex(where: { $0.id == lastItem.id }) {
                        trip.items.insert(itemToInsert, at: insertAfter + 1)
                    } else {
                        trip.items.append(itemToInsert)
                    }
                } else {
                    let targetItem = destItems[destinationIndexPath.row]
                    if let insertAt = trip.items.firstIndex(where: { $0.id == targetItem.id }) {
                        trip.items.insert(itemToInsert, at: insertAt)
                    }
                }
            })
            
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
        }
        
        updateProgress()
        tableView.reloadData()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
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
    
    var onNameChanged: ((String) -> Void)?
    var onPriorityTapped: (() -> Void)?
    var onDragHandleLongPress: (() -> Void)?
    
    private let containerView = UIView()
    private let dragHandleImageView = UIImageView()
    private let priorityButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    private let descriptionLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    private let reorderImageView = UIImageView()
    
    private var isInEditingMode = false
    
    private var normalConstraints: [NSLayoutConstraint] = []
    private var editingConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .white
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 3
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        dragHandleImageView.image = UIImage(systemName: "line.3.horizontal")
        dragHandleImageView.tintColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        dragHandleImageView.contentMode = .scaleAspectFit
        dragHandleImageView.isHidden = true
        dragHandleImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dragHandleImageView)
        
        priorityButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        priorityButton.layer.cornerRadius = 8
        priorityButton.layer.borderWidth = 1
        priorityButton.layer.masksToBounds = true
        priorityButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 6)
        priorityButton.translatesAutoresizingMaskIntoConstraints = false
        priorityButton.addTarget(self, action: #selector(priorityBadgeTapped), for: .touchUpInside)
        containerView.addSubview(priorityButton)
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        nameTextField.font = .systemFont(ofSize: 16, weight: .medium)
        nameTextField.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        nameTextField.borderStyle = .none
        nameTextField.isHidden = true
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        containerView.addSubview(nameTextField)
        
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(checkmarkImageView)
        
        reorderImageView.image = UIImage(systemName: "line.3.horizontal")
        reorderImageView.tintColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        reorderImageView.contentMode = .scaleAspectFit
        reorderImageView.isHidden = true
        reorderImageView.isUserInteractionEnabled = true
        reorderImageView.translatesAutoresizingMaskIntoConstraints = false
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        reorderImageView.addGestureRecognizer(longPress)
        containerView.addSubview(reorderImageView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            
            dragHandleImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dragHandleImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dragHandleImageView.widthAnchor.constraint(equalToConstant: 20),
            dragHandleImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        normalConstraints = [
            priorityButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            priorityButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            priorityButton.widthAnchor.constraint(equalToConstant: 36),
            priorityButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: priorityButton.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: priorityButton.trailingAnchor, constant: 10),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
        ]
        
        let textLeading: CGFloat = 12 + 36 + 10
        
        editingConstraints = [
            priorityButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            priorityButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            priorityButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: textLeading),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: reorderImageView.leadingAnchor, constant: -8),
            
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: textLeading),
            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: reorderImageView.leadingAnchor, constant: -8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: textLeading),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            descriptionLabel.trailingAnchor.constraint(equalTo: reorderImageView.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            reorderImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            reorderImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            reorderImageView.widthAnchor.constraint(equalToConstant: 28),
            reorderImageView.heightAnchor.constraint(equalToConstant: 28),
        ]
        
        NSLayoutConstraint.activate(normalConstraints)
    }
    
    @objc private func nameTextFieldChanged() {
        if let text = nameTextField.text {
            onNameChanged?(text)
        }
    }
    
    @objc private func priorityBadgeTapped() {
        onPriorityTapped?()
    }
    
    @objc private func handleReorderLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onDragHandleLongPress?()
        }
    }
    
    func isDragHandleHit(point: CGPoint) -> Bool {
        guard !reorderImageView.isHidden else { return false }
        let handleFrame = reorderImageView.convert(reorderImageView.bounds, to: self)
        let hitArea = handleFrame.insetBy(dx: -20, dy: -20)
        return hitArea.contains(point)
    }
    
    func priorityButtonFrameInWindow() -> CGRect? {
        return priorityButton.superview?.convert(priorityButton.frame, to: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onNameChanged = nil
        onPriorityTapped = nil
        onDragHandleLongPress = nil
    }
    
    private func applyPriorityStyle(_ priority: Priority, isEditing: Bool) {
        let title = priority.title
        
        priorityButton.setTitle(title, for: .normal)
        priorityButton.setTitleColor(.white, for: .normal)
        priorityButton.layer.borderWidth = 0
        priorityButton.semanticContentAttribute = .forceRightToLeft
        
        switch priority {
        case .p0:
            priorityButton.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
        case .p1:
            priorityButton.backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0)
        case .p2:
            priorityButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        }
        
        if isEditing {
            let config = UIImage.SymbolConfiguration(pointSize: 7, weight: .bold)
            let chevron = UIImage(systemName: "chevron.down", withConfiguration: config)
            priorityButton.setImage(chevron, for: .normal)
            priorityButton.tintColor = .white
        } else {
            priorityButton.setImage(nil, for: .normal)
        }
    }
    
    func configure(with item: TripItem, priority: Priority, isChecked: Bool, isEditing: Bool = false) {
        isInEditingMode = isEditing
        applyPriorityStyle(priority, isEditing: isEditing)
        
        if isEditing {
            NSLayoutConstraint.deactivate(normalConstraints)
            NSLayoutConstraint.activate(editingConstraints)
            
            dragHandleImageView.isHidden = true
            reorderImageView.isHidden = false
            checkmarkImageView.isHidden = true
            nameLabel.isHidden = false
            nameLabel.text = item.name
            nameLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            nameTextField.isHidden = true
            descriptionLabel.isHidden = false
            priorityButton.isHidden = false
            priorityButton.isUserInteractionEnabled = true
            containerView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor
        } else {
            NSLayoutConstraint.deactivate(editingConstraints)
            NSLayoutConstraint.activate(normalConstraints)
            
            dragHandleImageView.isHidden = true
            reorderImageView.isHidden = true
            nameLabel.isHidden = false
            nameTextField.isHidden = true
            nameLabel.attributedText = nil
            nameLabel.text = item.name
            nameLabel.textColor = isChecked ? UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0) : UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            checkmarkImageView.isHidden = !isChecked
            descriptionLabel.isHidden = false
            priorityButton.isHidden = false
            priorityButton.isUserInteractionEnabled = false
            containerView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor
        }
        
        if item.name == "Universal Power Adapter" {
            descriptionLabel.text = "Type A/B for Japan outlets"
        } else {
            descriptionLabel.text = ""
        }
    }
}
