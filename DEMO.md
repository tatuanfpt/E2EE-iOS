# Demo Guide

This document outlines the steps to demonstrate the E2EE Messaging App functionality.

## Demo Recording
[Watch the demo video](https://youtu.be/E7nWm1vfdTE)

## Prerequisites

- Two simulators/devices ready
- Server running
- App installed on both devices

## Demo Steps

1. **Server Setup**
   - Start the JS server from terminal
   - Verify server is running

2. **User Login**
   - Launch app on first simulator
   - Login as User A
   - Launch app on second simulator
   - Login as User S

3. **Chat Channel**
   - Both users join the same chat channel: "A-S"
   - Verify channel connection

4. **Message Exchange**
   - User A sends a message
   - Verify encryption on server
   - User S receives and decrypts message
   - User S sends a response
   - Verify encryption/decryption process

## Expected Outcomes

- Messages are encrypted before transmission
- Only authorized users can decrypt messages
- Real-time message delivery
- Secure key management

## Troubleshooting

If issues occur:
1. Check server connection
2. Verify user authentication
3. Confirm key pair generation
4. Check channel connection 