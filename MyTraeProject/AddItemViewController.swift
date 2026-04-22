import UIKit

protocol AddItemViewControllerDelegate: AnyObject {
    func addItemViewController(_ controller: AddItemViewController, didAddItems items: [TripItem])
}

class AddItemViewController: UIViewController {

    weak var delegate: AddItemViewControllerDelegate?
    var tripName: String = ""

    private enum Tab: Int {
        case singleEntry = 0
        case aiBulkAdd = 1
    }

    private var currentTab: Tab = .singleEntry

    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let toggleContainer = UIView()
    private let singleEntryButton = UIButton(type: .system)
    private let aiBulkAddButton = UIButton(type: .system)

    private let singleEntryView = UIView()
    private let aiBulkAddView = UIView()

    private let nameTextField = UITextField()
    private var selectedPriority: Priority = .p1
    private var priorityButtons: [UIButton] = []
    private var selectedCategory: Category = BuiltInCategory.electronics
    private var categoryButtons: [UIButton] = []

    private let aiTitleLabel = UILabel()
    private let aiDescriptionLabel = UILabel()
    private let aiTextView = UITextView()
    private let aiProcessingLabel = UILabel()
    private let pasteButton = UIButton(type: .system)


    private let bottomBar = UIView()
    private let actionButton = UIButton(type: .system)

    private let categorizingService = LLMCategorizingService()
    private var loadingOverlay: UIView?

    private let themeBlue = UIColor(red: 0/255, green: 88/255, blue: 188/255, alpha: 1.0)
    private let backgroundMain = UIColor(red: 250/255, green: 249/255, blue: 254/255, alpha: 1.0)
    private let textPrimary = UIColor(red: 26/255, green: 27/255, blue: 31/255, alpha: 1.0)
    private let textSecondary = UIColor(red: 65/255, green: 71/255, blue: 85/255, alpha: 1.0)
    private let textMuted = UIColor(red: 113/255, green: 119/255, blue: 134/255, alpha: 1.0)
    private let surfaceLight = UIColor(red: 244/255, green: 243/255, blue: 248/255, alpha: 1.0)


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = backgroundMain
        setupHeader()
        setupScrollView()
        setupToggle()
        setupSingleEntryView()
        setupAIBulkAddView()
        setupBottomBar()
        switchToTab(.singleEntry)
        setupKeyboardDismiss()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Header

