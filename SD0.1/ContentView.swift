import SwiftUI
import Photos
import AnyCodable
import SwiftUIX

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
    @FetchRequest(entity: ContentViewUserData.entity(), sortDescriptors: [])
    var resTest: FetchedResults<ContentViewUserData>
    
    @Binding var selectedTab: Int
    @State private var statusMessage = "请连接"
    
    @State private var isSubmitting = false
    @State private var isLoading = false
    @State private var isInit = false
    
    @State private var showAlertAfterSubmit = false
    @State private var showAlert = false
    @State private var showResultPage = false
    
    @State private var alertMessage = ""
    @State private var showToast = false
    @State private var showToastMessage = "false"
    
    
    init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
    }

    var widthOptions = [512, 768, 320]
    var heightOptions = [512, 768, 320]
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                
                Text("加载中，请稍候...")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
    func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
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
                        ScrollView {
                            ZStack{
                                VStack {
                                    // 提示文字
                                    Group{
                                        Text(statusMessage)
                                            .foregroundColor(statusMessage == "已经成功" ? .green : .orange)
                                            .padding()
                                        
                                        // Model标签和下拉选择框
                                        
                                        NormalContainer<HStack>(title: ""){
                                            HStack {
                                                Text("Model:")
                                                    .frame(width: 100, alignment: .leading)
                                                Picker(selection: $viewModel.selectedModelIndex, label: Text("Select Model")) {
                                                    ForEach(0..<viewModel.modelTitles.count, id: \.self) { index in
                                                        Text(viewModel.modelTitles[index])
                                                    }
                                                }
                                                .pickerStyle(MenuPickerStyle())
                                                .frame(width: 150)
                                            }
                                        }
                                        .padding(.bottom)
                                        
                                        HStack {
                                            Text("采样方法")
                                                .font(.headline)
                                            
                                            Picker("Select Sampler", selection: $viewModel.selectedSamplerIndex) {
                                                ForEach(0..<samplerOptions.count, id: \.self) { index in
                                                    Text(samplerOptions[index].rawValue)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                        }
                                        
                                        
                                        // Prompt 标签和输入框
                                        NormalContainer<HStack>(title: ""){
                                            HStack {
                                                Text("关键字")
                                                    .frame(width: 100, alignment: .leading)
                                                TextEditor(text: $viewModel.promptTextInput)
                                            }
                                        }
                                        .padding()
                                        // Negative Prompt 标签和输入框
                                        HStack {
                                            Text("反向关键字")
                                                .frame(width: 100, alignment: .leading)
                                            TextEditor(text: $viewModel.negativeTextInput)
                                        }
                                        .padding()
                                        HStack {
                                            Text("生成数量:")
                                            Picker("", selection: $viewModel.batch_size) {
                                                ForEach(1...9, id: \.self) { number in
                                                    Text("\(number)")
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100)
                                        }
                                        .padding()
                                    }
                                    Group{
                                        HStack {
                                            Text("精细度（1-150）")
                                            TextField("", value: $viewModel.steps, formatter: NumberFormatter())
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.numberPad)
                                        }
                                        HStack {
                                            Text("种子（-1为随机）")
                                            TextField("", value: $viewModel.seed, formatter: NumberFormatter())
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .keyboardType(.numberPad)
                                        }
                                        
                                        Toggle(isOn: $viewModel.faceRestore) {
                                            Text("面部修复")
                                        }
                                        HStack{
                                            HStack {
                                                Text("Width:")
                                                Picker("", selection: $viewModel.width) {
                                                    ForEach(widthOptions, id: \.self) { option in
                                                        Text("\(option)")
                                                    }
                                                }
                                            }
                                            Spacer()
                                                .pickerStyle(MenuPickerStyle())
                                            HStack {
                                                Text("Height:")
                                                Picker("", selection: $viewModel.height) {
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
                                    Toggle("Addition Network", isOn: $viewModel.isAdditionNetworkChecked)
                                        .padding()
                                    
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
                                                    Picker("Option", selection: $viewModel.selectedLoraOptions[index]) {
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
                                                    Slider(value: $viewModel.loraWeights[index], in: 0...1)
                                                    Text("\(viewModel.loraWeights[index], specifier: "%.2f")")
                                                }
                                            }
                                            .padding(.bottom)
                                        }
                                        
                                    }
                                }
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
                                                            showToast = true
                                                            showToastMessage = message
                                                            CoreDataUtils.share.loadSettingsContentViewData()
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
                        
                        HStack{
                            // 提交按钮
                            Button(action: submit) {
                                Text("Submit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                }
                if isSubmitting {
                    loadingOverlay
                }
            }
            
        }
    }
    
    private func testSave() {
//        CoreDataUtils.share.deleteAllData(of:"ContentViewUserData")
//        CoreDataUtils.share.deleteAllData(of:"LoraUIData")
        CoreDataUtils.share.loadSettingsContentViewData()
//        let settings = resTest
//        ForEach(resTest, width: \.width)
//        viewModel.isAdditionNetworkChecked = settings.isAdditionNetworkChecked
//        viewModel.batch_size = Int(settings.batch_size)
//        viewModel.height = Int(settings.height)
//        viewModel.width = Int(settings.width)
//        viewModel.seed = Int(settings.seed)
//        viewModel.selectedSamplerIndex = Int(settings.selectedSamplerIndex)
//        viewModel.selectedModelIndex = Int(settings.selectedModelIndex)
//        viewModel.steps = Int(settings.steps)
//        viewModel.negativeTextInput = settings.negativeTextInput ?? ""
//        viewModel.faceRestore = settings.faceRestore
//        viewModel.promptTextInput = settings.promptTextInput ?? ""
    }
    private func submit() {
        isSubmitting = true
        var body = txt2ImgRequestBody()
        body.prompt = viewModel.promptTextInput
        body.negative_prompt = viewModel.negativeTextInput
        body.sampler_index = samplerOptions[viewModel.selectedSamplerIndex].rawValue
        body.seed = viewModel.seed
        body.steps = viewModel.steps
        body.restore_faces = viewModel.faceRestore
        body.width = viewModel.width
        body.height = viewModel.height
        body.override_settings.sd_model_checkpoint = viewModel.modelTitles[viewModel.selectedModelIndex]
        body.batch_size = viewModel.batch_size
        var loras: [String] {
            viewModel.selectedLoraOptions.map { index in
                viewModel.loraModels.list[index]
            }
        }
        
        body.addArgs(isEnable: viewModel.isAdditionNetworkChecked,loras: loras, weights: viewModel.loraWeights, enableds: viewModel.loraIsEnableds)
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
