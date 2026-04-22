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
    private var pendingCategoryItem: TripItem?
    
    private let stackView = UIStackView()
    private let p0ProgressView = ProgressView()
    private let p1ProgressView = ProgressView()
    private let p2ProgressView = ProgressView()

    private var itemListVC: ItemListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        setupItemListVC()
        updateProgress()
    }
    
    private func setupUI() {
        title = trip.name
        view.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
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
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupItemListVC() {
        itemListVC = ItemListViewController()
        itemListVC.mode = .embedded
        itemListVC.delegate = self
        itemListVC.items = trip.items
        itemListVC.checkedItemIDs = trip.checkedItemIDs
        itemListVC.priorityOverrides = trip.priorityOverrides

        addChild(itemListVC)
        itemListVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(itemListVC.view)
        itemListVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            itemListVC.view.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            itemListVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemListVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemListVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func syncFromItemListVC() {
        trip.items = itemListVC.items
        trip.checkedItemIDs = itemListVC.checkedItemIDs
        trip.priorityOverrides = itemListVC.priorityOverrides
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
        syncFromItemListVC()
        updateProgress()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }
    
    @objc private func addNewItem() {
        let addVC = AddItemViewController()
        addVC.delegate = self
        addVC.tripName = trip.name
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc private func toggleEditMode() {
        isEditingMode.toggle()
        
        if isEditingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(toggleEditMode))
            navigationItem.rightBarButtonItem?.tintColor = .systemBlue
            itemListVC.isEditingMode = true
        } else {
            let editButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(toggleEditMode))
            editButton.tintColor = .systemBlue
            navigationItem.rightBarButtonItem = editButton
            itemListVC.isEditingMode = false
            for cell in itemListVC.tableView.visibleCells {
                if let itemCell = cell as? ItemCell {
                    itemCell.endEditingName()
                }
            }
            view.endEditing(true)
            saveAndUpdate()
        }
    }
    
    @objc private func closeDetailView() {
        if isEditingMode {
            toggleEditMode()
        }
        navigationController?.popViewController(animated: true)
    }
}

extension DetailViewController: AddItemViewControllerDelegate {
    func addItemViewController(_ controller: AddItemViewController, didAddItems items: [TripItem]) {
        for item in items {
            trip.items.append(item)
        }
        itemListVC.items = trip.items
        saveAndUpdate()
    }
}

extension DetailViewController: ItemListViewControllerDelegate {
    func itemListViewController(_ controller: ItemListViewController, didToggleCheckForItem item: TripItem) {
        syncFromItemListVC()
        updateProgress()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }

    func itemListViewController(_ controller: ItemListViewController, didDeleteItem item: TripItem) {
        saveAndUpdate()
    }

    func itemListViewController(_ controller: ItemListViewController, didUpdateItem item: TripItem) {
        syncFromItemListVC()
    }

    func itemListViewController(_ controller: ItemListViewController, didReorderItems items: [TripItem]) {
        syncFromItemListVC()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }

    func itemListViewController(_ controller: ItemListViewController, didChangePriorityForItem item: TripItem, to priority: Priority) {
        syncFromItemListVC()
        updateProgress()
        delegate?.detailViewController(self, didUpdateTrip: trip, at: index)
    }

    func itemListViewController(_ controller: ItemListViewController, didRequestNewCategoryForItem item: TripItem) {
        presentCategoryPicker(for: item)
    }
    
    func itemListViewControllerDidRequestAddItem(_ controller: ItemListViewController) {
        addNewItem()
    }
}

extension DetailViewController: CategoryPickerViewControllerDelegate {
    func categoryPickerViewController(_ controller: CategoryPickerViewController, didSelectCategory category: Category) {
        controller.dismiss(animated: true)
        itemListVC.moveItemToCategory(pendingCategoryItem!, category: category)
        saveAndUpdate()
        pendingCategoryItem = nil
    }

    func categoryPickerViewControllerDidCancel(_ controller: CategoryPickerViewController) {
        controller.dismiss(animated: true)
        pendingCategoryItem = nil
    }

    private func presentCategoryPicker(for item: TripItem) {
        pendingCategoryItem = item
        let picker = CategoryPickerViewController()
        picker.delegate = self
        picker.selectedCategory = item.category
        present(picker, animated: true)
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

class ItemCell: UITableViewCell, UITextFieldDelegate {
    
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
    private var editingOverlay: UIView?
    private var nameLabelTapGesture: UITapGestureRecognizer?
    
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
        nameTextField.backgroundColor = .clear
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameTextField)
        
        nameLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(nameLabelTapped))
        nameLabel.addGestureRecognizer(tap)
        nameLabelTapGesture = tap
        tap.isEnabled = false
        
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
    
    @objc private func nameLabelTapped() {
        guard isInEditingMode else { return }
        beginEditingItemName()
    }
    
    private func beginEditingItemName() {
        nameTextField.text = nameLabel.text
        nameTextField.isHidden = false
        nameLabel.isHidden = true
        nameTextField.becomeFirstResponder()
        
        guard let window = window else { return }
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .clear
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(editingOverlayTapped))
        overlay.addGestureRecognizer(tap)
        window.addSubview(overlay)
        editingOverlay = overlay
    }
    
    @objc private func editingOverlayTapped() {
        commitEditingItemName()
    }
    
    private func commitEditingItemName() {
        guard !nameTextField.isHidden else { return }
        let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        nameTextField.isHidden = true
        nameLabel.isHidden = false
        nameTextField.resignFirstResponder()
        editingOverlay?.removeFromSuperview()
        editingOverlay = nil
        if !newName.isEmpty && newName != nameLabel.text {
            nameLabel.text = newName
            onNameChanged?(newName)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commitEditingItemName()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        commitEditingItemName()
    }
    
    func endEditingName() {
        commitEditingItemName()
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
        editingOverlay?.removeFromSuperview()
        editingOverlay = nil
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
            nameLabelTapGesture?.isEnabled = true
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
            nameLabelTapGesture?.isEnabled = false
            containerView.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0).cgColor
        }
        
        if item.name == "Universal Power Adapter" {
            descriptionLabel.text = "Type A/B for Japan outlets"
        } else {
            descriptionLabel.text = ""
        }
    }
}
