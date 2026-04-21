import UIKit

protocol ItemListViewControllerDelegate: AnyObject {
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem])
    func itemListViewController(_ controller: ItemListViewController, didToggleCheckForItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didDeleteItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem)
    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem])
    func itemListViewController(_ controller: ItemListViewController, didChangePriorityForItem item: TripItem, to priority: Priority)
    func itemListViewController(_ controller: ItemListViewController, didRequestNewCategoryForItem item: TripItem)
}

extension ItemListViewControllerDelegate {
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem]) {}
    func itemListViewController(_ controller: ItemListViewController, didToggleCheckForItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didDeleteItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem) {}
    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem]) {}
    func itemListViewController(_ controller: ItemListViewController, didChangePriorityForItem item: TripItem, to priority: Priority) {}
    func itemListViewController(_ controller: ItemListViewController, didRequestNewCategoryForItem item: TripItem) {}
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

    private let newCategoryDropZone = UIView()
    private let dropZoneLabel = UILabel()
    private let dropZoneIcon = UIImageView()
    private var dropZoneHeightConstraint: NSLayoutConstraint?
    private var pendingDropItem: TripItem?

    private let confirmButton = UIButton(type: .system)
    private let themeBlue = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDropZone()
        setupTableView()
        if mode == .confirmation {
            setupConfirmationUI()
        }
    }

    private func setupDropZone() {
        newCategoryDropZone.backgroundColor = UIColor(red: 240/255, green: 245/255, blue: 255/255, alpha: 1.0)
        newCategoryDropZone.layer.cornerRadius = 16
        newCategoryDropZone.layer.borderWidth = 2
        newCategoryDropZone.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        newCategoryDropZone.translatesAutoresizingMaskIntoConstraints = false
        newCategoryDropZone.isHidden = true
        newCategoryDropZone.alpha = 0
        view.addSubview(newCategoryDropZone)

        dropZoneIcon.image = UIImage(systemName: "plus.rectangle.on.folder.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
        dropZoneIcon.tintColor = UIColor.systemBlue.withAlphaComponent(0.6)
        dropZoneIcon.contentMode = .scaleAspectFit
        dropZoneIcon.translatesAutoresizingMaskIntoConstraints = false
        newCategoryDropZone.addSubview(dropZoneIcon)

        dropZoneLabel.text = "拖到此处创建新分类"
        dropZoneLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dropZoneLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.7)
        dropZoneLabel.textAlignment = .center
        dropZoneLabel.translatesAutoresizingMaskIntoConstraints = false
        newCategoryDropZone.addSubview(dropZoneLabel)

        let dropInteraction = UIDropInteraction(delegate: self)
        newCategoryDropZone.addInteraction(dropInteraction)

        dropZoneHeightConstraint = newCategoryDropZone.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([
            newCategoryDropZone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryDropZone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryDropZone.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            dropZoneHeightConstraint!,

            dropZoneIcon.centerXAnchor.constraint(equalTo: newCategoryDropZone.centerXAnchor),
            dropZoneIcon.topAnchor.constraint(equalTo: newCategoryDropZone.topAnchor, constant: 14),

            dropZoneLabel.topAnchor.constraint(equalTo: dropZoneIcon.bottomAnchor, constant: 6),
            dropZoneLabel.centerXAnchor.constraint(equalTo: newCategoryDropZone.centerXAnchor),
        ])
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
        tableView.backgroundColor = .white
        view.addSubview(tableView)

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewBottomConstraint!,
        ])
    }

    func showDropZone() {
        // 延迟执行避免与 table view 拖动冲突
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.newCategoryDropZone.isHidden = false
            self.tableViewBottomConstraint?.constant = -88
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.newCategoryDropZone.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }

    func hideDropZone() {
        UIView.animate(withDuration: 0.25, animations: {
            self.newCategoryDropZone.alpha = 0
            self.tableViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            self.newCategoryDropZone.isHidden = true
            self.resetDropZoneAppearance()
        }
    }

    private func highlightDropZone() {
        UIView.animate(withDuration: 0.2) {
            self.newCategoryDropZone.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            self.newCategoryDropZone.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
            self.newCategoryDropZone.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            self.dropZoneIcon.tintColor = UIColor.systemBlue
            self.dropZoneLabel.textColor = UIColor.systemBlue
        }
    }

    private func resetDropZoneAppearance() {
        UIView.animate(withDuration: 0.2) {
            self.newCategoryDropZone.backgroundColor = UIColor(red: 240/255, green: 245/255, blue: 255/255, alpha: 1.0)
            self.newCategoryDropZone.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
            self.newCategoryDropZone.transform = .identity
            self.dropZoneIcon.tintColor = UIColor.systemBlue.withAlphaComponent(0.6)
            self.dropZoneLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.7)
        }
    }

    func moveItemToCategory(_ item: TripItem, category: Category) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        let oldCategory = items[idx].category
        let oldGroupedItems = groupedItems
        let oldSortedCategories = sortedCategories
        
        items[idx].category = category
        
        if mode == .embedded {
            delegate?.itemListViewController(self, didReorderItems: items)
        }
        
        // 直接 reloadData 避免 performBatchUpdates 的 section 数量不一致问题
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
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
            : .white

        let category = sortedCategories[section]
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: BuiltInCategory.icon(for: category))
        iconView.tintColor = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = category
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
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

    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        showDropZone()
    }

    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        hideDropZone()
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

// MARK: - UIDropInteractionDelegate (New Category Drop Zone)

