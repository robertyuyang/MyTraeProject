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

struct TripItem: Codable, Equatable {
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

struct Trip: Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TripItem]
    var imageUrl: String?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.items = []
        self.imageUrl = nil
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