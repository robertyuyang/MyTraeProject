//  NaturalLanguageParser.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/3/13.
//

import Foundation

class NaturalLanguageParser {
    static let shared = NaturalLanguageParser()
    
    private init() {}
    
    func parse(text: String) -> [(name: String, priority: Priority)] {
        var items: [(name: String, priority: Priority)] = []
        
        // 替换中文标点为英文标点
        let normalizedText = text
            .replacingOccurrences(of: "，", with: ",")
            .replacingOccurrences(of: "；", with: ";")
            .replacingOccurrences(of: "。", with: ".")
            .replacingOccurrences(of: "！", with: "!")
            .replacingOccurrences(of: "？", with: "?")
        
        // 按常见分隔符分割
        let components = normalizedText.components(separatedBy: [",", ";", "、", "。"])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // 定义表示 P0 优先级的关键词
        let p0Keywords = [
            "必须", "一定要", "一定要带", "必须带", "务必", "务必带", "记得带", "一定", "肯定", "必需",
            "need", "must", "have to", "required", "essential", "necessary"
        ]
        
        // 定义表示 P1 优先级的关键词
        let p1Keywords = [
            "最好", "最好带", "建议", "建议带", "可以", "可以带", "推荐", "推荐带", "尽量", "尽量带",
            "preferably", "recommended", "suggest", "should", "would like", "might want"
        ]
        
        // 处理每个部分
        for component in components {
            var name = component
            var priority: Priority = .p2 // 默认 P2
            
            // 检查是否有 P0 关键词
            for keyword in p0Keywords where name.contains(keyword) {
                priority = .p0
                name = name.replacingOccurrences(of: keyword, with: "")
                break
            }
            
            // 如果没有匹配到 P0，检查 P1 关键词
            if priority == .p2 {
                for keyword in p1Keywords where name.contains(keyword) {
                    priority = .p1
                    name = name.replacingOccurrences(of: keyword, with: "")
                    break
                }
            }
            
            // 清理额外的空白字符和标点
            name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "！", with: "")
                .replacingOccurrences(of: "!", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !name.isEmpty {
                items.append((name: name, priority: priority))
            }
        }
        
        return items
    }
}