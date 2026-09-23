//
//  ContentView.swift
//  Eatzy
//
//  Created by sun on 9/23/26.
//

import SwiftUI

struct ContentView: View {
    private let tabs = [
        "114(Cheomseong)",
        "305(Welfare)",
        "116(Info)",
        "408(Engineer)",
        "109(FastFood)",
        "103(GP)"
    ]

    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var selectedTab = "114(Cheomseong)"

    var body: some View {
        VStack(spacing: 0) {
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

            EatzyCallendar(selection: $selectedDate)
                .fixedSize(horizontal: false, vertical: true)

            EatzyTabBar(
                items: tabs,
                selection: $selectedTab,
                title: { $0 }
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray100)
    }
}

#Preview {
    ContentView()
}
