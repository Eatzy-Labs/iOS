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
        var universityCode = ""
        var nationality = ""
        var preferredLanguage = "en"
        var termsAgreed = true
        var isLoading = false
        var errorMessage: String?

        var canContinueFromEmail: Bool {
            email.isValidEmail
        }

        var showsPasswordConfirmation: Bool {
            !password.isEmpty
        }

        var canCompleteSignUp: Bool {
            !password.isEmpty
                && password == confirmedPassword
                && !universityCode.isEmpty
                && !nationality.isEmpty
                && !isLoading
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
        case signUpResponse(Result<SignUpResponseDTO, NetworkError>)
        case loginResponse(Result<Void, NetworkError>)
        case backButtonTapped
        case delegate(Delegate)

        enum Delegate {
            case backToOnboarding
            case signUpCompleted
        }
    }

    @Dependency(\.signUpClient) private var signUpClient
    @Dependency(\.loginClient) private var loginClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                state.errorMessage = nil
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
                state.errorMessage = nil
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
                state.errorMessage = nil
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
                    state.isLoading = true
                    state.errorMessage = nil
                    let request = SignUpRequestDTO(
                        email: state.email,
                        nationality: state.nationality,
                        password: state.password,
                        preferredLanguage: state.preferredLanguage,
                        termsAgreed: state.termsAgreed,
                        universityCode: state.universityCode,
                        verificationToken: nil
                    )
                    return .run { send in
                        do {
                            let response = try await signUpClient.signUp(request)
                            await send(.signUpResponse(.success(response)))
                        } catch {
                            await send(
                                .signUpResponse(
                                    .failure(error as? NetworkError ?? .unknownError)
                                )
                            )
                        }
                    }
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

            case .signUpResponse(.success):
                let email = state.email
                let password = state.password
                return .run { send in
                    do {
                        try await loginClient.login(email, password)
                        await send(.loginResponse(.success(())))
                    } catch {
                        await send(
                            .loginResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .signUpResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.description
                return .none

            case .loginResponse(.success):
                state.isLoading = false
                return .send(.delegate(.signUpCompleted))

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Account created, but login failed. \(error.description)"
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
