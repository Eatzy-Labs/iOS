//
//  MenuSheetFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MenuSheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedSectionID: String?
        var detail: MenuSheet

        init(
            selectedSectionID: String? = nil,
            detail: MenuSheet? = nil
        ) {
            self.selectedSectionID = selectedSectionID
            self.detail = detail ?? MenuSheetMockData.detail(for: selectedSectionID)
        }
    }

    enum Action {
        case dismissButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case dismissRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .dismissButtonTapped:
                return .send(.delegate(.dismissRequested))

            case .delegate:
                return .none
            }
        }
    }
}
