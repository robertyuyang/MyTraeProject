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

struct TravelItem: Codable, Equatable {
    let id: UUID
    var name: String
    var priority: Priority
    var isChecked: Bool
    
    init(name: String, priority: Priority) {
        self.id = UUID()
        self.name = name
        self.priority = priority
        self.isChecked = false
    }
}

struct TravelList: Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TravelItem]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.items = []
    }
}

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let listsKey = "travelLists"
    
    private init() {}
    
    func loadLists() -> [TravelList] {
        guard let data = userDefaults.data(forKey: listsKey),
              let lists = try? JSONDecoder().decode([TravelList].self, from: data) else {
            return []
        }
        return lists
    }
    
    func saveLists(_ lists: [TravelList]) {
        if let data = try? JSONEncoder().encode(lists) {
            userDefaults.set(data, forKey: listsKey)
        }
    }
}