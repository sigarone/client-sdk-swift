// swift-tools-version:5.9
// (Xcode15.0+)

import PackageDescription

let package = Package(
    name: "LiveKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v14),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "LiveKit",
            targets: ["LiveKit"]
        ),
    ],
    dependencies: [
        // LK-Prefixed Dynamic WebRTC XCFramework
        // AES-256 fork (sigarone/client-sdk-swift, branch/tag aes256-livekit /
        // 2.13.0-aes256-livekit): redirects to sigarone/webrtc-xcframework's
        // own aes256-livekit fork (tag 144.7559.03-aes256-livekit), which
        // points its binaryTarget at a LiveKitWebRTC.xcframework carrying the
        // aes256-framecryptor.patch — group-call media gets AES-256-GCM
        // instead of the fixed AES-128 FrameCryptor once a 32-byte shared
        // key is supplied. Everything else in this file is untouched from
        // upstream 2.13.0.
        .package(url: "https://github.com/sigarone/webrtc-xcframework.git", exact: "144.7559.03-aes256-livekit"),
        .package(url: "https://github.com/livekit/livekit-uniffi-xcframework.git", exact: "0.0.5"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.31.0"),
        // Only used for DocC generation
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "LKObjCHelpers",
            publicHeadersPath: "include"
        ),
        .target(
            name: "LiveKit",
            dependencies: [
                .product(name: "LiveKitWebRTC", package: "webrtc-xcframework"),
                .product(name: "LiveKitUniFFI", package: "livekit-uniffi-xcframework"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "LKObjCHelpers",
            ],
            exclude: [
                "Broadcast/NOTICE",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),
        .target(
            name: "LiveKitTestSupport",
            dependencies: [
                "LiveKit",
            ],
            path: "Tests/LiveKitTestSupport"
        ),
        .testTarget(
            name: "LiveKitCoreTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ]
        ),
        .testTarget(
            name: "LiveKitAudioTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ]
        ),
        .testTarget(
            name: "LiveKitObjCTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ]
        ),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
