//
//  TextCategorizingService.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/13.
//

import Foundation

protocol TextCategorizingService {
    func categorize(text: String, completion: @escaping (Result<[TripItem], Error>) -> Void)
}

class RuleBasedCategorizingService: TextCategorizingService {
    func categorize(text: String, completion: @escaping (Result<[TripItem], Error>) -> Void) {
        // TODO: 基于规则的实现
        completion(.success([]))
    }
}


