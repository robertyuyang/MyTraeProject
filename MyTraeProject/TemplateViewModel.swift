//
//  TemplateViewModel.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/22.
//

import Foundation
import UIKit

class TemplateViewModel {
    private var templates: [TripTemplate] = []
    
    var reloadData: (() -> Void)?
    var reloadRow: ((Int) -> Void)?
    
    init() {
        loadData()
    }
    
    func loadData() {
        templates = DataManager.shared.loadTemplates()
        reloadData?()
    }
    
    func saveData() {
        DataManager.shared.saveTemplates(templates)
    }
    
    func addTemplate(_ template: TripTemplate) {
        templates.insert(template, at: 0)
        saveData()
        reloadData?()
    }
    
    func deleteTemplate(at index: Int) {
        templates.remove(at: index)
        saveData()
        reloadData?()
    }
    
    func renameTemplate(at index: Int, newName: String) {
        templates[index].name = newName
        saveData()
        reloadRow?(index)
    }
    
    func duplicateTemplate(at index: Int) {
        let originalTemplate = templates[index]
        let duplicatedTemplate = TripTemplate(
            name: originalTemplate.name + " (Copy)",
            description: originalTemplate.description,
            items: originalTemplate.items,
            isBuiltIn: false
        )
        templates.insert(duplicatedTemplate, at: 0)
        saveData()
        reloadData?()
    }
    
    func updateTemplate(_ template: TripTemplate, at index: Int) {
        templates[index] = template
        saveData()
        reloadData?()
    }
    
    func numberOfTemplates() -> Int {
        return templates.count
    }
    
    func template(at index: Int) -> TripTemplate {
        return templates[index]
    }
    
    func toTrip(template: TripTemplate) -> Trip {
        return template.toTrip()
    }
}
