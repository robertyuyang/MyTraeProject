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
        
        guard let language = recognizer.dominantLanguage else {
            return text
        }
        
        if language == .english {
            return text
        }
        
        return "travel adventure landscape \(text)"
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
