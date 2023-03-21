//
//  CommitHistoryPage.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/20.
//

import SwiftUI

struct AnchorPreferenceKey: PreferenceKey {
    typealias Value = CGRect?
    static var defaultValue: Value = nil
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}



struct CommitHistoryPage: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var showPopover = false
    @State private var infoText = "Some text here"
    @State private var clickData: ContentViewUserData? = nil
    
//    @State private var isInfoPopoverShown: Bool = false

    @State private var popoverAnchor: CGRect? = nil
    @State private var ClickIndex: Int = 0

    @State private var historyData: [ContentViewUserData] = []
    
    @Binding var showCommitHistoryView: Bool
    
    var body: some View {
        ZStack{
            NavigationView {
                List {
                    ForEach(0..<historyData.count, id: \.self) { index in
                        ListItem(text: "第\(index + 1)次提交",data: historyData[index], showAlert: $showAlert,clickData: $clickData)
                    }
                    
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Confirm"),
                          message: Text("Are you sure you want to choose this item?"),
                          primaryButton: .default(Text("Yes"), action: {
                        showCommitHistoryView = false
                        CoreDataUtils.shared.loadSettingsContentViewData(data: clickData)
                        presentationMode.wrappedValue.dismiss()
                    }),
                          secondaryButton: .cancel(Text("No")))
                }
                .gesture(swipeGesture)
            }
            .navigationBarTitle("Sub View", displayMode: .inline)
            .onPreferenceChange(AnchorPreferenceKey.self) { value in
                if let rect = value {
                    popoverAnchor = rect
                }
            }
            .onAppear {
                historyData = CoreDataUtils.shared.fetchContentViewUserData()
            }
        }
    }
    
    var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width > 50 {
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
}
struct ListItem: View {
    var text: String
    var data: ContentViewUserData
    @State var isInfoPopoverShown : Bool = false
    @Binding var showAlert : Bool
    @Binding var clickData : ContentViewUserData?
    
    var body: some View {
        Button(action: {
            showAlert = true
            clickData = data
        }){
            HStack {
                Text(text)
                
                Button(action: {
                    isInfoPopoverShown.toggle()
                }) {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .alert(isPresented: $isInfoPopoverShown) {
                    Alert(title: Text("提交参数"), message: Text("\(data.description)"), dismissButton: .default(Text("ok")))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                let imageStr = data.imagebase64 ?? ""
                if let image = Utils.base64ToUIImage(base64String: imageStr) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                }
                //            Image(systemName: "arrow.right")
            }
        }
    }
}




struct CommitHistoryPage_Previews: PreviewProvider {
    static var previews: some View {
        CommitHistoryPage(showCommitHistoryView: .constant(true))
    }
}
