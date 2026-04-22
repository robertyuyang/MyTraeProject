import Foundation

class UnsplashImageGenerator: ImageGenerating {
    private let accessKey: String
    private let translationService: TranslationService
    private let translationMode: TranslationService.TranslationMode
    private let session: URLSession

    init(
        accessKey: String = "HVaMC8KaE2AiSMD1JxRahZ8brKZf9MFgZTL59O96eys",
        translationService: TranslationService = TranslationService(),
        translationMode: TranslationService.TranslationMode = .llm,
        session: URLSession = .shared
    ) {
        self.accessKey = accessKey
        self.translationService = translationService
        self.translationMode = translationMode
        self.session = session
    }

    func generateImage(for tripName: String, completion: @escaping (String?, Error?) -> Void) {
        print("🖼️ [图片生成] 开始为 Trip 生成图片")
        print("🖼️ [图片生成] Trip 名称: \"\(tripName)\"")
        print("🖼️ [图片生成] 使用翻译模式: \(translationMode)")
        
        translationService.translateToEnglish(tripName, mode: translationMode) { [weak self] translatedText in
            guard let self = self else { 
                print("🖼️ [图片生成] ❌ self 已释放")
                return 
            }
            print("🖼️ [图片生成] 准备搜索图片，关键词: \"\(translatedText)\"")
            self.searchUnsplash(with: translatedText, fallbackQuery: "travel landscape scenic", completion: completion)
        }
    }

    private func searchUnsplash(with text: String, fallbackQuery: String? = nil, completion: @escaping (String?, Error?) -> Void) {
        print("📸 [Unsplash搜索] 开始搜索...")
        print("📸 [Unsplash搜索] 搜索关键词: \"\(text)\"")
        if let fallback = fallbackQuery {
            print("📸 [Unsplash搜索] 备用查询: \"\(fallback)\"")
        }
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos") else {
            print("📸 [Unsplash搜索] ❌ URL无效")
            completion(nil, NSError(domain: "UnsplashImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: "\(text)"),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "per_page", value: "5")
        ]

        guard let url = urlComponents.url else {
            print("📸 [Unsplash搜索] ❌ 无法构建URL")
            completion(nil, NSError(domain: "UnsplashImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        print("📸 [Unsplash搜索] 请求URL: \(url)")

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { 
                print("📸 [Unsplash搜索] ❌ self 已释放")
                return 
            }
            
            if let error = error {
                print("📸 [Unsplash搜索] ❌ 请求失败: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let data = data else {
                print("📸 [Unsplash搜索] ❌ 无响应数据")
                completion(nil, NSError(domain: "UnsplashImageGenerator", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            print("📸 [Unsplash搜索] 收到响应数据")

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let results = json["results"] as? [[String: Any]] else {
                    print("📸 [Unsplash搜索] ❌ API响应格式错误")
                    completion(nil, NSError(domain: "UnsplashImageGenerator", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid API response"]))
                    return
                }
                
                print("📸 [Unsplash搜索] 找到 \(results.count) 个结果")
                
                // 如果有结果，返回第一个
                if let firstResult = results.first,
                   let urls = firstResult["urls"] as? [String: Any],
                   let regularUrl = urls["regular"] as? String {
                    print("📸 [Unsplash搜索] ✅ 找到图片: \(regularUrl)")
                    completion(regularUrl, nil)
                    return
                }
                
                // 如果没有结果且有备用查询，尝试备用查询
                if let fallback = fallbackQuery {
                    print("📸 [Unsplash搜索] 未找到结果，尝试备用查询: \"\(fallback)\"")
                    self.searchUnsplash(with: fallback, fallbackQuery: nil, completion: completion)
                } else {
                    print("📸 [Unsplash搜索] ❌ 未找到结果，也没有备用查询")
                    completion(nil, NSError(domain: "UnsplashImageGenerator", code: -3, userInfo: [NSLocalizedDescriptionKey: "No results found"]))
                }
            } catch {
                print("📸 [Unsplash搜索] ❌ JSON解析错误: \(error)")
                completion(nil, error)
            }
        }.resume()
    }
}
