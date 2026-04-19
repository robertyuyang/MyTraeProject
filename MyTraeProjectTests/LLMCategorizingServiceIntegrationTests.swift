//
//  LLMCategorizingServiceIntegrationTests.swift
//  MyTraeProjectTests
//
//  Created by ByteDance on 2026/4/19.
//

import XCTest
@testable import MyTraeProject

final class LLMCategorizingServiceIntegrationTests: XCTestCase {

    func testCategorizeTravelPackingList() {
        let expectation = expectation(description: "categorize travel packing list via real API")

        let inputText = """
        【P0】身份证 港澳证 护照
        机票 车票
        【P0】门票 签证
        酒店 复印件，酒店订单
        信用卡借记卡
        现金
        地铁卡 当地地铁卡
        【P0】驾照
        当地手机卡
        【P0】内衣裤
        【P0】睡衣睡裤
        【P0】袜子
        【P0】上衣
        【P0】墨镜
        【P1】外套
        【P0】眼罩
        发带发箍
        口罩
        防晒 防蚊
        袋子
        拖鞋
        """

        let apiKey = "7f170584-ff78-4d32-b5f9-fcbe78dac1a4"
        let baseURL = "https://ark.cn-beijing.volces.com/api/coding/v3"
        let model = "doubao-seed-2.0-pro"

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
                ["role": "user", "content": inputText]
            ],
            "temperature": 0.3
        ]

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 60

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                XCTFail("网络请求失败: \(error)")
                expectation.fulfill()
                return
            }

            guard let data = data else {
                XCTFail("未收到数据")
                expectation.fulfill()
                return
            }

            let responseString = String(data: data, encoding: .utf8) ?? "无法解码"
            NSLog("=== LLM API 原始 JSON 响应 ===\n%@\n=== 响应结束 ===", responseString)

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                XCTFail("API 响应格式异常: \(responseString)")
                expectation.fulfill()
                return
            }

            NSLog("=== LLM 返回的 content 字段 ===\n%@\n=== content 结束 ===", content)

            let realService = LLMCategorizingService()
            let items = realService.parseItems(from: content)
            NSLog("=== 解析后的物品列表 ===\n%@\n=== 列表结束 ===", items.map { "[\($0.defaultPriority.title)] \($0.name) (\($0.category))" }.joined(separator: "\n"))

            XCTAssertGreaterThanOrEqual(items.count, 20, "应至少解析出20个物品")

            let p0Items = items.filter { $0.defaultPriority == .p0 }
            XCTAssertGreaterThanOrEqual(p0Items.count, 5, "应至少有5个P0物品")
            let p0Names = p0Items.map { $0.name }
            let expectedP0Keywords = ["身份证", "护照", "驾照"]
            for keyword in expectedP0Keywords {
                let found = p0Names.contains { $0.contains(keyword) }
                XCTAssertTrue(found, "P0 物品中应包含「\(keyword)」")
            }

            let p1Items = items.filter { $0.defaultPriority == .p1 }
            let p1Names = p1Items.map { $0.name }
            let hasCoat = p1Names.contains { $0.contains("外套") }
            XCTAssertTrue(hasCoat, "P1 物品中应包含「外套」")

            let validCategories = Set(BuiltInCategory.allCases)
            for item in items {
                XCTAssertTrue(validCategories.contains(item.category),
                              "物品「\(item.name)」的分类「\(item.category)」不在合法分类中")
            }

            let clothingItems = items.filter { $0.category == BuiltInCategory.clothing }
            XCTAssertGreaterThanOrEqual(clothingItems.count, 3, "Clothing 分类应至少有3个物品")

            let idOrDocItems = items.filter {
                $0.category == BuiltInCategory.documentsAndIDs
            }
            XCTAssertGreaterThanOrEqual(idOrDocItems.count, 3, "IDs/Documents 分类应至少有3个物品")

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 60)
    }
}
