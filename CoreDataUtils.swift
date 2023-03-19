//
//  CoreDataUtils.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/19.
//

import Foundation

import CoreData

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
    
    static let share = CoreDataUtils()
    
    func printLoraData(loraData: LoraUIData) {
        print("loraData: \(String(describing: loraData))")
        
        if let loraWeights = loraData.loraWeights {
            print("loraWeights: \(loraWeights)")
        } else {
            print("loraWeights: unable to print")
        }
        
        if let selectedLoraOptions = loraData.selectedLoraOptions {
            print("selectedLoraOptions: \(selectedLoraOptions)")
        } else {
            print("selectedLoraOptions: unable to print")
        }
        
        if let loraIsEnableds = loraData.loraIsEnableds {
            print("loraIsEnableds: \(loraIsEnableds)")
        } else {
            print("loraIsEnableds: unable to print")
        }
    }
    
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


    
    func saveForLoraData() {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let loraDataFetch: NSFetchRequest<LoraUIData> = LoraUIData.fetchRequest()
        do {
            let fetchedSettings = try context.fetch(loraDataFetch)
            let loraData = fetchedSettings.first ?? LoraUIData(context: context)
            
            loraData.loraWeights = viewModel.loraWeights
            loraData.selectedLoraOptions = viewModel.selectedLoraOptions
            loraData.loraIsEnableds = viewModel.loraIsEnableds
            
            if !loraData.changedValues().isEmpty {
                do {
                    try context.save()
                } catch {
                    print("Failed to saveForLoraData settings: \(error)")
                }
            }
        } catch {
            print("Failed to load settings: \(error)")
        }
    }
    
    func saveForContentViewData() {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let UserInputLocalData: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
        do {
            let fetchedSettings = try context.fetch(UserInputLocalData)
            let inputData = fetchedSettings.first ?? ContentViewUserData(context: context)
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
    func loadSettingsContentViewData() {
        let context = CoreDataStack.shared.getContentViewDataModel.viewContext
        let loraLocalData: NSFetchRequest<LoraUIData> = LoraUIData.fetchRequest()
  
        let UserInputLocalData: NSFetchRequest<ContentViewUserData> = ContentViewUserData.fetchRequest()
        
        do {
            let fetchedSettings = try context.fetch(loraLocalData)
//            ForEach(fetchedSettings){index in
//                print("THHIIS : FUCKING\(index): \(fetchedSettings[index])")
//            }
            fetchedSettings.forEach({item in
                print("THHIIS : FUCKING: \(item)")
            })
            if let settings = fetchedSettings.first {
                printLoraData(loraData: settings)
                viewModel.loraWeights = settings.loraWeights ?? Array(repeating: 0, count: 5)
                viewModel.selectedLoraOptions = settings.selectedLoraOptions ?? Array(repeating: 0, count: 5)
                viewModel.loraIsEnableds = settings.loraIsEnableds ?? Array(repeating: false, count: 5)
            }
        } catch {
            print("Failed to load settings: \(error)")
        }
        
        do {
            let fetchedSettings = try context.fetch(UserInputLocalData)
            if let settings = fetchedSettings.first {
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
                print("outputData: \(settings)")
            }
        } catch {
            print("Failed to load settings: \(error)")
        }
    }


}
