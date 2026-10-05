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
        var categoryOptions: [MapPlace.CategoryOption] = []
        var selectedCategory: MapPlace.Category = .all
        var isPlacesLoading = false
        var placesErrorMessage: String?
        var isCategoriesLoading = false
        var categoriesErrorMessage: String?
        var isPlaceDetailLoading = false
        var placeDetailErrorMessage: String?
        var isVisible = false
        var isPlaceSheetPresented = false
        var placeSheet = MapPlaceSheetFeature.State()

        var visiblePlaces: [MapPlace] {
            guard selectedCategory != .all else {
                return places
            }

            return places.filter { $0.category == selectedCategory }
        }

        var displayedCategoryOptions: [MapPlace.CategoryOption] {
            [.init(category: .all, title: "All")] + categoryOptions
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
        case categoriesRetryTapped
        case categoriesResponse(Result<PlaceCategoriesResponseDTO, NetworkError>)
        case universityButtonTapped
        case settingButtonTapped
        case categorySelected(MapPlace.Category)
        case markerTapped(MapPlace.ID)
        case placeDetailResponse(
            placeID: MapPlace.ID,
            Result<PlaceDetailResponseDTO, NetworkError>
        )
        case placeSheetPresentationChanged(Bool)
        case placeSheet(MapPlaceSheetFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case settingRequested
            case menuRequested(cafeteriaCode: String)
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
                var effects: [Effect<Action>] = []

                if !state.isPlacesLoading, state.places.isEmpty {
                    state.isPlacesLoading = true
                    state.placesErrorMessage = nil
                    let universityCode = state.universityCode
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .placesResponse(
                                        .success(
                                            try await mapClient.fetchPlaces(universityCode, nil)
                                        )
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
                    )
                }

                if !state.isCategoriesLoading, state.categoryOptions.isEmpty {
                    state.isCategoriesLoading = true
                    state.categoriesErrorMessage = nil
                    effects.append(
                        .run { send in
                            do {
                                await send(
                                    .categoriesResponse(
                                        .success(try await mapClient.fetchCategories())
                                    )
                                )
                            } catch {
                                await send(
                                    .categoriesResponse(
                                        .failure(error as? NetworkError ?? .unknownError)
                                    )
                                )
                            }
                        }
                    )
                }

                return .merge(effects)

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

            case .categoriesRetryTapped:
                state.categoryOptions = []
                state.isCategoriesLoading = false
                return .send(.viewAppeared)

            case let .categoriesResponse(.success(response)):
                state.isCategoriesLoading = false
                state.categoriesErrorMessage = nil
                state.categoryOptions = response.categories.compactMap(
                    MapPlace.CategoryOption.init
                )
                return .none

            case let .categoriesResponse(.failure(error)):
                state.isCategoriesLoading = false
                state.categoriesErrorMessage = error.description
                return .none

            case .universityButtonTapped:
                return .none

            case .settingButtonTapped:
                return .send(.delegate(.settingRequested))

            case let .categorySelected(category):
                state.selectedCategory = category
                return .none

            case let .markerTapped(placeID):
                state.isPlaceDetailLoading = true
                state.placeDetailErrorMessage = nil
                let universityCode = state.universityCode
                return .run { send in
                    do {
                        await send(
                            .placeDetailResponse(
                                placeID: placeID,
                                .success(
                                    try await mapClient.fetchPlaceDetail(
                                        universityCode,
                                        placeID
                                    )
                                )
                            )
                        )
                    } catch {
                        await send(
                            .placeDetailResponse(
                                placeID: placeID,
                                .failure(error as? NetworkError ?? .unknownError)
                            )
                        )
                    }
                }

            case let .placeDetailResponse(placeID, .success(response)):
                state.isPlaceDetailLoading = false
                state.placeDetailErrorMessage = nil
                guard
                    String(response.place.id) == placeID,
                    let place = MapPlace(response)
                else {
                    return .none
                }
                state.placeSheet.place = place
                state.isPlaceSheetPresented = true
                return .none

            case let .placeDetailResponse(_, .failure(error)):
                state.isPlaceDetailLoading = false
                state.placeDetailErrorMessage = error.description
                return .none

            case let .placeSheetPresentationChanged(isPresented):
                state.isPlaceSheetPresented = isPresented
                return .none

            case .placeSheet(.delegate(.dismissRequested)):
                state.isPlaceSheetPresented = false
                return .none

            case let .placeSheet(.delegate(.menuRequested(cafeteriaCode))):
                state.isPlaceSheetPresented = false
                return .send(.delegate(.menuRequested(cafeteriaCode: cafeteriaCode)))

            case .placeSheet:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
