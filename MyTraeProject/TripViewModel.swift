//
//  TripViewModel.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/8.
//

import Foundation
import UIKit

class TripViewModel {
    private var trips: [Trip] = []
    private let imageGenerator: ImageGenerating
    
    var reloadData: (() -> Void)?
    var reloadRow: ((Int) -> Void)?
    
    init(imageGenerator: ImageGenerating = UnsplashImageGenerator()) {
        self.imageGenerator = imageGenerator
        loadData()
    }
    
    // 加载数据
    func loadData() {
        trips = DataManager.shared.loadTrips()
        if trips.isEmpty {
            loadSampleData()
        }
        sortTrips()
        reloadData?()
        generateMissingImages()
    }

    private func sortTrips() {
        trips.sort { $0.createdAt > $1.createdAt }
    }
    
    // 加载示例数据
    func loadSampleData() {
        // 创建示例旅行数据
        var coastalTrip = Trip(name: "沿海公路探险")
        coastalTrip.imageUrl = "https://images.unsplash.com/photo-1506929562872-bb421503ef21?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80"
        
        var wineTrip = Trip(name: "葡萄酒乡 retreat")
        wineTrip.imageUrl = "https://images.unsplash.com/photo-1516483638261-f4dbaf036963?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80"
        
        var urbanTrip = Trip(name: "城市建筑漫步")
        urbanTrip.imageUrl = "https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80"
        
        // 添加示例项目
        // 沿海公路探险
        coastalTrip.items.append(TripItem(name: "打包徒步靴", defaultPriority: .p0, category: BuiltInCategory.clothing))
        coastalTrip.items.append(TripItem(name: "预订海滨住宿", defaultPriority: .p0, category: BuiltInCategory.other))
        coastalTrip.items.append(TripItem(name: "规划风景路线", defaultPriority: .p0, category: BuiltInCategory.other))
        coastalTrip.items.append(TripItem(name: "打包泳衣", defaultPriority: .p0, category: BuiltInCategory.clothing))
        coastalTrip.items.append(TripItem(name: "检查汽车租赁", defaultPriority: .p0, category: BuiltInCategory.other))
        coastalTrip.items.append(TripItem(name: "购买旅行保险", defaultPriority: .p1, category: BuiltInCategory.other))
        coastalTrip.items.append(TripItem(name: "打包相机", defaultPriority: .p1, category: BuiltInCategory.electronics))
        coastalTrip.items.append(TripItem(name: "研究当地餐馆", defaultPriority: .p2, category: BuiltInCategory.other))
        
        wineTrip.items.append(TripItem(name: "预订酒庄之旅", defaultPriority: .p0, category: BuiltInCategory.other))
        wineTrip.items.append(TripItem(name: "预订精品酒店", defaultPriority: .p0, category: BuiltInCategory.other))
        wineTrip.items.append(TripItem(name: "打包舒适鞋子", defaultPriority: .p0, category: BuiltInCategory.clothing))
        wineTrip.items.append(TripItem(name: "研究葡萄酒品种", defaultPriority: .p1, category: BuiltInCategory.other))
        wineTrip.items.append(TripItem(name: "规划交通", defaultPriority: .p1, category: BuiltInCategory.other))
        wineTrip.items.append(TripItem(name: "购买品酒笔记本", defaultPriority: .p2, category: BuiltInCategory.other))
        
        urbanTrip.items.append(TripItem(name: "研究建筑地标", defaultPriority: .p0, category: BuiltInCategory.other))
        urbanTrip.items.append(TripItem(name: "预订市中心住宿", defaultPriority: .p0, category: BuiltInCategory.other))
        urbanTrip.items.append(TripItem(name: "规划步行路线", defaultPriority: .p0, category: BuiltInCategory.other))
        urbanTrip.items.append(TripItem(name: "打包舒适步行鞋", defaultPriority: .p0, category: BuiltInCategory.clothing))
        
        for i in [0, 1, 2, 3, 6, 7] {
            coastalTrip.checkedItemIDs.insert(coastalTrip.items[i].id)
        }
        for i in [0, 1] {
            wineTrip.checkedItemIDs.insert(wineTrip.items[i].id)
        }
        urbanTrip.checkedItemIDs.insert(urbanTrip.items[0].id)
        
        coastalTrip.createdAt = Date(timeIntervalSinceNow: -7200)
        wineTrip.createdAt = Date(timeIntervalSinceNow: -3600)
        urbanTrip.createdAt = Date()

        trips = [coastalTrip, wineTrip, urbanTrip]
        
        // 保存到UserDefaults
        saveData()
    }
    
    // 生成缺失的图片
    func generateMissingImages() {
        for (index, trip) in trips.enumerated() {
            if trip.imageUrl == nil {
                imageGenerator.generateImage(for: trip.name) { [weak self] imageUrl, error in
                    guard let self = self, let imageUrl = imageUrl else { return }
                    
                    DispatchQueue.main.async {
                        // 更新列表中的图片URL
                        self.trips[index].imageUrl = imageUrl
                        self.saveData()
                        // 只更新当前这一行
                        self.reloadRow?(index)
                    }
                }
            }
        }
    }
    
