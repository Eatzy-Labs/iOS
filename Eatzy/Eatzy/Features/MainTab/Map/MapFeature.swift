//
//  MapFeature.swift
//  Eatzy
//

import ComposableArchitecture

struct MapFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var universityCode: String
        var selectedUniversity = "Kyungpook Univ"
        var places: [MapPlace] = []
        var selectedCategory: MapPlace.Category = .all
        var isPlacesLoading = false
        var placesErrorMessage: String?
        var isVisible = false
        var isPlaceSheetPresented = false
        var placeSheet = MapPlaceSheetFeature.State()

        var visiblePlaces: [MapPlace] {
            guard selectedCategory != .all else {
                return places
            }

            return places.filter { $0.category == selectedCategory }
        }

        init(universityCode: String = "knu") {
            self.universityCode = universityCode
        }
    }

    @CasePathable
    enum Action {
        case viewAppeared
        case placesRetryTapped
        case placesResponse(Result<PlacesResponseDTO, NetworkError>)
        case universityButtonTapped
        case settingButtonTapped
        case categorySelected(MapPlace.Category)
        case markerTapped(MapPlace.ID)
        case placeSheetPresentationChanged(Bool)
        case placeSheet(MapPlaceSheetFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case settingRequested
        }
    }

    @Dependency(\.mapClient) private var mapClient

    var body: some Reducer<State, Action> {
        Scope(state: \.placeSheet, action: \.placeSheet) {
            MapPlaceSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case .viewAppeared:
                state.isVisible = true
                guard !state.isPlacesLoading, state.places.isEmpty else {
                    return .none
                }
                state.isPlacesLoading = true
                state.placesErrorMessage = nil
                let universityCode = state.universityCode
                return .run { send in
                    do {
                        await send(
                            .placesResponse(
                                .success(try await mapClient.fetchPlaces(universityCode, nil))
                            )
                        )
                    } catch {
                        await send(
                            .placesResponse(
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case .placesRetryTapped:
                state.places = []
                state.isPlacesLoading = false
                return .send(.viewAppeared)

            case let .placesResponse(.success(response)):
                state.isPlacesLoading = false
                state.placesErrorMessage = nil
                state.places = response.places.compactMap(MapPlace.init)
                return .none

            case let .placesResponse(.failure(error)):
                state.isPlacesLoading = false
                state.placesErrorMessage = error.description
                state.places = []
                return .none

            case .universityButtonTapped:
                return .none

            case .settingButtonTapped:
                return .send(.delegate(.settingRequested))

            case let .categorySelected(category):
                state.selectedCategory = category
                return .none

            case let .markerTapped(placeID):
                state.placeSheet.place = state.places.first { $0.id == placeID }
                state.isPlaceSheetPresented = state.placeSheet.place != nil
                return .none

            case let .placeSheetPresentationChanged(isPresented):
                state.isPlaceSheetPresented = isPresented
                return .none

            case .placeSheet(.delegate(.dismissRequested)):
                state.isPlaceSheetPresented = false
                return .none

            case .placeSheet:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
