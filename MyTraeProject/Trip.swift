//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import Foundation
import UIKit

enum Priority: Int, Codable, CaseIterable {
    case p0 = 0
    case p1 = 1
    case p2 = 2
    
    var title: String {
        switch self {
        case .p0: return "P0"
        case .p1: return "P1"
        case .p2: return "P2"
        }
    }
    
    var color: UIColor {
        switch self {
        case .p0: return .systemRed
        case .p1: return .systemOrange
        case .p2: return .systemBlue
        }
    }
}

typealias Category = String

enum BuiltInCategory {
    static let electronics: Category = "Electronics"
    static let documentsAndIDs: Category = "Documents & IDs"
    static let clothing: Category = "Clothing"
    static let toiletries: Category = "Toiletries"
    static let photography: Category = "Photography"
    static let footwear: Category = "Footwear"
    static let health: Category = "Health"
    static let outdoor: Category = "Outdoor"
    static let foodAndDrinks: Category = "Food & Drinks"
    static let accessories: Category = "Accessories"
    static let other: Category = "Other"

    static let allCases: [Category] = [electronics, documentsAndIDs, clothing, toiletries, photography, footwear, health, outdoor, foodAndDrinks, accessories, other]

    static func icon(for category: Category) -> String {
        switch category {
        case electronics: return "bolt.fill"
        case documentsAndIDs: return "doc.text.fill"
        case clothing: return "tshirt.fill"
        case toiletries: return "drop.fill"
        case photography: return "camera.fill"
        case footwear: return "shoe.fill"
        case health: return "heart.fill"
        case outdoor: return "leaf.fill"
        case foodAndDrinks: return "cup.and.saucer.fill"
        case accessories: return "bag.fill"
        case other: return "ellipsis.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

struct TripItem: Codable, Equatable {
    let id: UUID
    var name: String
    var defaultPriority: Priority
    var category: Category
    
    init(name: String, defaultPriority: Priority, category: Category = BuiltInCategory.other) {
        self.id = UUID()
        self.name = name
        self.defaultPriority = defaultPriority
        self.category = category
    }
}

struct TripTemplate: Codable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    var items: [TripItem]
    var imageUrl: String?
    let isBuiltIn: Bool
    var createdAt: Date
    
    init(name: String, description: String? = nil, items: [TripItem] = [], imageUrl: String? = nil, isBuiltIn: Bool = false) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.items = items
        self.imageUrl = imageUrl
        self.isBuiltIn = isBuiltIn
        self.createdAt = Date()
    }
    
    func toTrip() -> Trip {
        var trip = Trip(name: name)
        trip.items = items.map { item in
            TripItem(name: item.name, defaultPriority: item.defaultPriority, category: item.category)
        }
        trip.imageUrl = imageUrl
        return trip
    }
}

struct Trip: Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TripItem]
    var checkedItemIDs: Set<UUID>
    var priorityOverrides: [UUID: Priority]
    var imageUrl: String?
    var createdAt: Date
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.items = []
        self.checkedItemIDs = []
        self.priorityOverrides = [:]
        self.imageUrl = nil
        self.createdAt = Date()
    }
    
    func isItemChecked(_ item: TripItem) -> Bool {
        checkedItemIDs.contains(item.id)
    }
    
    mutating func toggleItemChecked(_ item: TripItem) {
        if checkedItemIDs.contains(item.id) {
            checkedItemIDs.remove(item.id)
        } else {
            checkedItemIDs.insert(item.id)
        }
    }
    
    func priority(for item: TripItem) -> Priority {
        priorityOverrides[item.id] ?? item.defaultPriority
    }
    
    mutating func setPriority(_ priority: Priority, for item: TripItem) {
        priorityOverrides[item.id] = priority
    }
}

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let tripsKey = "trips"
    private let templatesKey = "tripTemplates"
    
    private init() {}
    
    func loadTrips() -> [Trip] {
        guard let data = userDefaults.data(forKey: tripsKey),
              let trips = try? JSONDecoder().decode([Trip].self, from: data) else {
            return []
        }
        return trips
    }
    
    func saveTrips(_ trips: [Trip]) {
        if let data = try? JSONEncoder().encode(trips) {
            userDefaults.set(data, forKey: tripsKey)
        }
    }
    
    func loadTemplates() -> [TripTemplate] {
        var templates: [TripTemplate] = []
        
        if let data = userDefaults.data(forKey: templatesKey),
           let userTemplates = try? JSONDecoder().decode([TripTemplate].self, from: data) {
            templates.append(contentsOf: userTemplates)
        }
        
        templates.append(contentsOf: builtInTemplates)
        
        return templates
    }
    
    func saveTemplates(_ templates: [TripTemplate]) {
        let userTemplates = templates.filter { !$0.isBuiltIn }
        if let data = try? JSONEncoder().encode(userTemplates) {
            userDefaults.set(data, forKey: templatesKey)
        }
    }
    
    private var builtInTemplates: [TripTemplate] {
        [
            TripTemplate(
                name: "默认旅行模板",
                description: "标准旅行必备清单",
                items: [
                    TripItem(name: "身份证", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "内衣裤", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "睡衣睡裤", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "袜子", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "外套", defaultPriority: .p1, category: BuiltInCategory.clothing),
                    TripItem(name: "纸巾", defaultPriority: .p1, category: BuiltInCategory.other),
                    TripItem(name: "马桶垫", defaultPriority: .p2, category: BuiltInCategory.other),
                    TripItem(name: "洗面奶", defaultPriority: .p0, category: BuiltInCategory.toiletries),
                    TripItem(name: "牙刷牙膏", defaultPriority: .p1, category: BuiltInCategory.toiletries),
                    TripItem(name: "剃须刀", defaultPriority: .p0, category: BuiltInCategory.toiletries),
                    TripItem(name: "手机", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "耳机", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "充电头 手机充电线 手表充电线", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "充电宝", defaultPriority: .p0, category: BuiltInCategory.electronics)
                ],
                imageUrl: "https://images.unsplash.com/photo-1501785888041-af3ef281b399?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            ),
            TripTemplate(
                name: "周末短途游",
                description: "适合2-3天的短途旅行，包含必备物品清单",
                items: [
                    TripItem(name: "便携洗漱包", defaultPriority: .p0, category: BuiltInCategory.toiletries),
                    TripItem(name: "换洗衣物", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "手机充电器", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "身份证/证件", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "舒适鞋子", defaultPriority: .p1, category: BuiltInCategory.footwear),
                    TripItem(name: "便携充电宝", defaultPriority: .p1, category: BuiltInCategory.electronics),
                    TripItem(name: "雨伞/雨衣", defaultPriority: .p2, category: BuiltInCategory.other),
                    TripItem(name: "墨镜", defaultPriority: .p2, category: BuiltInCategory.accessories)
                ],
                imageUrl: "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            ),
            TripTemplate(
                name: "商务出行",
                description: "适合商务旅行，包含工作和生活必需品",
                items: [
                    TripItem(name: "笔记本电脑", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "商务正装", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "身份证件", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "名片", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "便携洗漱用品", defaultPriority: .p1, category: BuiltInCategory.toiletries),
                    TripItem(name: "笔记本和笔", defaultPriority: .p1, category: BuiltInCategory.accessories),
                    TripItem(name: "便携U盘/移动硬盘", defaultPriority: .p1, category: BuiltInCategory.electronics),
                    TripItem(name: "商务皮鞋", defaultPriority: .p2, category: BuiltInCategory.footwear)
                ],
                imageUrl: "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            ),
            TripTemplate(
                name: "海滩度假",
                description: "享受阳光沙滩的必备清单",
                items: [
                    TripItem(name: "泳衣", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "防晒霜", defaultPriority: .p0, category: BuiltInCategory.toiletries),
                    TripItem(name: "太阳帽", defaultPriority: .p0, category: BuiltInCategory.accessories),
                    TripItem(name: "墨镜", defaultPriority: .p0, category: BuiltInCategory.accessories),
                    TripItem(name: "沙滩毛巾", defaultPriority: .p1, category: BuiltInCategory.other),
                    TripItem(name: "人字拖", defaultPriority: .p1, category: BuiltInCategory.footwear),
                    TripItem(name: "防水手机袋", defaultPriority: .p1, category: BuiltInCategory.accessories),
                    TripItem(name: "相机/运动相机", defaultPriority: .p2, category: BuiltInCategory.photography),
                    TripItem(name: "沙滩玩具", defaultPriority: .p2, category: BuiltInCategory.other)
                ],
                imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            ),
            TripTemplate(
                name: "登山/徒步",
                description: "适合户外活动的完整装备清单",
                items: [
                    TripItem(name: "登山鞋", defaultPriority: .p0, category: BuiltInCategory.footwear),
                    TripItem(name: "登山杖", defaultPriority: .p0, category: BuiltInCategory.outdoor),
                    TripItem(name: "背包", defaultPriority: .p0, category: BuiltInCategory.accessories),
                    TripItem(name: "水袋/水壶", defaultPriority: .p0, category: BuiltInCategory.foodAndDrinks),
                    TripItem(name: "冲锋衣", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "速干衣裤", defaultPriority: .p1, category: BuiltInCategory.clothing),
                    TripItem(name: "急救包", defaultPriority: .p1, category: BuiltInCategory.health),
                    TripItem(name: "头灯", defaultPriority: .p1, category: BuiltInCategory.electronics),
                    TripItem(name: "食物/能量棒", defaultPriority: .p1, category: BuiltInCategory.foodAndDrinks),
                    TripItem(name: "指南针/地图", defaultPriority: .p2, category: BuiltInCategory.accessories),
                    TripItem(name: "手套", defaultPriority: .p2, category: BuiltInCategory.accessories)
                ],
                imageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            ),
            TripTemplate(
                name: "长途国际旅行",
                description: "适合跨洲际的长途旅行，包含所有必备品",
                items: [
                    TripItem(name: "护照", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "机票/行程单", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "签证材料", defaultPriority: .p0, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "电源转换插头", defaultPriority: .p0, category: BuiltInCategory.electronics),
                    TripItem(name: "旅行洗漱包", defaultPriority: .p0, category: BuiltInCategory.toiletries),
                    TripItem(name: "换洗衣物", defaultPriority: .p0, category: BuiltInCategory.clothing),
                    TripItem(name: "常备药品", defaultPriority: .p1, category: BuiltInCategory.health),
                    TripItem(name: "国际信用卡", defaultPriority: .p1, category: BuiltInCategory.documentsAndIDs),
                    TripItem(name: "充电宝", defaultPriority: .p1, category: BuiltInCategory.electronics),
                    TripItem(name: "颈枕/眼罩", defaultPriority: .p2, category: BuiltInCategory.accessories),
                    TripItem(name: "行李牌", defaultPriority: .p2, category: BuiltInCategory.accessories)
                ],
                imageUrl: "https://images.unsplash.com/photo-1488085061387-422e29b40080?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
                isBuiltIn: true
            )
        ]
    }
}