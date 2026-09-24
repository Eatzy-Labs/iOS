//
//  SettingView.swift
//  Eatzy
//

import SwiftUI

struct SettingView: View {
    let onBackTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            EatzyNavigationBar(
                leading: .back(action: onBackTapped)
            )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.gray100)
    }
}

#Preview {
    SettingView {}
}
