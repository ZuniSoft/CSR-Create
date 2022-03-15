// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "CSR Create",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "CSR Create",
            targets: ["AppModule"],
            bundleIdentifier: "com.zunisoft.ios.csrcreate",
            teamIdentifier: "S63L4926ND",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/cbaker6/CertificateSigningRequest.git", "1.28.0"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "CertificateSigningRequest", package: "CertificateSigningRequest")
            ],
            path: "."
        )
    ]
)