    private func setupHeader() {
        headerView.backgroundColor = backgroundMain
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        backButton.tintColor = textPrimary
        backButton.backgroundColor = .clear
        backButton.layer.cornerRadius = 20
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        headerView.addSubview(backButton)

        headerTitleLabel.text = "添加物品"
        headerTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        headerTitleLabel.textColor = .black
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerTitleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
        ])
    }

    // MARK: - ScrollView

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    // MARK: - Toggle

    private func setupToggle() {
        toggleContainer.backgroundColor = surfaceLight
        toggleContainer.layer.cornerRadius = 12
        toggleContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toggleContainer)

        singleEntryButton.setTitle("单个添加", for: .normal)
        singleEntryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        singleEntryButton.layer.cornerRadius = 8
        singleEntryButton.translatesAutoresizingMaskIntoConstraints = false
        singleEntryButton.addTarget(self, action: #selector(singleEntryTapped), for: .touchUpInside)
        toggleContainer.addSubview(singleEntryButton)

        aiBulkAddButton.setTitle("AI 批量添加", for: .normal)
        aiBulkAddButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        aiBulkAddButton.layer.cornerRadius = 8
        aiBulkAddButton.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddButton.addTarget(self, action: #selector(aiBulkAddTapped), for: .touchUpInside)
        toggleContainer.addSubview(aiBulkAddButton)

        NSLayoutConstraint.activate([
            toggleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            toggleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            toggleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            toggleContainer.heightAnchor.constraint(equalToConstant: 48),

            singleEntryButton.leadingAnchor.constraint(equalTo: toggleContainer.leadingAnchor, constant: 6),
            singleEntryButton.topAnchor.constraint(equalTo: toggleContainer.topAnchor, constant: 6),
            singleEntryButton.bottomAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: -6),

            aiBulkAddButton.leadingAnchor.constraint(equalTo: singleEntryButton.trailingAnchor, constant: 0),
            aiBulkAddButton.topAnchor.constraint(equalTo: toggleContainer.topAnchor, constant: 6),
            aiBulkAddButton.bottomAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: -6),
            aiBulkAddButton.trailingAnchor.constraint(equalTo: toggleContainer.trailingAnchor, constant: -6),

            singleEntryButton.widthAnchor.constraint(equalTo: aiBulkAddButton.widthAnchor),
        ])
    }

    // MARK: - Single Entry View

    private func setupSingleEntryView() {
        singleEntryView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(singleEntryView)

        NSLayoutConstraint.activate([
            singleEntryView.topAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: 40),
            singleEntryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            singleEntryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
        ])

        let nameSection = createSectionLabel("物品名称")
        singleEntryView.addSubview(nameSection)

        let nameBackground = UIView()
        nameBackground.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 249/255, alpha: 1.0)
        nameBackground.layer.cornerRadius = 12
        nameBackground.translatesAutoresizingMaskIntoConstraints = false
        singleEntryView.addSubview(nameBackground)

        nameTextField.placeholder = "例如：徕卡 M11 相机"
        nameTextField.font = .systemFont(ofSize: 14)
        nameTextField.textColor = textPrimary
        nameTextField.backgroundColor = .clear
        nameTextField.borderStyle = .none
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameBackground.addSubview(nameTextField)

        let prioritySection = createSectionLabel("优先级")
        singleEntryView.addSubview(prioritySection)

        let priorityStack = UIStackView()
        priorityStack.axis = .horizontal
        priorityStack.spacing = 12
        priorityStack.distribution = .fillEqually
        priorityStack.translatesAutoresizingMaskIntoConstraints = false
        singleEntryView.addSubview(priorityStack)

        let priorityData: [(Priority, String)] = [(.p0, "URGENT"), (.p1, "IMPORTANT"), (.p2, "NORMAL")]
        for (priority, subtitle) in priorityData {
            let btn = createPriorityChip(priority: priority, subtitle: subtitle)
            priorityStack.addArrangedSubview(btn)
            priorityButtons.append(btn)
        }

        let categorySection = createSectionLabel("分类")
        singleEntryView.addSubview(categorySection)

        let categoryGrid = createCategoryGrid()
        singleEntryView.addSubview(categoryGrid)

        NSLayoutConstraint.activate([
            nameSection.topAnchor.constraint(equalTo: singleEntryView.topAnchor),
            nameSection.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            nameSection.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),

            nameBackground.topAnchor.constraint(equalTo: nameSection.bottomAnchor, constant: 12),
            nameBackground.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            nameBackground.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),
            nameBackground.heightAnchor.constraint(equalToConstant: 44),

            nameTextField.leadingAnchor.constraint(equalTo: nameBackground.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: nameBackground.trailingAnchor, constant: -16),
            nameTextField.centerYAnchor.constraint(equalTo: nameBackground.centerYAnchor),

            prioritySection.topAnchor.constraint(equalTo: nameBackground.bottomAnchor, constant: 32),
            prioritySection.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            prioritySection.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),

            priorityStack.topAnchor.constraint(equalTo: prioritySection.bottomAnchor, constant: 12),
            priorityStack.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            priorityStack.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),
            priorityStack.heightAnchor.constraint(equalToConstant: 56),

            categorySection.topAnchor.constraint(equalTo: priorityStack.bottomAnchor, constant: 32),
            categorySection.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            categorySection.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),

            categoryGrid.topAnchor.constraint(equalTo: categorySection.bottomAnchor, constant: 12),
            categoryGrid.leadingAnchor.constraint(equalTo: singleEntryView.leadingAnchor),
            categoryGrid.trailingAnchor.constraint(equalTo: singleEntryView.trailingAnchor),
            categoryGrid.bottomAnchor.constraint(equalTo: singleEntryView.bottomAnchor),
        ])

        updatePrioritySelection()
        updateCategorySelection()
    }

    // MARK: - AI Bulk Add View

    private func setupAIBulkAddView() {
        aiBulkAddView.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddView.isHidden = true
        contentView.addSubview(aiBulkAddView)

        NSLayoutConstraint.activate([
            aiBulkAddView.topAnchor.constraint(equalTo: toggleContainer.bottomAnchor, constant: 40),
            aiBulkAddView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            aiBulkAddView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
        ])

        aiTitleLabel.text = "智能识别助手"
        aiTitleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        aiTitleLabel.textColor = textPrimary
        aiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddView.addSubview(aiTitleLabel)

        aiDescriptionLabel.text = "AI 将自动识别并分类您的物品，根据目的地智能建议优先级。只需在下方输入您的物品清单即可。"
        aiDescriptionLabel.font = .systemFont(ofSize: 13)
        aiDescriptionLabel.textColor = textSecondary
        aiDescriptionLabel.numberOfLines = 0
        aiDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddView.addSubview(aiDescriptionLabel)

        pasteButton.setTitle("粘贴并 AI 识别", for: .normal)
        pasteButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        pasteButton.backgroundColor = themeBlue.withAlphaComponent(0.1)
        pasteButton.setTitleColor(themeBlue, for: .normal)
        pasteButton.layer.cornerRadius = 12
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        let pasteIcon = UIImage(systemName: "doc.on.clipboard", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        pasteButton.setImage(pasteIcon, for: .normal)
        pasteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        aiBulkAddView.addSubview(pasteButton)

        let textViewContainer = UIView()
        textViewContainer.backgroundColor = .white
        textViewContainer.layer.cornerRadius = 12
        textViewContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.02).cgColor
        textViewContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        textViewContainer.layer.shadowOpacity = 1
        textViewContainer.layer.shadowRadius = 20
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddView.addSubview(textViewContainer)

        aiTextView.font = .systemFont(ofSize: 15)
        aiTextView.textColor = textPrimary
        aiTextView.backgroundColor = .clear
        aiTextView.textContainerInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        aiTextView.translatesAutoresizingMaskIntoConstraints = false
        aiTextView.delegate = self
        textViewContainer.addSubview(aiTextView)

        let placeholderLabel = UILabel()
        placeholderLabel.text = "在这里输入您的物品清单...\n例如：2件衬衫、充电宝、护照"
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = textMuted.withAlphaComponent(0.4)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.tag = 100
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.addSubview(placeholderLabel)

        let processingBadge = UIView()
        processingBadge.translatesAutoresizingMaskIntoConstraints = false
        aiBulkAddView.addSubview(processingBadge)

        let processingDot = UIView()
        processingDot.backgroundColor = themeBlue.withAlphaComponent(0.3)
        processingDot.layer.cornerRadius = 4
        processingDot.translatesAutoresizingMaskIntoConstraints = false
        processingBadge.addSubview(processingDot)

        aiProcessingLabel.text = "AI PROCESSING ENABLED"
        aiProcessingLabel.font = .systemFont(ofSize: 10, weight: .bold)
        aiProcessingLabel.textColor = textMuted.withAlphaComponent(0.5)
        aiProcessingLabel.translatesAutoresizingMaskIntoConstraints = false
        processingBadge.addSubview(aiProcessingLabel)

        NSLayoutConstraint.activate([
            aiTitleLabel.topAnchor.constraint(equalTo: aiBulkAddView.topAnchor),
            aiTitleLabel.leadingAnchor.constraint(equalTo: aiBulkAddView.leadingAnchor),
            aiTitleLabel.trailingAnchor.constraint(equalTo: aiBulkAddView.trailingAnchor),

            aiDescriptionLabel.topAnchor.constraint(equalTo: aiTitleLabel.bottomAnchor, constant: 12),
            aiDescriptionLabel.leadingAnchor.constraint(equalTo: aiBulkAddView.leadingAnchor),
            aiDescriptionLabel.trailingAnchor.constraint(equalTo: aiBulkAddView.trailingAnchor),

            pasteButton.topAnchor.constraint(equalTo: aiDescriptionLabel.bottomAnchor, constant: 20),
            pasteButton.leadingAnchor.constraint(equalTo: aiBulkAddView.leadingAnchor),
            pasteButton.trailingAnchor.constraint(equalTo: aiBulkAddView.trailingAnchor),
            pasteButton.heightAnchor.constraint(equalToConstant: 48),

            textViewContainer.topAnchor.constraint(equalTo: pasteButton.bottomAnchor, constant: 20),
            textViewContainer.leadingAnchor.constraint(equalTo: aiBulkAddView.leadingAnchor),
            textViewContainer.trailingAnchor.constraint(equalTo: aiBulkAddView.trailingAnchor),
            textViewContainer.heightAnchor.constraint(equalToConstant: 200),

            aiTextView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            aiTextView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            aiTextView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            aiTextView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 24),
            placeholderLabel.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 29),
            placeholderLabel.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -29),

            processingBadge.topAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: 8),
            processingBadge.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),

            processingDot.leadingAnchor.constraint(equalTo: processingBadge.leadingAnchor),
            processingDot.centerYAnchor.constraint(equalTo: processingBadge.centerYAnchor),
            processingDot.widthAnchor.constraint(equalToConstant: 8),
            processingDot.heightAnchor.constraint(equalToConstant: 8),

            aiProcessingLabel.leadingAnchor.constraint(equalTo: processingDot.trailingAnchor, constant: 8),
            aiProcessingLabel.topAnchor.constraint(equalTo: processingBadge.topAnchor),
            aiProcessingLabel.bottomAnchor.constraint(equalTo: processingBadge.bottomAnchor),
            aiProcessingLabel.trailingAnchor.constraint(equalTo: processingBadge.trailingAnchor),

            processingBadge.bottomAnchor.constraint(equalTo: aiBulkAddView.bottomAnchor),
        ])
    }

    // MARK: - Bottom Bar

    private func setupBottomBar() {
        bottomBar.backgroundColor = backgroundMain.withAlphaComponent(0.8)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.insertSubview(blurView, at: 0)

        actionButton.backgroundColor = themeBlue
        actionButton.layer.cornerRadius = 9999
        actionButton.clipsToBounds = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        bottomBar.addSubview(actionButton)

        let shadowLayer = CALayer()
        shadowLayer.shadowColor = themeBlue.withAlphaComponent(0.2).cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 10)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 15
        actionButton.layer.insertSublayer(shadowLayer, at: 0)

        updateActionButtonTitle()

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 100),

            blurView.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),

            actionButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 24),
            actionButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -24),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Helpers

    private func createSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = textMuted
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createPriorityChip(priority: Priority, subtitle: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = priority.rawValue
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(priorityChipTapped(_:)), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = priority.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.tag = 10
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 8, weight: .bold)
        subtitleLabel.tag = 11
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: btn.topAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
        ])

        return btn
    }

    private func createCategoryGrid() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

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
        var lastRowBottom: NSLayoutAnchor<NSLayoutYAxisAnchor> = container.topAnchor
        var rowButtons: [UIButton] = []
        var firstRowFirstBtn: UIButton?

        for (index, (category, displayName)) in categories.enumerated() {
            let col = index % columns
            let btn = createCategoryButton(category: category, displayName: displayName, icon: BuiltInCategory.icon(for: category))
            container.addSubview(btn)
            categoryButtons.append(btn)

            if col == 0 {
                btn.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
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
                btn.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
                lastRowBottom = rowButtons[0].bottomAnchor
            }

            if index == categories.count - 1 {
                rowButtons[0].bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            }
        }

        if let firstBtn = firstRowFirstBtn {
            firstBtn.heightAnchor.constraint(equalToConstant: 64).isActive = true
        }

        return container
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

    // MARK: - State Management

    private func switchToTab(_ tab: Tab) {
        currentTab = tab

        let isAI = tab == .aiBulkAdd

        singleEntryView.isHidden = isAI
        aiBulkAddView.isHidden = !isAI

        if isAI {
            singleEntryButton.backgroundColor = .clear
            singleEntryButton.setTitleColor(textMuted, for: .normal)
            singleEntryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

            aiBulkAddButton.backgroundColor = .white
            aiBulkAddButton.setTitleColor(themeBlue, for: .normal)
            aiBulkAddButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            aiBulkAddButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
            aiBulkAddButton.layer.shadowOffset = CGSize(width: 0, height: 1)
            aiBulkAddButton.layer.shadowOpacity = 1
            aiBulkAddButton.layer.shadowRadius = 2
        } else {
            singleEntryButton.backgroundColor = .white
            singleEntryButton.setTitleColor(themeBlue, for: .normal)
            singleEntryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            singleEntryButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
            singleEntryButton.layer.shadowOffset = CGSize(width: 0, height: 1)
            singleEntryButton.layer.shadowOpacity = 1
            singleEntryButton.layer.shadowRadius = 2

            aiBulkAddButton.backgroundColor = .clear
            aiBulkAddButton.setTitleColor(textMuted, for: .normal)
            aiBulkAddButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        }

        updateSingleEntryBottom()
        updateAIBulkAddBottom()
        updateActionButtonTitle()
    }

    private var singleEntryBottomConstraint: NSLayoutConstraint?
    private var aiBulkAddBottomConstraint: NSLayoutConstraint?

    private func updateSingleEntryBottom() {
        singleEntryBottomConstraint?.isActive = false
        if !singleEntryView.isHidden {
            singleEntryBottomConstraint = singleEntryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120)
            singleEntryBottomConstraint?.isActive = true
        }
    }

    private func updateAIBulkAddBottom() {
        aiBulkAddBottomConstraint?.isActive = false
        if !aiBulkAddView.isHidden {
            aiBulkAddBottomConstraint = aiBulkAddView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120)
            aiBulkAddBottomConstraint?.isActive = true
        }
    }

    private func updatePrioritySelection() {
        for btn in priorityButtons {
            guard let priority = Priority(rawValue: btn.tag) else { continue }
            let isSelected = priority == selectedPriority
            let titleLabel = btn.viewWithTag(10) as? UILabel
            let subtitleLabel = btn.viewWithTag(11) as? UILabel
            let priorityColor = priority.color

            if isSelected {
                btn.backgroundColor = priorityColor
                btn.layer.borderColor = priorityColor.cgColor
                titleLabel?.textColor = .white
                subtitleLabel?.textColor = .white
            } else {
                btn.backgroundColor = .white
                btn.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 225/255, alpha: 1.0).cgColor
                titleLabel?.textColor = priorityColor
                subtitleLabel?.textColor = textMuted
            }
        }
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

    private func updateActionButtonTitle() {
        let title: String
        let icon: String
        if currentTab == .singleEntry {
            title = "添加到清单"
            icon = "plus"
        } else {
            title = "AI 分析物品"
            icon = "sparkles"
        }

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .white

        let titleAttr = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
        ]))
        config.attributedTitle = titleAttr
        config.image = UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        config.imagePadding = 12
        config.imagePlacement = .leading

        actionButton.configuration = config
    }

    // MARK: - Actions

    @objc private func dismissSelf() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func singleEntryTapped() {
        switchToTab(.singleEntry)
    }

    @objc private func aiBulkAddTapped() {
        switchToTab(.aiBulkAdd)
    }

    @objc private func priorityChipTapped(_ sender: UIButton) {
        guard let priority = Priority(rawValue: sender.tag) else { return }
        selectedPriority = priority
        updatePrioritySelection()
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let category = sender.accessibilityIdentifier else { return }
        selectedCategory = category
        updateCategorySelection()
    }

    @objc private func pasteButtonTapped() {
        guard UIPasteboard.general.hasStrings, let pasteText = UIPasteboard.general.string, !pasteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("剪贴板中没有可用的文本")
            return
        }
        
        aiTextView.text = pasteText
        if let placeholder = aiTextView.superview?.viewWithTag(100) {
            placeholder.isHidden = true
        }
        
        analyzeAndAddItems()
    }

    @objc private func actionButtonTapped() {
        if currentTab == .singleEntry {
            addSingleItem()
        } else {
            analyzeAndAddItems()
        }
    }

    private func addSingleItem() {
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("请输入物品名称")
            return
        }

        let item = TripItem(name: name.trimmingCharacters(in: .whitespacesAndNewlines), defaultPriority: selectedPriority, category: selectedCategory)
        delegate?.addItemViewController(self, didAddItems: [item])
        navigationController?.popViewController(animated: true)
    }

    private func analyzeAndAddItems() {
        guard let text = aiTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("请输入要分析的物品")
            return
        }

        showLoading(true)
        categorizingService.categorize(text: text) { [weak self] result in
            guard let self = self else { return }
            self.showLoading(false)
            switch result {
            case .success(let items):
                if items.isEmpty {
                    self.showError("未能识别出任何物品，请重试。")
                } else {
                    let listVC = ItemListViewController()
                    listVC.mode = .confirmation
                    listVC.items = items
                    listVC.delegate = self
                    self.navigationController?.pushViewController(listVC, animated: true)
                }
            case .failure(let error):
                self.showError("分析失败：\(error.localizedDescription)")
            }
        }
    }

    private func showLoading(_ show: Bool) {
        if show {
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.center = overlay.center
            spinner.startAnimating()
            overlay.addSubview(spinner)

            let label = UILabel()
        label.text = "AI 正在分析中..."
        label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
            ])

            view.addSubview(overlay)
            loadingOverlay = overlay
        } else {
            loadingOverlay?.removeFromSuperview()
            loadingOverlay = nil
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension AddItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let placeholder = textView.superview?.viewWithTag(100) {
            placeholder.isHidden = !textView.text.isEmpty
        }
    }
}

// MARK: - ItemListViewControllerDelegate

extension AddItemViewController: ItemListViewControllerDelegate {
    func itemListViewController(_ controller: ItemListViewController, didConfirmItems items: [TripItem]) {
        delegate?.addItemViewController(self, didAddItems: items)
        navigationController?.popToViewController(self, animated: false)
        navigationController?.popViewController(animated: true)
    }
}
