//
//  ProfileView.swift
//  Eatzy
//

import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(store.isEditing ? "EDIT" : "PROFILE")
                            .applyEatzyFont(.display_22_sb)
                            .foregroundStyle(.coreBlack)
                            .padding(.vertical, 40)

                        profileFields
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .onChange(of: store.isCountryDropdownExpanded) { _, isExpanded in
                    guard isExpanded else { return }

                    Task { @MainActor in
                        await Task.yield()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo("countryDropdown", anchor: .top)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.coreWhite)
        .hideKeyboardOnBackgroundTap()
        .alert(
            "Discard changes?",
            isPresented: discardAlertPresentation
        ) {
            Button("Cancel", role: .cancel) {
                store.send(.cancelDiscardButtonTapped)
            }

            Button("Discard", role: .destructive) {
                store.send(.discardChangesButtonTapped)
            }
        } message: {
            Text("Your changes will not be saved")
        }
        .alert(
            "Unable to save changes",
            isPresented: saveErrorPresentation
        ) {
            Button("OK") {
                store.send(.saveErrorDismissed)
            }
        } message: {
            Text(store.saveErrorMessage ?? "")
        }
    }
}

private extension ProfileView {
    var navigationBar: some View {
        EatzyNavigationBar(
            leading: .back {
                store.send(.backButtonTapped)
            },
            trailing: store.isEditing
                ? [
                    .text("Done", color: .orange500) {
                        store.send(.doneButtonTapped)
                    }
                ]
                : [
                    .icon(.icEdit, accessibilityLabel: "Edit profile") {
                        store.send(.editButtonTapped)
                    }
                ]
        )
    }

    @ViewBuilder
    var profileFields: some View {
        if store.isEditing {
            editFields
        } else {
            readOnlyFields
        }
    }

    var readOnlyFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            readOnlyField(title: "ID", value: store.profile.userID)
            readOnlyField(title: "Email", value: store.profile.email)
            readOnlyField(title: "University", value: store.profile.university)
            readOnlyField(title: "Country", value: store.profile.country)
        }
    }

    var editFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            fieldLabel("ID") {
                EatzyTextfield(
                    text: userID,
                    state: idFieldState,
                    placeholder: "Type here",
                    maximumLength: 15
                )
            }

            fieldLabel("Email") {
                EatzyTextfield(
                    text: email,
                    state: emailFieldState,
                    placeholder: "Type here",
                    maximumLength: 50,
                    showsCounter: false,
                    keyboardType: .emailAddress
                )
                .disabled(true)
            }

            fieldLabel("University") {
                EatzyDropdown(
                    title: selectedUniversityTitle,
                    options: store.universities,
                    selections: selectedUniversity
                )
                .disabled(true)
            }

            fieldLabel("Country") {
                EatzyDropdown(
                    title: selectedCountryTitle,
                    options: store.countries.map(\.code),
                    selections: selectedCountry,
                    onExpansionChanged: {
                        store.send(.countryDropdownExpansionChanged($0))
                    },
                    optionTitle: { code in
                        store.countries.first(where: { $0.code == code })?.name ?? code
                    }
                )
            }
            .id("countryDropdown")
        }
    }

    func readOnlyField(title: String, value: String) -> some View {
        fieldLabel(title) {
            ProfileInfoField(value: value)
        }
    }

    func fieldLabel<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .applyEatzyFont(.display_16_sb)
                .foregroundStyle(.gray900)

            content()
                .padding(.horizontal, -4)
        }
    }

    var userID: Binding<String> {
        Binding(
            get: { store.draft.userID },
            set: { store.send(.userIDChanged($0)) }
        )
    }

    var idFieldState: Binding<EatzyTextfield.State> {
        Binding(
            get: { store.idFieldState },
            set: { store.send(.idFieldStateChanged($0)) }
        )
    }

    var email: Binding<String> {
        Binding(
            get: { store.draft.email },
            set: { store.send(.emailChanged($0)) }
        )
    }

    var emailFieldState: Binding<EatzyTextfield.State> {
        Binding(
            get: { store.emailFieldState },
            set: { store.send(.emailFieldStateChanged($0)) }
        )
    }

    var selectedUniversity: Binding<Set<String>> {
        Binding(
            get: { [store.draft.university] },
            set: { store.send(.universitySelectionChanged($0)) }
        )
    }

    var selectedCountry: Binding<Set<String>> {
        Binding(
            get: { [store.draftNationalityCode] },
            set: { store.send(.countrySelectionChanged($0)) }
        )
    }

    var discardAlertPresentation: Binding<Bool> {
        Binding(
            get: { store.isDiscardAlertPresented },
            set: { store.send(.discardAlertPresentationChanged($0)) }
        )
    }

    var saveErrorPresentation: Binding<Bool> {
        Binding(
            get: { store.saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    store.send(.saveErrorDismissed)
                }
            }
        )
    }

    var selectedUniversityTitle: String {
        store.draft.university.isEmpty ? "Please Select" : store.draft.university
    }

    var selectedCountryTitle: String {
        guard !store.draftNationalityCode.isEmpty else { return "Please Select" }
        return store.countries.first {
            $0.code == store.draftNationalityCode
        }?.name ?? store.draftNationalityCode
    }

}

#Preview {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
}