    // 保存数据
    func saveData() {
        DataManager.shared.saveTrips(trips)
    }
    
    // 创建新旅行
    func createNewTrip(name: String, completion: @escaping () -> Void) {
        print("🚀 [创建Trip] ==================================")
        print("🚀 [创建Trip] 开始创建新 Trip")
        print("🚀 [创建Trip] Trip 名称: \"\(name)\"")
        
        let templates = DataManager.shared.loadTemplates()
        let defaultTemplate = templates.first { $0.name == "默认旅行模板" }
        var newTrip: Trip
        
        if let template = defaultTemplate {
            print("🚀 [创建Trip] 使用默认模板")
            newTrip = template.toTrip()
            newTrip.name = name
        } else {
            print("🚀 [创建Trip] 未找到默认模板，创建空白 Trip")
            newTrip = Trip(name: name)
        }
        
        print("🚀 [创建Trip] 准备生成图片...")
        
        // 生成与旅行名称相关的图片
        imageGenerator.generateImage(for: name) { [weak self] imageUrl, error in
            DispatchQueue.main.async {
                if let imageUrl = imageUrl {
                    print("🚀 [创建Trip] ✅ 图片生成成功: \(imageUrl)")
                    newTrip.imageUrl = imageUrl
                } else if let error = error {
                    print("🚀 [创建Trip] ❌ 图片生成失败: \(error)")
                } else {
                    print("🚀 [创建Trip] ⚠️ 未获取到图片")
                }
                
                guard let self = self else {
                    print("🚀 [创建Trip] ❌ self 已释放")
                    return
                }
                
                self.trips.insert(newTrip, at: 0)
                print("🚀 [创建Trip] Trip 已添加到列表")
                
                self.saveData()
                print("🚀 [创建Trip] 数据已保存")
                
                self.reloadData?()
                print("🚀 [创建Trip] UI 已刷新")
                
                print("🚀 [创建Trip] ✅ Trip 创建完成!")
                print("🚀 [创建Trip] ==================================")
                
                completion()
            }
        }
    }
    
    // 删除旅行
    func deleteTrip(at index: Int) {
        trips.remove(at: index)
        saveData()
        reloadData?()
    }
    
    // 重命名旅行
    func renameTrip(at index: Int, newName: String) {
        trips[index].name = newName
        saveData()
        reloadRow?(index)
    }
    
    // 复制旅行
    func copyTrip(at index: Int) {
        let originalTrip = trips[index]
        var copiedTrip = Trip(name: originalTrip.name + " (副本)")
        copiedTrip.items = originalTrip.items
        copiedTrip.imageUrl = originalTrip.imageUrl
        trips.insert(copiedTrip, at: 0)
        saveData()
        reloadData?()
    }
    
    // 获取旅行数量
    func numberOfTrips() -> Int {
        return trips.count
    }
    
    // 获取指定位置的旅行
    func trip(at index: Int) -> Trip {
        return trips[index]
    }
    
    // 更新旅行
    func updateTrip(_ trip: Trip, at index: Int) {
        trips[index] = trip
        saveData()
        reloadRow?(index)
    }
    
    // 计算某个清单的P0进度
    func p0Progress(for trip: Trip) -> (checked: Int, total: Int, percentage: Double) {
        let p0Items = trip.items.filter { trip.priority(for: $0) == .p0 }
        let checkedCount = p0Items.filter { trip.isItemChecked($0) }.count
        let totalCount = p0Items.count
        let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
        return (checkedCount, totalCount, percentage)
    }
    
    func totalProgress(for trip: Trip) -> (checked: Int, total: Int, percentage: Double) {
        let checkedCount = trip.items.filter { trip.isItemChecked($0) }.count
        let totalCount = trip.items.count
        let percentage = totalCount > 0 ? Double(checkedCount) / Double(totalCount) : 0
        return (checkedCount, totalCount, percentage)
    }
    
    // 获取旅行状态
    func getTripStatus(for trip: Trip) -> TripStatus {
        let p0Progress = self.p0Progress(for: trip)
        let totalProgress = self.totalProgress(for: trip)
        
        if p0Progress.percentage < 1.0 && totalProgress.percentage > 0 {
            return .urgent
        } else if totalProgress.percentage > 0 && totalProgress.percentage < 1.0 {
            return .planning
        } else {
            return .concept
        }
    }
    
    // 旅行状态枚举
    enum TripStatus: String {
        case urgent = "URGENT"
        case planning = "PLANNING"
        case concept = "CONCEPT"
        
        var color: UIColor {
            switch self {
            case .urgent:
                return UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0) // systemRed
            case .planning:
                return UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0) // systemOrange
            case .concept:
                return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0) // systemGray
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .urgent:
                return UIColor(red: 255/255, green: 242/255, blue: 242/255, alpha: 1.0)
            case .planning:
                return UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1.0)
            case .concept:
                return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
            }
        }
    }
}
