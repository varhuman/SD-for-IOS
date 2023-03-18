//
//  MainView.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//

import SwiftUI
struct MainView: View {
    @State private var selectedTab = 0
    init() {
        requestPhotoLibraryAccess()
    }
    var body: some View {
        VStack{
            CustomNavigationBar(showInfoButton: true)
            BottomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
