import Foundation

protocol ImageGenerating {
    func generateImage(for tripName: String, completion: @escaping (String?, Error?) -> Void)
}

class AIImageGenerator: ImageGenerating {
    init() {}
    
    func generateImage(for tripName: String, completion: @escaping (String?, Error?) -> Void) {
        let prompt = "横版风景照片，与'\(tripName)'相关的旅行场景，高清，真实感"
        // 使用Z-Image免费AI图片生成服务
        // 完全免费，无需API密钥
        let baseURL = "https://zimage.run/api/generate"
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(nil, NSError(domain: "AIImageGenerator", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // 添加参数
        urlComponents.queryItems = [
            URLQueryItem(name: "prompt", value: prompt),
            URLQueryItem(name: "size", value: "1024x512"), // 横版图片
            URLQueryItem(name: "model", value: "z-image-turbo") // 使用turbo模型
        ]
        
        guard let url = urlComponents.url else {
            completion(nil, NSError(domain: "AIImageGenerator", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // 发送请求
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "AIImageGenerator", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // 解析响应
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = json["url"] as? String {
                    completion(imageUrl, nil)
                } else {
                    completion(nil, NSError(domain: "AIImageGenerator", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}