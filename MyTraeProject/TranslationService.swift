import Foundation
import NaturalLanguage

class TranslationService {
    enum TranslationMode {
        case llm
        case appleNative
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
    
    func translateToEnglish(_ text: String, mode: TranslationMode = .llm, completion: @escaping (String) -> Void) {
        print("🔤 [翻译服务] ==================================")
        print("🔤 [翻译服务] 开始处理")
        print("🔤 [翻译服务] 输入文本: \"\(text)\"")
        print("🔤 [翻译服务] 翻译模式: \(mode)")
        
        let containsChinese = text.range(of: "\\p{Han}", options: .regularExpression) != nil
        print("🔤 [翻译服务] 包含中文: \(containsChinese)")
        
        guard containsChinese else {
            print("🔤 [翻译服务] 不需要翻译，直接返回原文")
            print("🔤 [翻译服务] ==================================")
            completion(text)
            return
        }
        
        print("🔤 [翻译服务] 检测到中文，开始翻译...")
        
        switch mode {
        case .llm:
            translateWithLLM(text) { translatedText in
                let finalText = translatedText ?? text
                print("🔤 [翻译服务] LLM 翻译结果: \"\(finalText)\"")
                print("🔤 [翻译服务] ==================================")
                completion(finalText)
            }
        case .appleNative:
            print("🔤 [翻译服务] Apple 本地翻译暂不可用，回退到 LLM")
            translateWithLLM(text) { translatedText in
                let finalText = translatedText ?? text
                print("🔤 [翻译服务] 翻译结果: \"\(finalText)\"")
                print("🔤 [翻译服务] ==================================")
                completion(finalText)
            }
        }
    }
    
    private func translateWithLLM(_ text: String, completion: @escaping (String?) -> Void) {
        print("🔤 [LLM翻译] 开始调用...")
        print("🔤 [LLM翻译] API URL: \(llmBaseURL)")
        
        guard let url = URL(string: "\(llmBaseURL)/chat/completions") else {
            print("🔤 [LLM翻译] ❌ URL无效")
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
            if let error = error {
                print("🔤 [LLM翻译] ❌ 请求失败: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("🔤 [LLM翻译] ❌ 无响应数据")
                completion(nil)
                return
            }
            
            print("🔤 [LLM翻译] 收到响应数据")
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    print("🔤 [LLM翻译] ❌ 解析响应失败")
                    completion(nil)
                    return
                }
                
                let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                print("🔤 [LLM翻译] 解析成功: \"\(trimmed)\"")
                completion(trimmed)
            } catch {
                print("🔤 [LLM翻译] ❌ JSON解析错误: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
