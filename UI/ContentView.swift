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
    
    @State private var showTemplateView = false
    @State private var showCommitHistoryView = false
    
    
    init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                
                Text("正在生成图片，请等待...")
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
                        UserInputView()
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
                            
                            Button(action: {
                                withAnimation {
                                    showTemplateView = true
                                }
                            }) {
                                Text("Template")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                showCommitHistoryView.toggle()
                            }) {
                                Text("Open Sub View")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .background(NavigationLink("", destination: CommitHistoryPage(showCommitHistoryView: $showCommitHistoryView), isActive: $showCommitHistoryView).opacity(0))
                        }
                    }
                }
                .overlay(Group {
                    if showAlert {
                        AlertView(isPresented: $showAlert, title: "错误", message: alertMessage)
                    }
                })
                if isSubmitting {
                    loadingOverlay
                }
                if showTemplateView {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showTemplateView = false
                            }
                        }
                    TemplateModelView(showView: $showTemplateView)
                }
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
                                            CoreDataUtils.shared.loadSettingsContentViewData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
//                .overlay(ToastView(showToast: $showToast))
            }
            
        }
    }
    
    private func testSave() {
//        CoreDataUtils.share.deleteAllData(of:"ContentViewUserData")
//        CoreDataUtils.share.deleteAllData(of:"LoraUIData")
        CoreDataUtils.shared.loadSettingsContentViewData()
    }
    private func submit() {
        isSubmitting = true
        var body = txt2ImgRequestBody()
        body.prompt = viewModel.promptTextInput
        body.negative_prompt = viewModel.negativeTextInput
        body.sampler_index = samplerOptions[viewModel.selectedSamplerIndex]
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
                    CoreDataUtils.shared.saveForSubmit(image: savedImages.first)
                case .failure(let error):
                    // 在此处处理错误，例如显示错误消息
                    showAlertAfterSubmit = true
                    isSubmitting = false
                    print("Request failed with error: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedTab: .constant(0))
    }
}
