//
//  SignUpFeature.swift
//  Eatzy
//
//  Created by sun on 9/24/26.
//

import ComposableArchitecture
import Foundation

struct SignUpFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Step: Equatable {
            case email
            case password
        }

        var step: Step = .email
        var email = ""
        var emailFieldState = EatzyTextfield.State.placeholder
        var password = ""
        var passwordFieldState = EatzyTextfield.State.placeholder
        var confirmedPassword = ""
        var confirmedPasswordFieldState = EatzyTextfield.State.placeholder

        var canContinueFromEmail: Bool {
            email.isValidEmail
        }

        var showsPasswordConfirmation: Bool {
            !password.isEmpty
        }

        var canCompleteSignUp: Bool {
            !password.isEmpty && password == confirmedPassword
        }
    }

    enum Action {
        case emailChanged(String)
        case emailFieldStateChanged(EatzyTextfield.State)
        case passwordChanged(String)
        case passwordFieldStateChanged(EatzyTextfield.State)
        case confirmedPasswordChanged(String)
        case confirmedPasswordFieldStateChanged(EatzyTextfield.State)
        case continueButtonTapped
        case backButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backToOnboarding
            case signUpCompleted
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                if email.isEmpty {
                    state.emailFieldState = .placeholder
                } else if email.isValidEmail {
                    state.emailFieldState = .filled
                } else {
                    state.emailFieldState = .error(message: "Enter a valid email")
                }
                return .none

            case let .emailFieldStateChanged(fieldState):
                state.emailFieldState = fieldState
                return .none

            case let .passwordChanged(password):
                state.password = password
                state.passwordFieldState = password.isEmpty ? .placeholder : .filled

                if password.isEmpty {
                    state.confirmedPassword = ""
                    state.confirmedPasswordFieldState = .placeholder
                }
                return .none

            case let .passwordFieldStateChanged(fieldState):
                state.passwordFieldState = fieldState
                return .none

            case let .confirmedPasswordChanged(password):
                state.confirmedPassword = password
                state.confirmedPasswordFieldState = password.isEmpty ? .placeholder : .filled
                return .none

            case let .confirmedPasswordFieldStateChanged(fieldState):
                state.confirmedPasswordFieldState = fieldState
                return .none

            case .continueButtonTapped:
                switch state.step {
                case .email where state.canContinueFromEmail:
                    state.step = .password
                case .password where state.canCompleteSignUp:
                    return .send(.delegate(.signUpCompleted))
                default:
                    break
                }
                return .none

            case .backButtonTapped:
                switch state.step {
                case .email:
                    return .send(.delegate(.backToOnboarding))
                case .password:
                    state.step = .email
                    return .none
                }

            case .delegate:
                return .none
            }
        }
    }
}
