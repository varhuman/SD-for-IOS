//
//  UserInputView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/19.
//

import SwiftUI

struct UserInputView: View {
    var widthHeightOptions = [512, 768, 320, 460]
    @ObservedObject var viewModel = AppViewModel.viewModel
    var body: some View {
        List{
            // 提示文字
            Group{
                // Model标签和下拉选择框
                Section(header: SectionImageHeader(symbolName: "filemenu.and.selection", title: "Model")){
                    if !viewModel.modelTitles.isEmpty{
                        NavigationLink(destination: PickerSelectionView(selectedIndex: $viewModel.selectedModelIndex, options: viewModel.modelTitles)) {
                            HStack {
                                SectionImageHeader(symbolName: "bolt.fill", title: "模型选择")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text("\(viewModel.modelTitles[viewModel.selectedModelIndex])")
                            }
                        }
                    }
                    NavigationLink(destination: PickerSelectionView(selectedIndex: $viewModel.selectedSamplerIndex, options: samplerOptions)) {
                        HStack {
                            Image(systemName: "circle.square")
                            Text("采样方法")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Text("\(samplerOptions[viewModel.selectedSamplerIndex])")
                        }
                    }
                }
                
                // Prompt 标签和输入框
                Section(header: SectionImageHeader(symbolName: "key", title: "关键字")){
                    HStack {
                        Text("正向")
                            .frame(width: 100, alignment: .leading)
                        Spacer()
                        TextEditor(text: $viewModel.promptTextInput)
                            .border(Color.gray, width: 1)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .frame(height: 80, alignment: .leading)
                    }
                    HStack {
                        Text("反向")
                            .frame(width: 100, alignment: .leading)
                        Spacer()
                        TextEditor(text: $viewModel.negativeTextInput)
                            .frame(height: 80, alignment: .leading)
                            .border(Color.gray, width: 1)
//                            .cornerRadius(20)
                    }
                }
                
                // Negative Prompt 标签和输入框
                Section(header: SectionImageHeader(symbolName: "number.circle.fill", title: "生成数量")) {
                    Picker("", selection: $viewModel.batch_size) {
                        ForEach(1...5, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            Group{
                Section(header: SectionImageHeader(symbolName: "pencil", title: "图形参数"))  {
                    HStackTextField(title: "精细度（1-150)", textFieldValue: $viewModel.steps)
                    HStackTextField(title: "种子（-1为随机）", textFieldValue: $viewModel.seed)
                    HStackToggle(title: "面部修复", isOn: $viewModel.faceRestore)
                    HStackPicker(title: "Width", textFieldValue: $viewModel.width, Options: widthHeightOptions)
                    HStackPicker(title: "Height", textFieldValue: $viewModel.height, Options: widthHeightOptions)
                }
            }
            Section(header: "Addition Network")
            {
                HStackToggle(title: "是否启用", isOn: $viewModel.isAdditionNetworkChecked)
                // 子列表
                if viewModel.isAdditionNetworkChecked {
                    ForEach(0..<5) { index in
                        VStack {
                            HStack {
                                Toggle("", isOn: $viewModel.loraIsEnableds[index])
                                    .toggleStyle(CheckboxToggleStyle())
                                    .frame(width: 20)
                                
                                Text("Lora\(index + 1):")
                                    .frame(width: 80, alignment: .leading)
                                Picker("", selection: $viewModel.selectedLoraOptions[index]) {
                                    ForEach(0..<viewModel.loraModels.list.count, id: \.self) { index in
                                        Text(viewModel.loraModels.list[index])
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            // Weight{i}标签和横向滑块以及显示滑块值的标签
                            HStack {
                                Text("Weight\(index + 1):")
                                    .frame(width: 100, alignment: .leading)
                                Slider(value: $viewModel.loraWeights[index], in: 0...1)
                                Text("\(viewModel.loraWeights[index], specifier: "%.2f")")
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct UserInputView_Previews: PreviewProvider {
    static var previews: some View {
        UserInputView()
    }
}
