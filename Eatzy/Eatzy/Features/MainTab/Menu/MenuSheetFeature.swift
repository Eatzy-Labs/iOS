//
//  MenuSheetFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MenuSheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedSectionID: String?

        init(selectedSectionID: String? = nil) {
            self.selectedSectionID = selectedSectionID
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
