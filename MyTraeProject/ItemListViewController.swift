import UIKit

protocol ItemListViewControllerDelegate: AnyObject {
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem])
    func itemListViewController(_ controller: ItemListViewController, didToggleCheckForItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didDeleteItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem])
    func itemListViewController(_ controller: ItemListViewController, didChangePriorityForItem item: TripItem, to priority: Priority)
}

extension ItemListViewControllerDelegate {
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem]) {}
    func itemListViewController(_ controller: ItemListViewController, didToggleCheckForItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didDeleteItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem]) {}
    func itemListViewController(_ controller: ItemListViewController, didChangePriorityForItem item: TripItem, to priority: Priority) {}
}

enum ItemListMode {
    case embedded
    case confirmation
}

class ItemListViewController: UIViewController {

    weak var delegate: ItemListViewControllerDelegate?

    var mode: ItemListMode = .embedded
    var items: [TripItem] = [] {
        didSet { tableView.reloadData() }
    }
    var isEditingMode: Bool = false {
        didSet { tableView.reloadData() }
    }

    var checkedItemIDs: Set<UUID> = []
    var priorityOverrides: [UUID: Priority] = [:]

    let tableView = UITableView()
    private var dropdownOverlay: UIView?
    private var tableViewBottomConstraint: NSLayoutConstraint?

