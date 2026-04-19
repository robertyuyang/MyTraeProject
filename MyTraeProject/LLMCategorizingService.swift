//
//  LLMCategorizingService.swift
//  MyTraeProject
//
//  Created by ByteDance on 2026/4/17.
//

import Foundation

class LLMCategorizingService: TextCategorizingService {
    private let apiKey: String
    private let baseURL: String
    private let model: String
    let session: URLSession

    init(
        apiKey: String = "7f170584-ff78-4d32-b5f9-fcbe78dac1a4",
        baseURL: String = "https://ark.cn-beijing.volces.com/api/coding/v3",
        model: String = "doubao-seed-2.0-pro",
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.session = session
    }

    func categorize(text: String, completion: @escaping (Result<[TripItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "LLMCategorizingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let categories = BuiltInCategory.allCases.joined(separator: ", ")
        let systemPrompt = """
        你是一个旅行物品分类助手。用户会输入一段自然语言描述他们想带的物品。
        你需要：
        1. 从文本中提取每个物品
        2. 为每个物品判断优先级：P0（必须带）、P1（建议带）、P2（可选）
        3. 为每个物品分配一个分类，只能从以下分类中选择：\(categories)

        请严格以 JSON 数组格式返回结果，不要包含任何其他文字，格式如下：
        [{"name": "物品名", "priority": 0, "category": "分类"}]
        其中 priority 为 0 表示 P0，1 表示 P1，2 表示 P2。
        """

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "LLMCategorizingService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        request.timeoutInterval = 30

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "LLMCategorizingService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "LLMCategorizingService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])))
                    }
                    return
                }

                let items = self.parseItems(from: content)
                DispatchQueue.main.async { completion(.success(items)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    func parseItems(from content: String) -> [TripItem] {
        let trimmed = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = trimmed.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }

        return array.compactMap { dict -> TripItem? in
            guard let name = dict["name"] as? String, !name.isEmpty else { return nil }

            let priorityRaw = dict["priority"] as? Int ?? 2
            let priority = Priority(rawValue: priorityRaw) ?? .p2

            let category = dict["category"] as? String ?? BuiltInCategory.other
            let validCategory = BuiltInCategory.allCases.contains(category) ? category : BuiltInCategory.other

            return TripItem(name: name, defaultPriority: priority, category: validCategory)
        }
    }
}
