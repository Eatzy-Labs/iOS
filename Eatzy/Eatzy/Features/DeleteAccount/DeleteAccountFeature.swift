//
//  DeleteAccountFeature.swift
//  Eatzy
//
//  Created by sun on 10/12/26.
//

import ComposableArchitecture
import Foundation

struct DeleteAccountFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        static let otherReason = "Other (please tell us)"
        static let reasons = [
            "My school or cafeteria isn’t supported",
            "Menu information is wrong or often missing",
            "I can’t trust the allergy or dietary info",
            "My dietary needs aren’t covered",
            "I no longer eat at the cafeteria",
            "The app is hard to use or has bugs",
            "I’m concerned about my privacy",
            otherReason
        ]

        var selectedReason: String?
        var otherReasonText = ""
        var otherReasonErrorMessage: String?

        var canDelete: Bool {
            selectedReason != nil
        }
    }

    enum Action {
        case backButtonTapped
        case reasonSelected(String?)
        case otherReasonChanged(String)
        case deleteAccountButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backRequested
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.backRequested))

            case let .reasonSelected(reason):
                state.selectedReason = reason
                state.otherReasonErrorMessage = nil
                return .none

            case let .otherReasonChanged(text):
                state.otherReasonText = text
                state.otherReasonErrorMessage = nil
                return .none

            case .deleteAccountButtonTapped:
                if state.selectedReason == State.otherReason,
                   state.otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.otherReasonErrorMessage = "Please enter content"
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
