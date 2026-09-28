//
//  LoginFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct LoginFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var email = ""
        var emailFieldState = EatzyTextfield.State.placeholder
        var password = ""
        var passwordFieldState = EatzyTextfield.State.placeholder
        var isLoading = false
        var errorMessage: String?

        var isLoginEnabled: Bool {
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !password.isEmpty
                && !isLoading
        }
    }

    enum Action {
        case emailChanged(String)
        case emailFieldStateChanged(EatzyTextfield.State)
        case passwordChanged(String)
        case passwordFieldStateChanged(EatzyTextfield.State)
        case loginButtonTapped
        case loginResponse(Result<Void, NetworkError>)
        case signUpButtonTapped
        case guestButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case loginCompleted
        }
    }

    @Dependency(\.loginClient) private var loginClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                state.errorMessage = nil
                state.emailFieldState = email.isEmpty ? .placeholder : .filled
                return .none

            case let .emailFieldStateChanged(fieldState):
                state.emailFieldState = fieldState
                return .none

            case let .passwordChanged(password):
                state.password = password
                state.errorMessage = nil
                state.passwordFieldState = password.isEmpty ? .placeholder : .filled
                return .none

            case let .passwordFieldStateChanged(fieldState):
                state.passwordFieldState = fieldState
                return .none

            case .loginButtonTapped:
                guard state.isLoginEnabled else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                let loginID = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = state.password
                return .run { send in
                    do {
                        try await loginClient.login(loginID, password)
                        await send(.loginResponse(.success(())))
                    } catch {
                        await send(
                            .loginResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case .loginResponse(.success):
                state.isLoading = false
                return .send(.delegate(.loginCompleted))

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.description
                return .none

            case .signUpButtonTapped:
                return .none

            case .guestButtonTapped:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
