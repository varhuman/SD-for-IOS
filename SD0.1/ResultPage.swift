import SwiftUI

struct ResultPage: View {
    @Binding var selectedTab: Int
    @ObservedObject private var appData = AppData.appData
    var body: some View {
        VStack(){
            VStack {
                if appData.resImages.isEmpty {
                        VStack(spacing: 20) {
                            Text("请先前往生成页面生成图片")
                                .font(.title)

                            Button("To Submit") {
                                selectedTab = 0
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    } else {
                        ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(appData.resImages.indices, id: \.self) { index in
                                Image(uiImage: appData.resImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .padding(2)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle("结果页面", displayMode: .inline)
    }
}


struct ResultPage_Previews: PreviewProvider {
    static var previews: some View {
        ResultPage(selectedTab: .constant(1))
    }
}
