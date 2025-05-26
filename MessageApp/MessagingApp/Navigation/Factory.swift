//
//  Factory.swift
//  ReplaceNotificationCenterWithAdapter
//

import SwiftUI

final class Factory {
    private let userService = RemoteUserService()
    private var conversationViewModel: ConversationViewModel?
    
    let socketService = LocalSocketService()
    let messageService = RemoteMessageService()
    private var chatViewModel: ChatViewModel?
}

// Root
extension Factory {
    func createConversation(sender: String, didTapItem: @escaping (String, String) -> Void) -> some View {
        if conversationViewModel == nil {
            conversationViewModel = ConversationViewModel(sender: sender, service: userService, didTapItem: didTapItem)
        }
        
        guard let conversationViewModel = conversationViewModel else {
            fatalError("conversationViewModel need to be set before use ")
        }
        
        conversationViewModel.sender = sender
        
        return ConversationView(viewModel: conversationViewModel)
    }
    
    func createChat(sender: String, receiver: String) -> some View {
        if chatViewModel == nil {
            chatViewModel = ChatViewModel(sender: sender, receiver: receiver, service: socketService, messageService: messageService)
        }
        
        guard let chatViewModel = chatViewModel else {
            fatalError("chatViewModel need to be set before use ")
        }
        
        chatViewModel.sender = sender
        chatViewModel.receiver = receiver
        
        return ChatView(viewModel: chatViewModel)
    }
}

// Sub
extension Factory {
    
}
