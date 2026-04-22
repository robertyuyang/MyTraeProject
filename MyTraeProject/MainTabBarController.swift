//
//  MainTabBarController.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

class MainTabBarController: UIViewController {
    
    private var currentTabIndex: Int = 0
    private let tabs: [(title: String, icon: String)] = [
        ("Trips", "suitcase"),
        ("Templates", "doc.text"),
        ("Settings", "gear")
    ]
    
    private let tabBarView = UIView()
    private let contentContainer = UIView()
    private var currentViewController: UIViewController?
    
    private let tripsVC: TripsViewController2
    private let templatesVC: TemplatesViewController
    
    init() {
        self.tripsVC = TripsViewController2()
        self.templatesVC = TemplatesViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        selectTab(at: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTripCreatedFromTemplate),
            name: NSNotification.Name("TripCreatedFromTemplate"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        
        tabBarView.backgroundColor = .white
        tabBarView.layer.borderWidth = 1.0
        tabBarView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(stackView)
        
        for (index, tab) in tabs.enumerated() {
            let tabItem = createTabBarItem(title: tab.title, icon: tab.icon, isSelected: index == 0, index: index)
            stackView.addArrangedSubview(tabItem)
        }
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 80),
            
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: tabBarView.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createTabBarItem(title: String, icon: String, isSelected: Bool, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: icon)
        imageView.tintColor = isSelected ? .systemBlue : .secondaryLabel
        imageView.tag = 100
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = isSelected ? .systemBlue : .secondaryLabel
        label.tag = 101
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        container.tag = index
        
        return container
    }
    
    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        selectTab(at: index)
    }
    
    private func selectTab(at index: Int) {
        currentTabIndex = index
        
        for (i, subview) in tabBarView.subviews.enumerated() {
            if let stackView = subview as? UIStackView {
                for (j, tabContainer) in stackView.arrangedSubviews.enumerated() {
                    let isSelected = j == index
                    if let imageView = tabContainer.viewWithTag(100) as? UIImageView {
                        imageView.tintColor = isSelected ? .systemBlue : .secondaryLabel
                    }
                    if let label = tabContainer.viewWithTag(101) as? UILabel {
                        label.textColor = isSelected ? .systemBlue : .secondaryLabel
                    }
                }
            }
        }
        
        let viewController: UIViewController
        switch index {
        case 0:
            viewController = tripsVC
        case 1:
            viewController = templatesVC
        case 2:
            viewController = SettingsViewController()
        default:
            return
        }
        
        switchToViewController(viewController)
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
        currentViewController = viewController
    }
    
    @objc private func handleTripCreatedFromTemplate() {
        selectTab(at: 0)
    }
}

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        let pageTitleLabel = UILabel()
        pageTitleLabel.text = "Settings"
        pageTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        pageTitleLabel.textColor = .black
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Coming Soon"
        placeholderLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