extension ItemListViewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.localDragSession != nil
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        highlightDropZone()
        return UIDropProposal(operation: .move)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        resetDropZoneAppearance()
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let dragItem = session.items.first,
              let item = dragItem.localObject as? TripItem else { return }
        pendingDropItem = item
        delegate?.itemListViewController(self, didRequestNewCategoryForItem: item)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        resetDropZoneAppearance()
    }
}

// MARK: - CategoryPickerViewController (复用 AddItemViewController 的分类选择UI)

protocol CategoryPickerViewControllerDelegate: AnyObject {
    func categoryPickerViewController(_ controller: CategoryPickerViewController, didSelectCategory category: Category)
    func categoryPickerViewControllerDidCancel(_ controller: CategoryPickerViewController)
}

class CategoryPickerViewController: UIViewController {

    weak var delegate: CategoryPickerViewControllerDelegate?
    var selectedCategory: Category = BuiltInCategory.other

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let categoryGrid = UIView()
    private var categoryButtons: [UIButton] = []

    private let themeBlue = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)
    private let textPrimary = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
    private let textMuted = UIColor(red: 113/255, green: 119/255, blue: 134/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCategoryGrid()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.systemGray3
        closeButton.contentVerticalAlignment = .fill
        closeButton.contentHorizontalAlignment = .fill
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)

        titleLabel.text = "选择分类"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        subtitleLabel.text = "将物品拖到此处可选择新分类"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        categoryGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryGrid)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            categoryGrid.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            categoryGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            categoryGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func setupCategoryGrid() {
        let categories: [(Category, String)] = [
            (BuiltInCategory.electronics, "ELECTRONICS"),
            (BuiltInCategory.documentsAndIDs, "DOCUMENTS"),
            (BuiltInCategory.clothing, "CLOTHING"),
            (BuiltInCategory.toiletries, "TOILETRIES"),
            (BuiltInCategory.photography, "PHOTO"),
            (BuiltInCategory.footwear, "FOOTWEAR"),
            (BuiltInCategory.health, "HEALTH"),
            (BuiltInCategory.outdoor, "OUTDOOR"),
            (BuiltInCategory.foodAndDrinks, "FOOD"),
            (BuiltInCategory.accessories, "ACCESSORIES"),
            (BuiltInCategory.other, "OTHER"),
        ]

        let columns = 4
        let spacing: CGFloat = 8
        var lastRowBottom: NSLayoutAnchor<NSLayoutYAxisAnchor> = categoryGrid.topAnchor
        var rowButtons: [UIButton] = []
        var firstRowFirstBtn: UIButton?

        for (index, (category, displayName)) in categories.enumerated() {
            let col = index % columns
            let btn = createCategoryButton(category: category, displayName: displayName, icon: BuiltInCategory.icon(for: category))
            categoryGrid.addSubview(btn)
            categoryButtons.append(btn)

            if col == 0 {
                btn.leadingAnchor.constraint(equalTo: categoryGrid.leadingAnchor).isActive = true
                btn.topAnchor.constraint(equalTo: lastRowBottom, constant: index == 0 ? 0 : spacing).isActive = true
                rowButtons = [btn]
                if firstRowFirstBtn == nil { firstRowFirstBtn = btn }
            } else {
                btn.leadingAnchor.constraint(equalTo: rowButtons.last!.trailingAnchor, constant: spacing).isActive = true
                btn.topAnchor.constraint(equalTo: rowButtons[0].topAnchor).isActive = true
                rowButtons.append(btn)
            }

            if let ref = firstRowFirstBtn, btn !== ref {
                btn.widthAnchor.constraint(equalTo: ref.widthAnchor).isActive = true
                btn.heightAnchor.constraint(equalTo: ref.heightAnchor).isActive = true
            }

            if col == columns - 1 {
                btn.trailingAnchor.constraint(equalTo: categoryGrid.trailingAnchor).isActive = true
                lastRowBottom = rowButtons[0].bottomAnchor
            }

            if index == categories.count - 1 {
                rowButtons[0].bottomAnchor.constraint(equalTo: categoryGrid.bottomAnchor).isActive = true
            }
        }

        if let firstBtn = firstRowFirstBtn {
            firstBtn.heightAnchor.constraint(equalToConstant: 64).isActive = true
        }

        updateCategorySelection()
    }

    private func createCategoryButton(category: Category, displayName: String, icon: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = category
        btn.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tag = 20
        btn.addSubview(iconView)

        let label = UILabel()
        label.text = displayName
        label.font = .systemFont(ofSize: 7, weight: .bold)
        label.textAlignment = .center
        label.tag = 21
        label.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: btn.centerYAnchor, constant: -6),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            label.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 3),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: btn.leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(lessThanOrEqualTo: btn.trailingAnchor, constant: -2),
        ])

        return btn
    }

    private func updateCategorySelection() {
        for btn in categoryButtons {
            let category = btn.accessibilityIdentifier ?? ""
            let isSelected = category == selectedCategory
            let iconView = btn.viewWithTag(20) as? UIImageView
            let label = btn.viewWithTag(21) as? UILabel

            if isSelected {
                btn.backgroundColor = themeBlue
                iconView?.tintColor = .white
                label?.textColor = .white
            } else {
                btn.backgroundColor = .white
                iconView?.tintColor = textMuted
                label?.textColor = textMuted
            }
        }
    }

    @objc private func closeTapped() {
        delegate?.categoryPickerViewControllerDidCancel(self)
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let category = sender.accessibilityIdentifier else { return }
        selectedCategory = category
        updateCategorySelection()
        delegate?.categoryPickerViewController(self, didSelectCategory: category)
    }
}
