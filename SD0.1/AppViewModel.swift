//
//  AppViewModel.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/16.
//
import Foundation
import Combine


class AppViewModel: ObservableObject {
    static let viewModel = AppViewModel()

    @Published var modelTitles: [String] = []
    @Published var modelItems: [ModelItem] = []
    @Published var loraModels: LoraModelsResponse = LoraModelsResponse(list: [])
    
    func fetchModelOptions(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.getModelRequest { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            // 解析JSON数据并更新您的数据模型
                            // 注意：您需要根据实际的API响应数据来解析JSON
                            do {
                                print("原始数据: \(String(data: data, encoding: .utf8) ?? "无法转换为字符串")")

                                self.modelItems = try JSONDecoder().decode([ModelItem].self, from: data)
                                self.modelTitles = self.modelItems.map { $0.title }.sorted()
                                // 使用解析后的modelItems数组更新您的数据模型
                                print("解析后的ModelItem数组: \(self.modelItems)")
                                completion(true, "Model数据请求成功")
                            } catch {
                                print("Model JSON解析失败: \(error.localizedDescription)")
                                completion(false, "请求成功，但JSON解析失败")
                            }

                            
                        case .failure(let error):
                            print("请求失败: \(error.localizedDescription)")
                            completion(false, "Model数据请求失败，出现了错误")
                        }
                    }
                }
    }

    func getOptions(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.getOptionsRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(OptionsResponse.self, from: data)
                        print("sd_model_checkpoint: \(decodedData.sd_model_checkpoint)")
                        completion(true, "Options数据请求成功")
                    } catch {
                        print("Options JSON解析失败: \(error.localizedDescription)")
                        completion(false, "请求成功，但JSON解析失败")
                    }
                    
                case .failure(let error):
                    print("请求失败: \(error.localizedDescription)")
                    completion(false, "Options数据请求失败，出现了错误")
                }
            }
        }
    }
    
    func getLoraModels(completion: @escaping (Bool, String) -> Void) {
        NetworkManager.shared.getLoraModelRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        
                        print("getLoraModels原始数据: \(String(data: data, encoding: .utf8) ?? "无法转换为字符串")")
                        self.loraModels = try JSONDecoder().decode(LoraModelsResponse.self, from: data)
                        self.loraModels.list.sort()
                        completion(true, "getLoraModels数据请求成功")
                    } catch {
                        print("getLoraModels JSON解析失败: \(error.localizedDescription)")
                        completion(false, "请求成功，但JSON解析失败")
                    }
                    
                case .failure(let error):
                    print("请求失败: \(error.localizedDescription)")
                    completion(false, "getLoraModels数据请求失败，出现了错误")
                }
            }
        }
    }
    
    func sendtxt2ImgRequest(body: txt2ImgRequestBody, completion: @escaping (Result<txt2ImgResponse, Error>) -> Void) {
        NetworkManager.shared.sendtxt2ImgRequest(requestParameters: body) { result in
                    switch result {
                    case .success(let serverResponse):
                        print("Received server response: \(serverResponse)")
                        // 更新UI或处理响应数据

                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        // 在此处处理错误，例如显示错误消息
                    }
                }
        }
}
