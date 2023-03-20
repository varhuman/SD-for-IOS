//
//  BottomTabBar.swift
//  SD0.1
//
//  Created by CreepOnSky on 2023/3/17.
//

import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: Int
    @StateObject private var appData = AppData()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("输入")
                }
                .tag(0)
            
            ResultPage(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("输出")
                }
                .tag(1)
            
            HistoryPage(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "3.circle")
                    Text("历史")
                }
                .tag(2)
            
            testForAnyView()
                .tabItem {
                    Image(systemName: "4.circle")
                    Text("Font")
                }
                .tag(3)
        }
    }
}


struct BottomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        BottomTabBar(selectedTab: .constant(3))
    }
}
