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
        var isConfirmationPresented = false
        var currentPassword = ""
        var passwordErrorMessage: String?
        var isDeleting = false

        var canDelete: Bool {
            selectedReason != nil
        }
    }

    enum Action {
        case backButtonTapped
        case reasonSelected(String?)
        case otherReasonChanged(String)
        case deleteAccountButtonTapped
        case confirmationCancelled
        case currentPasswordChanged(String)
        case deleteConfirmed
        case deleteResponse(Result<Void, NetworkError>)
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case deleteAccountCompleted
        }
    }

    @Dependency(\.deleteAccountClient) private var deleteAccountClient

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
                    return .none
                }
                state.currentPassword = ""
                state.passwordErrorMessage = nil
                state.isConfirmationPresented = true
                return .none

            case .confirmationCancelled:
                guard !state.isDeleting else { return .none }
                state.isConfirmationPresented = false
                state.currentPassword = ""
                state.passwordErrorMessage = nil
                return .none

            case let .currentPasswordChanged(password):
                state.currentPassword = password
                state.passwordErrorMessage = nil
                return .none

            case .deleteConfirmed:
                let password = state.currentPassword
                guard !password.isEmpty, !state.isDeleting else { return .none }
                state.isConfirmationPresented = false
                state.isDeleting = true
                return .run { send in
                    do {
                        try await deleteAccountClient.delete(password)
                        await send(.deleteResponse(.success(())))
                    } catch {
                        await send(
                            .deleteResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case .deleteResponse(.success):
                state.isDeleting = false
                state.isConfirmationPresented = false
                return .send(.delegate(.deleteAccountCompleted))

            case let .deleteResponse(.failure(error)):
                state.isDeleting = false
                if case let .apiError(code, _) = error,
                   code == "MEMBER_WRONG_PASSWORD" {
                    state.passwordErrorMessage = "Incorrect password. Please try again."
                } else {
                    state.passwordErrorMessage = error.description
                }
                state.isConfirmationPresented = true
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
