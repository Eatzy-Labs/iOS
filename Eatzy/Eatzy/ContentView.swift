//
//  ContentView.swift
//  Eatzy
//
//  Created by sun on 9/23/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            EatzyNavigationBar(
                leading: .title("TITLE"),
                trailing: [
                    .icon(.icBell, accessibilityLabel: "알림") {
                        print("알림 선택")
                    },
                    .icon(.icSetting, accessibilityLabel: "설정") {
                        print("설정 선택")
                    }
                ]
            )

            Spacer()
        }
        .background(.gray100)
    }
}

#Preview {
    ContentView()
}
