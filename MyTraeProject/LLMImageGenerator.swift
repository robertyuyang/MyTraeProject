import Foundation

class LLMImageGenerator: ImageGenerating {
    private let apiKey: String
    private let baseURL: String
    private let model: String
    private let session: URLSession

    init(
        apiKey: String = "7f170584-ff78-4d32-b5f9-fcbe78dac1a4",
        baseURL: String = "https://ark.cn-beijing.volces.com/api/v3",
        model: String = "doubao-seedream-3-0-t2i",
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.session = session
    }

    func generateImage(for tripName: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)/images/generations") else {
            completion(nil, NSError(domain: "LLMImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let prompt = "一张精美的旅行风景横版照片，主题是「\(tripName)」，高清摄影作品，色彩鲜艳，适合作为旅行清单的封面图"

        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "size": "2048x1024",
            "response_format": "url",
            "watermark": false
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(nil, NSError(domain: "LLMImageGenerator", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData
        request.timeoutInterval = 120

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "LLMImageGenerator", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let dataArray = json["data"] as? [[String: Any]],
                      let firstItem = dataArray.first,
                      let imageUrl = firstItem["url"] as? String else {
                    completion(nil, NSError(domain: "LLMImageGenerator", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"]))
                    return
                }

                completion(imageUrl, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}