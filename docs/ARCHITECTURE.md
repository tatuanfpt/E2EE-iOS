# Architecture Overview

## System Architecture

The E2EE Messaging App follows a client-server architecture with the following components:

### Server Side
- Node.js with Express.js
- Socket.IO for WebSocket communication
- SQLite database for data persistence
- RESTful API endpoints for user and message management

### iOS App
- SwiftUI for modern UI implementation
- MVVM architecture pattern
- WebSocket client for real-time communication
- Local storage for message history

## Component Structure

### Views (SwiftUI)
- Authentication views
- Chat list view
- Chat detail view
- Settings view

### ViewModels
- AuthenticationViewModel
- ChatListViewModel
- ChatDetailViewModel
- SettingsViewModel

### Services
- NetworkService
- EncryptionService
- StorageService
- WebSocketService

### Models
- User
- Message
- Chat
- EncryptionKey

## Data Flow

1. **Authentication Flow**
   - User credentials → AuthenticationService → Server
   - Server response → Local storage + Key generation

2. **Messaging Flow**
   - User input → EncryptionService → WebSocketService → Server
   - Server → WebSocketService → DecryptionService → UI

3. **Key Management**
   - Key generation on user registration
   - Key storage in secure storage
   - Key exchange during chat initialization

## Security Architecture

- End-to-End Encryption using AES
- Secure key storage using Keychain
- WebSocket secure connection
- Message encryption/decryption at client side 