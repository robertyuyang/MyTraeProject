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
    static let documents: Category = "Documents"
    static let clothing: Category = "Clothing"
    static let toiletries: Category = "Toiletries"
    static let ids: Category = "IDs"
    static let medicine: Category = "Medicine"
    static let personalCare: Category = "Personal Care"
    static let entertainment: Category = "Entertainment"
    static let other: Category = "Other"

    static let allCases: [Category] = [electronics, documents, clothing, toiletries, ids, medicine, personalCare, entertainment, other]
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

struct Trip: Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TripItem]
    var checkedItemIDs: Set<UUID>
    var priorityOverrides: [UUID: Priority]
    var imageUrl: String?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.items = []
        self.checkedItemIDs = []
        self.priorityOverrides = [:]
        self.imageUrl = nil
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
}