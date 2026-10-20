# OMI SDK Showcase App (iOS)

The **OMI SDK Showcase App** is the official successor to the Example App and serves as a fully featured demonstration of the **OMI SDK** for iOS. It is designed to help developers understand how to integrate, configure, and use the SDK in a real-world application.

Built entirely from scratch using **SwiftUI**, the app showcases modern iOS development practices while providing comprehensive coverage of the SDK’s functionality.

## Purpose

The Showcase App is intended to:
- Demonstrate the full functional surface of the OMI SDK
- Provide a practical, runnable reference implementation
- Accelerate developer onboarding and SDK adoption
- Illustrate recommended integration and architectural patterns

## Architecture & Design

- **SwiftUI-First Implementation**  
  The application is written entirely in SwiftUI, using declarative UI principles and state-driven design to keep the codebase clear, maintainable, and modern.

- **SDK-Aligned UX**  
  The user experience has been completely redesigned to mirror the structure and organization of the OMI SDK itself. Each section of the app corresponds directly to specific SDK modules and capabilities.

- **Modular Structure**  
  Features are presented in isolated, well-defined sections, making it easy to explore individual SDK components without unnecessary coupling.

## Feature Coverage

The Showcase App demonstrates all major functionalities provided by the OMI SDK, including but not limited to:

- Authentication and authorization flows
- Session and lifecycle management
- API interactions and SDK configuration
- Error handling and edge-case scenarios
- UI integration patterns where applicable

Each feature is presented with working examples that can be easily traced back to the underlying SDK APIs.

## Developer Experience

- **Hands-On Examples**  
  Developers can run the app and interact with real SDK flows instead of relying solely on isolated code snippets.

- **Reference Implementation**  
  The project goes beyond basic examples by demonstrating how to structure a production-ready SwiftUI application that integrates the OMI SDK.

- **Easy Exploration**  
  The app’s navigation and layout are optimized for discoverability, allowing developers to quickly locate relevant examples and patterns.

## Getting Started

Clone the repository, configure the required SDK credentials, and run the app to explore the OMI SDK in action. The Showcase App can be used as both a learning tool and a starting point for building your own applications.

---

This repository is intended as a companion to the OMI SDK documentation and should be used as a practical reference when integrating the SDK into your own iOS projects.

## Installation

### Setup access to the OneWelcome SPM repository
The OMI SDK Showcase App includes the SDK as SPM private repository. In order to let SPM download it you need to setup your account details so the SDK can be
automatically downloaded:
1. Make sure that you have access to the Thales CPL IAM Artifactory repository (thalescpliam.jfrog.io).
2. Follow [Setting up the project guide](https://thalesdocs.com/oip/omi-sdk/ios-sdk/ios-sdk-setup-project/index.html) in the SDK documentation for instructions on configuring access to the SPM/Cocoapods repository.
3. Set SPM registry with a following command:

`swift package-registry set --global https://thalescpliam.jfrog.io/artifactory/api/swift/swift-public --netrc`

## Providing token server configuration
The OMI SDK Showcase App is already configured with the backend (Access) out of the box.

### Changing the configuration
If there is a need to change the token server configuration within the example app it is going to be best to do it using the Onegini SDK Configurator. Follow
the steps as described in: `https://github.com/ThalesGroup/sdk-configurator`
