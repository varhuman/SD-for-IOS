import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    
    private static let ip = "192.168.4.4:7860"
    private static let ip2 = "120.55.169.72:48880"
    private static let url = "http://\(ip2)/sdapi/v1/"
    private let HOST = "48880"
    let getModelUrl = "\(url)sd-models"
    let getOptionUrl = "\(url)options"
    let getLoraModelUrl = "\(url)getLora"
    let txt2ImgUrl = "\(url)txt2img"
    
    private init() { }

    func getRequest(url: URL, headers: [String: String], completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
    }
    
    func postRequest(url: String, parameters: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            completionHandler(nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        if let jsonSer = try? JSONSerialization.data(withJSONObject: parameters),
           let body = String(data: jsonSer, encoding: .utf8){
            print("这是输出的body : \(body)")
            Utils.SaveOutputLog(content: "\(body)", fileName: "body.json")
        }
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func getModelRequest(completion: @escaping (Result<Data, Error>) -> Void) {
            guard let url = URL(string: getModelUrl) else {
                fatalError("Invalid URL")
            }
            let headers = [
                "Host": HOST,
                "Connection": "keep-alive",
                "Content-Type": "application/json"
            ]
            getRequest(url: url, headers: headers, completion: completion)
        }

    func getOptionsRequest(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: getOptionUrl) else {
            fatalError("Invalid URL")
        }
        let headers = [
            "Host": HOST,
            "Connection": "keep-alive",
            "Content-Type": "application/json"
        ]
        getRequest(url: url, headers: headers, completion: completion)
    }
    
    func getLoraModelRequest(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: getLoraModelUrl) else {
            fatalError("Invalid URL")
        }
        let headers = [
            "Host": HOST,
            "Connection": "keep-alive",
            "Content-Type": "application/json"
        ]
        getRequest(url: url, headers: headers, completion: completion)
    }
    
    func sendtxt2ImgRequest(requestParameters: txt2ImgRequestBody,  completion: @escaping (Result<txt2ImgResponse, Error>) -> Void) {
            let parameters = requestParameters.toDictionary()
            let urlString = txt2ImgUrl
            postRequest(url: urlString, parameters: parameters) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing data"])))
                    return
                }

                do {
                    
                    let serverResponse = try JSONDecoder().decode(txt2ImgResponse.self, from: data)
                    completion(.success(serverResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }

}
