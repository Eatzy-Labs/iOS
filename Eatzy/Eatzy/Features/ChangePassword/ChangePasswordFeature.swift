//
//  ChangePasswordFeature.swift
//  Eatzy
//
//  Created by sun on 10/11/26.
//

import ComposableArchitecture

struct ChangePasswordFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        enum Step: Equatable {
            case currentPassword
            case newPassword
        }

        var step: Step = .currentPassword
        var currentPassword = ""
        var currentPasswordFieldState = EatzyTextfield.State.placeholder
        var passwordChangeToken: String?
        var passwordChangeTokenExpiresAt: String?
        var isVerifyingCurrentPassword = false
        var newPassword = ""
        var newPasswordFieldState = EatzyTextfield.State.placeholder
        var isNewPasswordValidated = false
        var confirmedPassword = ""
        var confirmedPasswordFieldState = EatzyTextfield.State.placeholder
        var isChangingPassword = false

        var showsPasswordConfirmation: Bool {
            isNewPasswordValidated
        }

        var canConfirm: Bool {
            isNewPasswordValidated &&
                !confirmedPassword.isEmpty &&
                newPassword == confirmedPassword &&
                !isChangingPassword
        }
    }

    enum Action {
        case backButtonTapped
        case currentPasswordChanged(String)
        case currentPasswordFieldStateChanged(EatzyTextfield.State)
        case currentPasswordSubmitted
        case verifyPasswordResponse(Result<VerifyPasswordResponseDTO, NetworkError>)
        case newPasswordChanged(String)
        case newPasswordFieldStateChanged(EatzyTextfield.State)
        case newPasswordSubmitted
        case confirmedPasswordChanged(String)
        case confirmedPasswordFieldStateChanged(EatzyTextfield.State)
        case confirmedPasswordFocusChanged(Bool)
        case confirmButtonTapped
        case changePasswordResponse(Result<Void, NetworkError>)
        case delegate(Delegate)

        enum Delegate {
            case backRequested
            case passwordChanged
        }
    }

    @Dependency(\.usersClient) private var usersClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                if state.step == .newPassword {
                    state.step = .currentPassword
                    state.newPassword = ""
                    state.newPasswordFieldState = .placeholder
                    state.isNewPasswordValidated = false
                    state.confirmedPassword = ""
                    state.confirmedPasswordFieldState = .placeholder
                    state.passwordChangeToken = nil
                    state.passwordChangeTokenExpiresAt = nil
                    return .none
                }
                return .send(.delegate(.backRequested))

            case let .currentPasswordChanged(password):
                state.currentPassword = password
                state.currentPasswordFieldState = password.isEmpty ? .placeholder : .writing
                return .none

            case let .currentPasswordFieldStateChanged(fieldState):
                state.currentPasswordFieldState = fieldState
                return .none

            case .currentPasswordSubmitted:
                guard !state.currentPassword.isEmpty,
                      !state.isVerifyingCurrentPassword else { return .none }
                state.isVerifyingCurrentPassword = true
                return .run { [password = state.currentPassword] send in
                    do {
                        let response = try await usersClient.verifyPassword(
                            VerifyPasswordRequestDTO(currentPassword: password)
                        )
                        await send(.verifyPasswordResponse(.success(response)))
                    } catch {
                        await send(
                            .verifyPasswordResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .verifyPasswordResponse(.success(response)):
                state.isVerifyingCurrentPassword = false
                state.currentPasswordFieldState = .filled
                state.passwordChangeToken = response.passwordChangeToken
                state.passwordChangeTokenExpiresAt = response.expiresAt
                state.step = .newPassword
                return .none

            case let .verifyPasswordResponse(.failure(error)):
                state.isVerifyingCurrentPassword = false
                if case let .apiError(code, _) = error,
                   code == "MEMBER_WRONG_PASSWORD" {
                    state.currentPasswordFieldState = .error(
                        message: "Incorrect password. Please try again."
                    )
                } else {
                    state.currentPasswordFieldState = .error(message: error.description)
                }
                return .none

            case let .newPasswordChanged(password):
                state.newPassword = password
                state.isNewPasswordValidated = false
                state.newPasswordFieldState = password.isEmpty ? .placeholder : .writing
                state.confirmedPassword = ""
                state.confirmedPasswordFieldState = .placeholder
                return .none

            case let .newPasswordFieldStateChanged(fieldState):
                state.newPasswordFieldState = fieldState
                return .none

            case .newPasswordSubmitted:
                if let message = state.newPassword.passwordValidationErrorMessage {
                    state.newPasswordFieldState = .error(message: message)
                    state.isNewPasswordValidated = false
                } else {
                    state.newPasswordFieldState = .filled
                    state.isNewPasswordValidated = true
                }
                return .none

            case let .confirmedPasswordChanged(password):
                state.confirmedPassword = password
                state.confirmedPasswordFieldState = password.isEmpty ? .placeholder : .writing
                return .none

            case let .confirmedPasswordFieldStateChanged(fieldState):
                state.confirmedPasswordFieldState = fieldState
                return .none

            case let .confirmedPasswordFocusChanged(isFocused):
                guard !isFocused, !state.confirmedPassword.isEmpty else { return .none }
                state.confirmedPasswordFieldState = state.confirmedPassword == state.newPassword
                    ? .filled
                    : .error(message: "Passwords don’t match")
                return .none

            case .confirmButtonTapped:
                guard state.canConfirm,
                      let passwordChangeToken = state.passwordChangeToken else {
                    return .none
                }
                state.isChangingPassword = true
                return .run { [newPassword = state.newPassword] send in
                    do {
                        try await usersClient.changePassword(
                            ChangePasswordRequestDTO(
                                newPassword: newPassword,
                                passwordChangeToken: passwordChangeToken
                            )
                        )
                        await send(.changePasswordResponse(.success(())))
                    } catch {
                        await send(
                            .changePasswordResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case .changePasswordResponse(.success):
                state.isChangingPassword = false
                return .send(.delegate(.passwordChanged))

            case let .changePasswordResponse(.failure(error)):
                state.isChangingPassword = false
                if case let .apiError(code, _) = error {
                    switch code {
                    case "AUTH_WEAK_PASSWORD":
                        state.newPasswordFieldState = .error(message: error.description)
                    case "MEMBER_INVALID_PASSWORD_CHANGE_TOKEN":
                        state.step = .currentPassword
                        state.passwordChangeToken = nil
                        state.passwordChangeTokenExpiresAt = nil
                        state.currentPassword = ""
                        state.currentPasswordFieldState = .error(
                            message: "Password verification expired. Please try again."
                        )
                        state.newPassword = ""
                        state.confirmedPassword = ""
                        state.isNewPasswordValidated = false
                    default:
                        state.newPasswordFieldState = .error(message: error.description)
                    }
                } else {
                    state.newPasswordFieldState = .error(message: error.description)
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
