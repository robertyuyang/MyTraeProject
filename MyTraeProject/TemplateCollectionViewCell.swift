//
//  TemplateCollectionViewCell.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {
    static let identifier = "TemplateCollectionViewCell"
    
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let priorityStackView = UIStackView()
    private let p0Label = UILabel()
    private let p1Label = UILabel()
    private let p2Label = UILabel()
    private var p0Container: UIView?
    private var p1Container: UIView?
    private var p2Container: UIView?
    private let totalLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    
    var onMenuTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        priorityStackView.axis = .horizontal
        priorityStackView.spacing = 8
        priorityStackView.alignment = .center
        priorityStackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(priorityStackView)
        
        // 创建 P0 容器
        let p0Cont = createPriorityContainer(label: p0Label, color: UIColor.systemRed, title: "P0")
        p0Container = p0Cont
        priorityStackView.addArrangedSubview(p0Cont)
        
        // 创建 P1 容器
        let p1Cont = createPriorityContainer(label: p1Label, color: UIColor.systemOrange, title: "P1")
        p1Container = p1Cont
        priorityStackView.addArrangedSubview(p1Cont)
        
        // 创建 P2 容器
        let p2Cont = createPriorityContainer(label: p2Label, color: UIColor.systemBlue, title: "P2")
        p2Container = p2Cont
        priorityStackView.addArrangedSubview(p2Cont)
        
        totalLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        totalLabel.textColor = .black
        totalLabel.backgroundColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 0.12)
        totalLabel.textAlignment = .center
        totalLabel.layer.cornerRadius = 14
        totalLabel.clipsToBounds = true
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(totalLabel)
        
        menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        menuButton.tintColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        cardView.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            menuButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            menuButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            menuButton.widthAnchor.constraint(equalToConstant: 28),
            menuButton.heightAnchor.constraint(equalToConstant: 28),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -6),
            
            priorityStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priorityStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            priorityStackView.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            
            totalLabel.topAnchor.constraint(equalTo: priorityStackView.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            totalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            totalLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            totalLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    @objc private func menuButtonTapped() {
        onMenuTapped?()
    }
    
    private func createPriorityContainer(label: UILabel, color: UIColor, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 6
        container.layer.borderWidth = 1
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "\(title):"
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
        ])
        
        return container
    }
    
    func configure(template: TripTemplate) {
        nameLabel.text = template.name
        
        var p0Count = 0
        var p1Count = 0
        var p2Count = 0
        
        for item in template.items {
            switch item.defaultPriority {
            case .p0: p0Count += 1
            case .p1: p1Count += 1
            case .p2: p2Count += 1
            }
        }
        
        p0Label.text = "\(p0Count)"
        p1Label.text = "\(p1Count)"
        p2Label.text = "\(p2Count)"
        
        let totalCount = p0Count + p1Count + p2Count
        totalLabel.text = "\(totalCount) ITEMS TOTAL"
        
        // 隐藏数量为0的优先级
        p0Container?.isHidden = p0Count == 0
        p1Container?.isHidden = p1Count == 0
        p2Container?.isHidden = p2Count == 0
    }
}
