import SwiftUI
import Photos
import AnyCodable

func requestPhotoLibraryAccess() {
    PHPhotoLibrary.requestAuthorization { status in
        switch status {
        case .authorized:
            print("授权成功！")
        case .denied, .restricted:
            print("授权失败！")
        case .notDetermined:
            print("未决定")
        case .limited:
            print("有限的访问权限")
        @unknown default:
            print("未知状态")
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = AppViewModel.viewModel
    
    @ObservedObject var appData = AppData.appData
    @Binding var selectedTab: Int
    @State private var textInput = ""
    @State private var negativeTextInput = ""
    @State private var statusMessage = "请连接"
    @State private var selectedOption = 0
    @State private var isToggleOn = false
    let options = ["Option 1", "Option 2", "Option 3"]
    
    @State private var selectedModelIndex = 0
    
    @State private var modelOptions: [String] = []
    @State private var loraModelOptions: [String] = []
    @State private var selectedModelOption = 0
    
    @State private var isAdditionNetworkChecked = false
    @State private var networkOptions: [String] = []
    @State private var loraWeights: [Float] = Array(repeating: 0, count: 5)
    @State private var selectedLoraOptions: [Int] = Array(repeating: 0, count: 5)
    @State private var loraIsEnableds: [Bool] = Array(repeating: false, count: 5)

    @State private var isSubmitting = false
    
    @State private var showAlertAfterSubmit = false
    @State private var showAlert = false
    @State private var showResultPage = false
    @State private var base64ImageData = ""
    
    @State private var navigateToResultPage = false
    @State private var isLoading = false
    @State private var isInit = false
    
    @State private var alertMessage = ""
    
    @State private var steps: Int = 50
    @State private var seed: Int = -1
    @State private var batch_size: Int = 1
    @State private var faceRestore: Bool = false
    @State private var width: Int = 512
    @State private var height: Int = 512
    
    @State private var showToast = false
    
    var widthOptions = [512, 768, 320]
    var heightOptions = [512, 768, 320]
    
    func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack{
                    VStack {
                        if isLoading {
                            VStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground).opacity(0.5))
                            .edgesIgnoringSafeArea(.all)
                        } else {
                            // 提示文字
                            Group{
                                Text(statusMessage)
                                .foregroundColor(statusMessage == "已经成功" ? .green : .orange)
                                .padding()
                                
                                // Model标签和下拉选择框
                                HStack {
                                    Text("Model:")
                                        .frame(width: 100, alignment: .leading)
                                    Picker(selection: $selectedModelIndex, label: Text("Select Model")) {
                                        ForEach(0..<viewModel.modelTitles.count, id: \.self) { index in
                                            Text(viewModel.modelTitles[index])
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 150)
                                }
                                .padding(.bottom)
                                
                                // Prompt 标签和输入框
                                HStack {
                                    Text("关键字")
                                        .frame(width: 100, alignment: .leading)
                                    TextEditor(text: $textInput)
                                }
                                .padding()
                                // Negative Prompt 标签和输入框
                                HStack {
                                    Text("反向关键字")
                                        .frame(width: 100, alignment: .leading)
                                    TextEditor(text: $negativeTextInput)
                                }
                                .padding()
                                HStack {
                                    Text("生成数量:")
                                    Picker("", selection: $batch_size) {
                                        ForEach(1...9, id: \.self) { number in
                                            Text("\(number)")
                                        }
                                    }
//                                    .pickerStyle(CompactDatePickerStyle())
                                    pickerStyle(WheelPickerStyle())
                                    .frame(width: 100)
                                }
                                .padding()
                            }
                            Group{
                                HStack {
                                    Text("精细度（1-150）")
                                    TextField("", value: $steps, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                                HStack {
                                    Text("种子（-1为随机）")
                                    TextField("", value: $seed, formatter: NumberFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                }
                                
                                Toggle(isOn: $faceRestore) {
                                    Text("面部修复")
                                }
                                HStack{
                                    HStack {
                                        Text("Width:")
                                        Picker("", selection: $width) {
                                            ForEach(widthOptions, id: \.self) { option in
                                                Text("\(option)")
                                            }
                                        }
                                    }
                                    Spacer()
                                        .pickerStyle(MenuPickerStyle())
                                    HStack {
                                        Text("Height:")
                                        Picker("", selection: $height) {
                                            ForEach(heightOptions, id: \.self) { option in
                                                Text("\(option)")
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Addition Network勾选框
                            Toggle("Addition Network", isOn: $isAdditionNetworkChecked)
                                .padding()
                            
                            // 子列表
                            if isAdditionNetworkChecked {
                                ForEach(0..<5) { index in
                                    VStack {
                                        HStack {
                                            Toggle("", isOn: $loraIsEnableds[index])
                                                .toggleStyle(CheckboxToggleStyle())
                                                .frame(width: 20)
                                            
                                            Text("Lora\(index + 1):")
                                                .frame(width: 80, alignment: .leading)
                                            Picker("Option", selection: $selectedLoraOptions[index]) {
                                                ForEach(0..<viewModel.loraModels.list.count, id: \.self) { index in
                                                    Text(viewModel.loraModels.list[index])
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .frame(width: 150)
                                        }
                                        // Weight{i}标签和横向滑块以及显示滑块值的标签
                                        HStack {
                                            Text("Weight\(index + 1):")
                                                .frame(width: 100, alignment: .leading)
                                            Slider(value: $loraWeights[index], in: 0...1)
                                            Text("\(loraWeights[index], specifier: "%.2f")")
                                        }
                                    }
                                    .padding(.bottom)
                                }
                                
                            }
                            
                            
                            // 提交按钮
                            Button(action: submit) {
                                Text("Submit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding()}
                    }
                    .overlay(isSubmitting ? ProgressView().scaleEffect(1.5) : nil)
                    .overlay(Group {
                        if showAlert {
                            AlertView(isPresented: $showAlert, title: "错误", message: alertMessage)
                        }
                    })
                }
                .onAppear {
                    if !isInit {
                        isLoading = true
                        AppViewModel.viewModel.fetchModelOptions {success, message in
                            if !success {
                                showAlert = true
                                alertMessage = message
                            }
                            else {
                                AppViewModel.viewModel.getOptions { success, message in
                                    if !success {
                                        showAlert = true
                                        alertMessage = message
                                    }
                                    else{
                                        AppViewModel.viewModel.getLoraModels { success, message in
                                            if !success {
                                                showAlert = true
                                                alertMessage = message
                                            }
                                            else{
                                                isInit = true
                                                isLoading = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                NavigationLink(destination: ResultPage(selectedTab: $selectedTab)) {
                    Text("跳转到结果页面")
                }
                .overlay(ToastView(showToast: $showToast))
                .hidden()
            }
        }
    }
    
    private func submit() {
        isSubmitting = true
        var body = txt2ImgRequestBody()
        body.prompt = textInput
        body.negative_prompt = negativeTextInput
        body.seed = seed
        body.steps = steps
        body.restore_faces = faceRestore
        body.width = width
        body.height = height
        body.override_settings["sd_model_checkpoint"] = viewModel.modelTitles[selectedModelIndex]
        body.batch_size = batch_size
        var loras: [String] {
            selectedLoraOptions.map { index in
                viewModel.loraModels.list[index]
            }
        }
        
        
        body.addArgs(isEnable: isAdditionNetworkChecked,loras: loras, weights: loraWeights, enableds: loraIsEnableds)
        print("这是输出的body : \(body)"  )
        NetworkManager.shared.sendtxt2ImgRequest(requestParameters: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let serverResponse):
                    print("Received server response: \(serverResponse)")
                    
                    // 更新UI或处理响应数据
                    var savedImages: [UIImage] = []
                    
                    // 将 serverResponse 中的 images 转换为 UIImage 数组
                    for base64String in serverResponse.images {
                        if let image = Utils.base64ToUIImage(base64String: base64String) {
                            savedImages.append(image)
                        }
                    }
                    
                    AppData.appData.resImages = []
                    AppData.appData.resImages.append(contentsOf: savedImages)
                    for item in savedImages {
                        if let imageURL = Utils.saveImageToDocumentsDirectory(item) {
                            AppData.appData.savedImages.append(imageURL)
                        }
                        saveImageToPhotoLibrary(item)
                    }
                    showToast = true
                    isSubmitting = false
                    selectedTab = 1
                case .failure(let error):
                    // 在此处处理错误，例如显示错误消息
                    showAlertAfterSubmit = true
                    isSubmitting = false
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedTab: .constant(0))
    }
}
