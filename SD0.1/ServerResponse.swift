//
//  ServerResponse.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//

import Foundation
import SwiftyJSON
import AnyCodable

// ModelItem 结构体
struct ModelItem: Codable {
    let title: String
    let model_name: String
    let hash: String
    let sha256: String
    let filename: String
    let config: String?
}

let samplerOptions: [SamplerIndex] = [
    .EulerA,
    .Euler,
    .LMS,
    .Heun,
    .DPM2,
    .DPM2A,
    .DPMPP2SA,
    .DPMPP2M,
    .DPMPPSDE,
    .DPMFast,
    .DPMAdaptive,
    .LMSKarras,
    .DPM2Karras,
    .DPM2AKarras,
    .DPMPP2SAKarras,
    .DPMPP2MKarras,
    .DPMPPSDEKarras
]

struct OptionsResponse: Codable {
    let sd_model_checkpoint: String
}

enum SamplerIndex: String {
    case EulerA = "Euler a"
    case Euler = "Euler"
    case LMS = "LMS"
    case Heun = "Heun"
    case DPM2 = "DPM2"
    case DPM2A = "DPM2 a"
    case DPMPP2SA = "DPM++ 2S a"
    case DPMPP2M = "DPM++ 2M"
    case DPMPPSDE = "DPM++ SDE"
    case DPMFast = "DPM fast"
    case DPMAdaptive = "DPM adaptive"
    case LMSKarras = "LMS Karras"
    case DPM2Karras = "DPM2 Karras"
    case DPM2AKarras = "DPM2 a Karras"
    case DPMPP2SAKarras = "DPM++ 2S a Karras"
    case DPMPP2MKarras = "DPM++ 2M Karras"
    case DPMPPSDEKarras = "DPM++ SDE Karras"
}

let samplers_k_diffusion = [
    SamplerIndex.EulerA,
    SamplerIndex.Euler,
    SamplerIndex.LMS,
    SamplerIndex.Heun,
    SamplerIndex.DPM2,
    SamplerIndex.DPM2A,
    SamplerIndex.DPMPP2SA,
    SamplerIndex.DPMPP2M,
    SamplerIndex.DPMPPSDE,
    SamplerIndex.DPMFast,
    SamplerIndex.DPMAdaptive,
    SamplerIndex.LMSKarras,
    SamplerIndex.DPM2Karras,
    SamplerIndex.DPM2AKarras,
    SamplerIndex.DPMPP2SAKarras,
    SamplerIndex.DPMPP2MKarras,
    SamplerIndex.DPMPPSDEKarras,
]
extension SamplerIndex: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = SamplerIndex(rawValue: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid sampler index value")
        }
        self = value
    }
}
extension SamplerIndex: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}


extension txt2ImgRequestBody {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}
struct txt2ImgRequestBody: Codable {
    var enable_hr: Bool = false
    var denoising_strength: Int = 0
    var firstphase_width: Int = 0
    var firstphase_height: Int = 0
    var hr_scale: Int = 2
    var hr_second_pass_steps: Int = 0
    var hr_resize_x: Int = 0
    var hr_resize_y: Int = 0
    var prompt: String = "A Girl, laying sofa"
    var negative_prompt: String = "low quality, nsfw"
    var styles: [String] = ["string"]
    var override_settings: OverrideSettings = OverrideSettings()
    
    struct OverrideSettings: Codable {
        var sd_model_checkpoint: String = "AsiaFacemix-pruned-fix.safetensors [75230c2f99]"
    }
    
    var seed: Int = -1
    var subseed: Int = -1
    var subseed_strength: Int = 0
    var seed_resize_from_h: Int = -1
    var seed_resize_from_w: Int = -1
    var batch_size: Int = 1
    var n_iter: Int = 1
    var steps: Int = 50
    var cfg_scale: Int = 7
    var width: Int = 512
    var height: Int = 512
    var restore_faces: Bool = false
    var tiling: Bool = false
    var eta: Int = 0
    var s_churn: Int = 0
    var s_tmax: Int = 0
    var s_tmin: Int = 0
    var s_noise: Int = 1
    var override_settings_restore_afterwards: Bool = true
    var script_args: JSON = [0,true,false,"LoRA","",0.1,0.1,"LoRA","",0.1,0.1]
    var sampler_index: String = "Euler a"
    
    mutating func addArgs(isEnable: Bool? = false, loras: [String]? = nil, weights: [Float]? = nil, enableds: [Bool]? = nil) {
        // 清空数组，并添加默认值
        script_args = JSON(arrayLiteral: 0, true)
        
        // 添加 isEnable 参数
        if let isEnable = isEnable {
            script_args.arrayObject?.append(isEnable)
        }
        
        // 检查 loras, weights 和 enableds 是否同时存在
        if let loras = loras, let weights = weights, let enableds = enableds {
            // 确保三个数组具有相同的长度
            guard loras.count == weights.count, weights.count == enableds.count else {
                print("Error: loras, weights and enableds arrays should have the same length.")
                return
            }
            
            // 遍历数组并依次添加值
            for index in 0..<loras.count {
                if enableds[index] {
                    script_args.arrayObject?.append("LoRA")
                    script_args.arrayObject?.append(loras[index])
                    script_args.arrayObject?.append(weights[index])
                    script_args.arrayObject?.append(weights[index])
                }
            }
        }
    }
}

struct LoraModelsResponse: Codable {
    var list: [String] // lora的models列表，只包括名字
}

struct txt2ImgResponse: Codable {
    let images: [String]
//    let parameters: Parameters
//    let info: String

    struct Parameters: Codable {
        let enable_hr: Bool
        let denoising_strength: Double
        let firstphase_width: Int
        let firstphase_height: Int
        let hr_scale: Double
        let hr_upscaler: String?
        let hr_second_pass_steps: Int
        let hr_resize_x: Int
        let hr_resize_y: Int
        let prompt: String
        let styles: [String]
        let seed: Int
        let subseed: Int
        let subseed_strength: Double
        let seed_resize_from_h: Int
        let seed_resize_from_w: Int
        let sampler_name: String?
        let batch_size: Int
        let n_iter: Int
        let steps: Int
        let cfg_scale: Double
        let width: Int
        let height: Int
        let restore_faces: Bool
        let tiling: Bool
        let negative_prompt: String?
        let eta: Double
        let s_churn: Double
        let s_tmax: Double
        let s_tmin: Double
        let s_noise: Double
        let override_settings: [String: String]
        let override_settings_restore_afterwards: Bool
        let script_args: [String]
        let sampler_index: String
        let script_name: String?
    }
}


