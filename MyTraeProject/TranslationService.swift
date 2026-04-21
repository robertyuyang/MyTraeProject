import Foundation
import NaturalLanguage

class TranslationService {
    enum Mode {
        case llm
        case appleNaturalLanguage
    }
    
    private let llmApiKey: String
    private let llmBaseURL: String
    private let llmModel: String
    private let session: URLSession
    
    init(
        llmApiKey: String = "7f170584-ff78-4d32-b5f9-fcbe78dac1a4",
        llmBaseURL: String = "https://ark.cn-beijing.volces.com/api/coding/v3",
        llmModel: String = "doubao-seed-2.0-pro",
        session: URLSession = .shared
    ) {
        self.llmApiKey = llmApiKey
        self.llmBaseURL = llmBaseURL
        self.llmModel = llmModel
        self.session = session
    }
    
    func translateToEnglish(_ text: String, mode: Mode = .appleNaturalLanguage, completion: @escaping (String) -> Void) {
        switch mode {
        case .appleNaturalLanguage:
            let result = processWithNaturalLanguage(text)
            completion(result)
        case .llm:
            translateWithLLM(text) { translatedText in
                completion(translatedText ?? text)
            }
        }
    }
    
    private func processWithNaturalLanguage(_ text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        let dominantLanguage = recognizer.dominantLanguage
        let isEnglish = dominantLanguage == .english
        
        // 常见中文地名的英文映射 - 提高搜索成功率
        let chineseLocationMapping: [String: String] = [
            "北京": "Beijing",
            "上海": "Shanghai",
            "广州": "Guangzhou",
            "深圳": "Shenzhen",
            "杭州": "Hangzhou",
            "成都": "Chengdu",
            "西安": "Xi'an",
            "重庆": "Chongqing",
            "武汉": "Wuhan",
            "南京": "Nanjing",
            "苏州": "Suzhou",
            "厦门": "Xiamen",
            "三亚": "Sanya",
            "丽江": "Lijiang",
            "桂林": "Guilin",
            "大理": "Dali",
            "西藏": "Tibet",
            "新疆": "Xinjiang",
            "云南": "Yunnan",
            "四川": "Sichuan",
            "日本": "Japan",
            "东京": "Tokyo",
            "大阪": "Osaka",
            "京都": "Kyoto",
            "韩国": "Korea",
            "首尔": "Seoul",
            "泰国": "Thailand",
            "曼谷": "Bangkok",
            "新加坡": "Singapore",
            "马来西亚": "Malaysia",
            "印度尼西亚": "Indonesia",
            "巴厘岛": "Bali",
            "法国": "France",
            "巴黎": "Paris",
            "意大利": "Italy",
            "罗马": "Rome",
            "威尼斯": "Venice",
            "英国": "United Kingdom",
            "伦敦": "London",
            "美国": "United States",
            "纽约": "New York",
            "洛杉矶": "Los Angeles",
            "夏威夷": "Hawaii",
            "澳大利亚": "Australia",
            "悉尼": "Sydney",
            "旅行": "travel",
            "旅游": "tourism",
            "度假": "vacation",
            "假期": "holiday"
        ]
        
        // 尝试匹配中文关键词
        var translatedText = text
        for (chinese, english) in chineseLocationMapping {
            if text.contains(chinese) {
                translatedText = text.replacingOccurrences(of: chinese, with: english)
            }
        }
        
        // 如果检测到非英文或文本包含中文字符，使用优化的搜索策略
        let containsChinese = text.range(of: "\\p{Han}", options: .regularExpression) != nil
        
        if isEnglish && !containsChinese {
            return translatedText
        }
        
        // 构建更有效的搜索查询
        if translatedText != text {
            // 如果成功替换了一些关键词，使用翻译后的文本
            return "\(translatedText) travel landscape"
        } else {
            // 否则使用通用搜索策略
            return "travel landscape adventure scenic destination"
        }
    }
    
    private func translateWithLLM(_ text: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(llmBaseURL)/chat/completions") else {
            completion(nil)
            return
        }
        
        let systemPrompt = """
        你是一个专业的翻译助手。请将用户输入的文本翻译成英文。
        如果文本已经是英文，则直接返回原文。
        只返回翻译结果，不要包含任何其他文字或解释。
        """
        
        let requestBody: [String: Any] = [
            "model": llmModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(llmApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        request.timeoutInterval = 30
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    completion(nil)
                    return
                }
                
                let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                completion(trimmed)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
