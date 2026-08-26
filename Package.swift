// swift-tools-version:6.1
// (Xcode16.3+)

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
            targets: ["LiveKit"],
        ),
    ],
    dependencies: [
        // AES-256 fork (sigarone/client-sdk-swift): redirects to
        // sigarone/webrtc-xcframework's own aes256-livekit fork, which
        // points its binaryTarget at a LiveKitWebRTC.xcframework carrying
        // the aes256-framecryptor.patch — group-call media gets AES-256-GCM
        // instead of the fixed AES-128 FrameCryptor once a 32-byte shared
        // key is supplied.
        //
        // PINNED AT 144.7559.10-aes256-livekit, NOT the 144.7559.11 this
        // 2.16.0 rebase would otherwise pull in: upstream bumped the raw
        // WebRTC binary between .10 and .11 (different release checksum,
        // different underlying webrtc-sdk/webrtc-build source commit —
        // verified via `gh api .../compare`, not just a version-string
        // re-tag), and no aes256-livekit variant of .11 has been built yet
        // (that requires the full native rebuild pipeline in
        // BCRYPTO/webrtc-aes256-build/apple/, macOS+Xcode only, not
        // buildable from this session). Sources/LiveKit/E2EE/ has zero
        // overlap with the upstream 2.15.1..2.16.0 diff other than the
        // setKey(keyData:) overload upstream added itself (see
        // KeyProvider.swift's own comment on that function), so staying on
        // the .10 binary is safe for THIS release. Follow-up: rebuild+tag
        // 144.7559.11-aes256-livekit on a Mac, then bump this pin.
        //
        // 2026-08-26: still .10, but now the `-native-pli` variant — adds
        // native-pli.patch (W-NATIVEPLI, unconditional rate-limited
        // FrameCryptionState.kDecryptionFailed notification on a real
        // decrypt-tag-mismatch), ported from Android's 2026-08-25 AAR
        // rebuild to close the group-call iOS/Android parity gap. No
        // WebRTC source/version change, same reasoning above still holds.
        .package(url: "https://github.com/sigarone/webrtc-xcframework.git", exact: "144.7559.10-aes256-livekit-native-pli"),
        .package(url: "https://github.com/livekit/livekit-uniffi-xcframework.git", exact: "0.0.6"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.31.0"),
        // Only used for DocC generation
        .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "LKObjCHelpers",
            publicHeadersPath: "include",
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
        ),
        .target(
            name: "LiveKitTestSupport",
            dependencies: [
                "LiveKit",
            ],
            path: "Tests/LiveKitTestSupport",
        ),
        .testTarget(
            name: "LiveKitCoreTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
        .testTarget(
            name: "LiveKitAudioTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
        .testTarget(
            name: "LiveKitObjCTests",
            dependencies: [
                "LiveKit",
                "LiveKitTestSupport",
            ],
        ),
    ],
    swiftLanguageModes: [.v5, .v6],
)
