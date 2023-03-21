//
//  CoreDataUtils.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/19.
//

import Foundation

import CoreData

import SwiftUI

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var getContentViewDataModel: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "contentViewData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}


class CoreDataUtils: ObservableObject{
    var viewModel = AppViewModel.viewModel
    
    static let shared = CoreDataUtils()
    
    func deleteAllData(of entityName: String) {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all data of entity \(entityName): \(error)")
        }
    }
    
    func fetchContentViewUserData() -> [ContentViewUserData] {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let fetchRequest: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
        
        do {
            let fetchedData = try context.fetch(fetchRequest)
            return fetchedData
        } catch {
            print("Failed to fetch ContentViewUserData: \(error)")
            return []
        }
    }
    

    func deleteData(of entityName: String, attributeName: String, value: String) {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", attributeName, value)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete data with attribute \(attributeName) of value \(value) in entity \(entityName): \(error)")
        }
    }
    func deleteLastData(){
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let inputData: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
        do {
            let fetchedSettings = try context.fetch(inputData)
            
            if let lastSetting = fetchedSettings.last {
                context.delete(lastSetting)
                do {
                    try context.save()
                } catch {
                    print("Failed to save after deleting the last object: \(error)")
                }
            } else {
                print("No objects found to delete")
            }
        } catch {
            print("Failed to fetch settings: \(error)")
        }

    }
    
    func saveForSubmit(image: UIImage? = nil){
        var imageStr: String = ""
        if let image = image {
            imageStr = Utils.compressBase64Image(image: image, compressionQuality: 0.2) ?? ""
        }
        
        //保存前需要删除最后一个，因为最后一个是用户输出的最终状态、删除了才能保证没有将用户最终状态变成一个历史记录
//        deleteLastData()
        
        saveForContentViewData(isCreate: true, imageStr: imageStr)
    }
    
    func saveForContentViewData(isCreate:Bool = false, imageStr:String? = "") {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let UserInputLocalData: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
        do {
            let fetchedSettings = try context.fetch(UserInputLocalData)
            
            let inputData = isCreate ? ContentViewUserData(context: context) : (fetchedSettings.last ?? ContentViewUserData(context: context))
            inputData.isAdditionNetworkChecked = viewModel.isAdditionNetworkChecked
            inputData.batch_size = Int64(viewModel.batch_size)
            inputData.height = Int64(viewModel.height)
            inputData.width = Int64(viewModel.width)
            inputData.seed = Int64(viewModel.seed)
            inputData.selectedSamplerIndex = Int64(viewModel.selectedSamplerIndex)
            inputData.selectedModelIndex = Int64(viewModel.selectedModelIndex)
            inputData.steps = Int64(viewModel.steps)
            inputData.negativeTextInput = viewModel.negativeTextInput
            inputData.faceRestore = viewModel.faceRestore
            inputData.promptTextInput = viewModel.promptTextInput
            inputData.loraWeights = viewModel.loraWeights
            inputData.selectedLoraOptions = viewModel.selectedLoraOptions
            inputData.loraIsEnableds = viewModel.loraIsEnableds
            inputData.imagebase64 = imageStr
            print("inputData: \(inputData)")
            if !inputData.changedValues().isEmpty{
                do {
                    try context.save()
                } catch {
                    print("Failed to saveForContentViewData settings: \(error)")
                }
            }
        } catch {
            print("Failed to load settings: \(error)")
        }
    }
    func loadSettingsContentViewData(data: ContentViewUserData? = nil) {
        if let settings = data {
            // 如果输入参数存在，直接从参数中读取数据
            updateViewModel(with: settings)
        } else {
            // 如果输入参数不存在，从CoreData中读取数据
            let context = CoreDataStack.shared.getContentViewDataModel.viewContext
            let UserInputLocalData: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
            
            do {
                let fetchedSettings = try context.fetch(UserInputLocalData)
                if let settings = fetchedSettings.first {
                    updateViewModel(with: settings)
                }
            } catch {
                print("Failed to load settings: \(error)")
            }
        }
    }
    
    func updateViewModel(with settings: ContentViewUserData) {
        viewModel.isAdditionNetworkChecked = settings.isAdditionNetworkChecked
        viewModel.batch_size = Int(settings.batch_size)
        viewModel.height = Int(settings.height)
        viewModel.width = Int(settings.width)
        viewModel.seed = Int(settings.seed)
        viewModel.selectedSamplerIndex = Int(settings.selectedSamplerIndex)
        viewModel.selectedModelIndex = Int(settings.selectedModelIndex)
        viewModel.steps = Int(settings.steps)
        viewModel.negativeTextInput = settings.negativeTextInput ?? ""
        viewModel.faceRestore = settings.faceRestore
        viewModel.promptTextInput = settings.promptTextInput ?? ""
        viewModel.loraWeights = settings.loraWeights ?? Array(repeating: 0, count: 5)
        viewModel.selectedLoraOptions = settings.selectedLoraOptions ?? Array(repeating: 0, count: 5)
        viewModel.loraIsEnableds = settings.loraIsEnableds ?? Array(repeating: false, count: 5)
        print("outputData: \(settings)")
    }
}
