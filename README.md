📱 iOS E2EE Messaging Assignment (UIKit + Swift)
Welcome to the End-to-End Encrypted Messaging SDK Assignment for iOS. Your task is to build a secure, modular, and real-time messaging SDK in native iOS using Swift and UIKit, applying clean architecture principles and integrating end-to-end encryption and live communication features.

🎯 Assignment Overview
You will build an SDK to send encrypted messages in real-time and integrate it into a demo UIKit-based iOS app. The SDK should separate concerns (encryption, storage, networking) and be easily usable in other iOS projects.

✅ MUST: Core Requirements
1. 🧱 SDK Architecture (Clean Architecture)
Build the SDK using Clean Architecture principles:

Domain Layer: Entities and use cases (e.g., Message, SendMessageUseCase).

Data Layer: AES encryption logic, secure key storage, and real-time backend communication.

Presentation Layer: UIKit views and view controllers.

The SDK must be modular and framework-compatible for integration into other iOS apps.

2. 📡 Real-Time Messaging
Integrate a WebSocket-based service (e.g., Socket.IO or Supabase Realtime over WebSockets).

Enable:

Sending encrypted messages.

Receiving real-time updates.

Displaying message history from local/remote storage.

3. 📦 SDK Integration & Documentation
Provide:

Integration instructions (via Swift Package Manager or XCFramework).

Public APIs and usage examples.

A working UIKit demo app using the SDK.

🔹 OPTIONAL: Additional Enhancements
4. 🔐 Security Enhancements
Dynamic IV Generation: Generate a new initialization vector (IV) per message.

Secure Key Storage: Use Keychain Services to store keys.

Key Exchange: Implement Diffie-Hellman (DH) for symmetric key negotiation between peers (e.g., using CryptoKit).

5. 🧪 Testing
Achieve 75%+ test coverage:

Unit tests for AES encryption, decryption, key handling.

Integration tests for message sending/receiving.

Use XCTest.

6. 🎨 UI/UX Enhancements (UIKit)
Use MVVM or Coordinator pattern for better maintainability.

Create static views for:

Chat creation

User profile

Settings

Authentication (basic email/pass or biometrics)

Handle errors:

Invalid key input

Network failures

Decryption issues

7. 📱 Native Optimization
Ensure the app and SDK work smoothly on iOS devices (iPhone, iPad).

Optimize for:

Memory usage during encryption.

Responsiveness during real-time messaging.

Test on at least one real device.

⭐ BONUS: Advanced Challenges
8. ⚡ Performance Optimization
Measure performance for bulk encryption/decryption (e.g., 10,000 messages).

Use Instruments to profile memory and CPU usage.

Submit:

Profiling screenshots

A brief technical report of optimizations

📚 Documentation Requirements
Changelog: Track all notable changes (features, bug fixes, performance).

Usage Guide: Steps to use the SDK, including:

Setup

Key APIs

Integration into a demo app

Technical Notes:

Architecture choices

Cryptographic decisions

Performance observations

Additional Notes
Complete within 7 days.

Use Git with regular commits to reflect your development process.

Prioritize code quality, modularity, and security.

Use English throughout your codebase and documentation.
