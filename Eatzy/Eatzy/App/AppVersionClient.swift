//
//  AppVersionClient.swift
//  Eatzy
//
//  Created by sun on 10/13/26.
//

import ComposableArchitecture
import Foundation

struct AppVersionClient {
    var fetchRequirement: @Sendable () async throws -> VersionRequirementResponseDTO
    var currentBuild: @Sendable () -> Int
    var appStoreURL: @Sendable () -> URL?
}

extension AppVersionClient: DependencyKey {
    static let liveValue = Self(
        fetchRequirement: {
            try await AppService().fetchVersionRequirement(platform: "ios")
        },
        currentBuild: {
            let value = Bundle.main.object(
                forInfoDictionaryKey: "CFBundleVersion"
            ) as? String
            return value.flatMap(Int.init) ?? 0
        },
        appStoreURL: {
            guard
                let value = Bundle.main.object(
                    forInfoDictionaryKey: "AppStoreURL"
                ) as? String,
                !value.isEmpty,
                !value.contains("$(")
            else {
                return nil
            }
            return URL(string: value)
        }
    )

    static let testValue = Self(
        fetchRequirement: {
            VersionRequirementResponseDTO(
                latestBuild: 1,
                minSupportedBuild: 1,
                platform: "ios"
            )
        },
        currentBuild: { 1 },
        appStoreURL: { nil }
    )
}

extension DependencyValues {
    var appVersionClient: AppVersionClient {
        get { self[AppVersionClient.self] }
        set { self[AppVersionClient.self] = newValue }
    }
}
