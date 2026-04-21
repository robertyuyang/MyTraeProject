import Foundation

class UnsplashImageGenerator: ImageGenerating {
    private let accessKey: String
    private let session: URLSession

    init(
        accessKey: String = "HVaMC8KaE2AiSMD1JxRahZ8brKZf9MFgZTL59O96eys",
        session: URLSession = .shared
    ) {
        self.accessKey = accessKey
        self.session = session
    }

    func generateImage(for tripName: String, completion: @escaping (String?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos") else {
            completion(nil, NSError(domain: "UnsplashImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: "\(tripName) travel landscape"),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "per_page", value: "1")
        ]

        guard let url = urlComponents.url else {
            completion(nil, NSError(domain: "UnsplashImageGenerator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "UnsplashImageGenerator", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      let firstResult = results.first,
                      let urls = firstResult["urls"] as? [String: Any],
                      let regularUrl = urls["regular"] as? String else {
                    completion(nil, NSError(domain: "UnsplashImageGenerator", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid API response or no results"]))
                    return
                }

                completion(regularUrl, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
