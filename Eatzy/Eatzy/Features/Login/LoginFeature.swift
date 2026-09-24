//
//  LoginFeature.swift
//  Eatzy
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

        var isLoginEnabled: Bool {
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !password.isEmpty
        }
    }

    enum Action {
        case emailChanged(String)
        case emailFieldStateChanged(EatzyTextfield.State)
        case passwordChanged(String)
        case passwordFieldStateChanged(EatzyTextfield.State)
        case loginButtonTapped
        case signUpButtonTapped
        case guestButtonTapped
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .emailChanged(email):
            state.email = email
            state.emailFieldState = email.isEmpty ? .placeholder : .filled
            return .none

        case let .emailFieldStateChanged(fieldState):
            state.emailFieldState = fieldState
            return .none

        case let .passwordChanged(password):
            state.password = password
            state.passwordFieldState = password.isEmpty ? .placeholder : .filled
            return .none

        case let .passwordFieldStateChanged(fieldState):
            state.passwordFieldState = fieldState
            return .none

        case .loginButtonTapped:
            // API 연결 시 로그인 요청 Effect를 추가합니다.
            return .none

        case .signUpButtonTapped:
            return .none

        case .guestButtonTapped:
            return .none
        }
    }
}
