//
//  ProfileView.swift
//  Eatzy
//

import ComposableArchitecture
import PhotosUI
import SwiftUI

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(store.isEditing ? "EDIT" : "PROFILE")
                            .applyEatzyFont(.display_22_sb)
                            .foregroundStyle(.coreBlack)

                        profileImage
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)

                        profileFields
                            .padding(.top, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
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
        .photosPicker(
            isPresented: photoPickerPresentation,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else { return }
            let data = try? await selectedPhotoItem.loadTransferable(type: Data.self)
            store.send(.profileImageDataLoaded(data))
        }
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
    }
}

private extension ProfileView {
    @ViewBuilder
    var profileImage: some View {
        if store.isEditing {
            Button {
                store.send(.profileImageTapped)
            } label: {
                profileImageContent(fallback: .profileGray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select profile photo")
        } else {
            profileImageContent(fallback: .profile)
        }
    }

    @ViewBuilder
    func profileImageContent(fallback: ImageResource) -> some View {
        if let data = store.profileImageData,
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        } else {
            Image(fallback)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        }
    }

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
            readOnlyField(title: "ID", value: store.userID)
            readOnlyField(title: "Email", value: store.email)
            readOnlyField(title: "University", value: selectedUniversityTitle)
            readOnlyField(title: "Country", value: selectedCountryTitle)
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
            }

            fieldLabel("University") {
                EatzyDropdown(
                    title: selectedUniversityTitle,
                    options: ProfileMockData.universities,
                    selections: selectedUniversity
                )
            }

            fieldLabel("Country") {
                EatzyDropdown(
                    title: selectedCountryTitle,
                    options: ProfileMockData.countries,
                    selections: selectedCountry,
                    onExpansionChanged: {
                        store.send(.countryDropdownExpansionChanged($0))
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
        }
    }

    var userID: Binding<String> {
        Binding(
            get: { store.userID },
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
            get: { store.email },
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
            get: { store.selectedUniversity },
            set: { store.send(.universitySelectionChanged($0)) }
        )
    }

    var selectedCountry: Binding<Set<String>> {
        Binding(
            get: { store.selectedCountry },
            set: { store.send(.countrySelectionChanged($0)) }
        )
    }

    var photoPickerPresentation: Binding<Bool> {
        Binding(
            get: { store.isPhotoPickerPresented },
            set: { store.send(.photoPickerPresentationChanged($0)) }
        )
    }

    var discardAlertPresentation: Binding<Bool> {
        Binding(
            get: { store.isDiscardAlertPresented },
            set: { store.send(.discardAlertPresentationChanged($0)) }
        )
    }

    var selectedUniversityTitle: String {
        store.selectedUniversity.first ?? "Please Select"
    }

    var selectedCountryTitle: String {
        store.selectedCountry.first ?? "Please Select"
    }
}

#Preview {
    ProfileView(store: Store(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
}