    private let confirmButton = UIButton(type: .system)
    private let themeBlue = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        if mode == .confirmation {
            setupConfirmationUI()
        }
    }

    private func setupTableView() {
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

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint!,
        ])
    }

    private func setupConfirmationUI() {
        title = "确认物品清单"
        navigationController?.setNavigationBarHidden(false, animated: false)
        view.backgroundColor = UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 1.0)

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        isEditingMode = true
        tableView.dragInteractionEnabled = true

        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 0.8)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.insertSubview(blurView, at: 0)

        confirmButton.backgroundColor = themeBlue
        confirmButton.layer.cornerRadius = 9999
        confirmButton.clipsToBounds = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
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

        let shadowLayer = CALayer()
        shadowLayer.shadowColor = themeBlue.withAlphaComponent(0.2).cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 10)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 15
        confirmButton.layer.insertSublayer(shadowLayer, at: 0)

        tableViewBottomConstraint?.isActive = false
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        tableViewBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
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

    func priority(for item: TripItem) -> Priority {
        return priorityOverrides[item.id] ?? item.defaultPriority
    }

    func isItemChecked(_ item: TripItem) -> Bool {
        return checkedItemIDs.contains(item.id)
    }

    @objc private func dismissSelf() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func confirmTapped() {
        delegate?.itemListViewController(self, didConfirmItems: items)
    }

    private func dismissDropdown() {
        dropdownOverlay?.removeFromSuperview()
        dropdownOverlay = nil
    }

    private func showPriorityDropdown(for item: TripItem, fromCell cell: ItemCell) {
        dismissDropdown()

        guard let window = view.window,
              let buttonFrame = cell.priorityButtonFrameInWindow() else { return }

        let currentPriority = priority(for: item)

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

        for p in Priority.allCases {
            let btn = UIButton(type: .system)
            btn.tag = p.rawValue
            btn.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
            btn.setTitle(p.title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 4
            btn.layer.masksToBounds = true

            switch p {
            case .p0:
                btn.backgroundColor = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
            case .p1:
                btn.backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0)
            case .p2:
                btn.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            }

            if p == currentPriority {
                btn.alpha = 0.4
            }

            btn.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                self.dismissDropdown()
                self.priorityOverrides[item.id] = p
                if self.mode == .embedded {
                    self.delegate?.itemListViewController(self, didChangePriorityForItem: item, to: p)
                }
                self.tableView.reloadData()
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

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ItemListViewController: UITableViewDataSource, UITableViewDelegate {

    private var groupedItems: [Category: [TripItem]] {
        return Dictionary(grouping: items) { $0.category }
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
        headerView.backgroundColor = mode == .confirmation
            ? UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 1.0)
            : .systemBackground

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
        let itemsInCategory = groupedItems[category]!
        let item = itemsInCategory[indexPath.row]
        let p = priority(for: item)
        let checked = isItemChecked(item)
        cell.configure(with: item, priority: p, isChecked: checked, isEditing: isEditingMode)
        cell.onNameChanged = { [weak self] newName in
            guard let self = self else { return }
            if let idx = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[idx].name = newName
                if self.mode == .embedded {
                    self.delegate?.itemListViewController(self, didUpdateItem: self.items[idx])
                }
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
        let itemsInCategory = groupedItems[category]!
        let item = itemsInCategory[indexPath.row]
        if checkedItemIDs.contains(item.id) {
            checkedItemIDs.remove(item.id)
        } else {
            checkedItemIDs.insert(item.id)
        }
        delegate?.itemListViewController(self, didToggleCheckForItem: item)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            let category = self.sortedCategories[indexPath.section]
            let itemsInCategory = self.groupedItems[category]!
            let item = itemsInCategory[indexPath.row]
            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                let removed = self.items.remove(at: index)
                if self.mode == .embedded {
                    self.delegate?.itemListViewController(self, didDeleteItem: removed)
                }
                self.tableView.reloadData()
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

        guard let globalSourceIndex = items.firstIndex(where: { $0.id == movedItem.id }) else { return }
        items.remove(at: globalSourceIndex)

        let destCategory = sortedCategories[destinationIndexPath.section]
        let destItems = items.filter { $0.category == destCategory }

        if destinationIndexPath.row >= destItems.count {
            if let lastItem = destItems.last,
               let insertAfter = items.firstIndex(where: { $0.id == lastItem.id }) {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                items.insert(itemToInsert, at: insertAfter + 1)
            } else {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                items.append(itemToInsert)
            }
        } else {
            let targetItem = destItems[destinationIndexPath.row]
            if let insertAt = items.firstIndex(where: { $0.id == targetItem.id }) {
                var itemToInsert = movedItem
                itemToInsert.category = destCategory
                items.insert(itemToInsert, at: insertAt)
            }
        }

        if mode == .embedded {
            delegate?.itemListViewController(self, didReorderItems: items)
        }
    }
}

// MARK: - UITableViewDragDelegate & UITableViewDropDelegate

extension ItemListViewController: UITableViewDragDelegate, UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard isEditingMode else { return [] }
        let touchPoint = session.location(in: tableView.cellForRow(at: indexPath)!)
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemCell,
              cell.isDragHandleHit(point: touchPoint) else {
            return []
        }
        let category = sortedCategories[indexPath.section]
        let itemsInCategory = groupedItems[category]!
        let item = itemsInCategory[indexPath.row]
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

                guard let globalSourceIndex = items.firstIndex(where: { $0.id == movedItem.id }) else { return }
                items.remove(at: globalSourceIndex)

                let destCategory = sortedCategories[destinationIndexPath.section]
                let destItems = items.filter { $0.category == destCategory }

                var itemToInsert = movedItem
                itemToInsert.category = destCategory

                if destinationIndexPath.row >= destItems.count {
                    if let lastItem = destItems.last,
                       let insertAfter = items.firstIndex(where: { $0.id == lastItem.id }) {
                        items.insert(itemToInsert, at: insertAfter + 1)
                    } else {
                        items.append(itemToInsert)
                    }
                } else {
                    let targetItem = destItems[destinationIndexPath.row]
                    if let insertAt = items.firstIndex(where: { $0.id == targetItem.id }) {
                        items.insert(itemToInsert, at: insertAt)
                    }
                }
            })

            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
        }

        tableView.reloadData()
        if mode == .embedded {
            delegate?.itemListViewController(self, didReorderItems: items)
        }
    }
}
