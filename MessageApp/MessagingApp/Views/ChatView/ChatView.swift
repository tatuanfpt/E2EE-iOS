//
//  ChatView.swift
//  MessagingApp
//
//  Created by Sam on 21/5/25.
//

import SwiftUI

import Combine

struct ChatView: View {
    @State private var lastContentOffset: CGFloat = 0
    @State private var isScrollingUp: Bool = false
    
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("Sender: \(viewModel.sender)")
            Text("Receiver: \(viewModel.receiver)")
            MessageListView(reachedTop: $viewModel.reachedTop, messages: $viewModel.messages, isFocused: $isFocused)
                .onTapGesture {
                    isFocused = false
                }
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .global).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) { newOffset in
                    isScrollingUp = newOffset > lastContentOffset  // Detect upward scroll
                    lastContentOffset = newOffset
                }
            MessageTextField() { text in
                viewModel.sendMessage(text)
            }
            .focused($isFocused)
            .padding()
        }
        .clipped()
        .onAppear {
            viewModel.subscribe()
            viewModel.fetchMessages()
        }
    }
    
    var loadMoreView: some View {
        GeometryReader { geo -> Color in
            let frame = geo.frame(in: .global)
            if frame.origin.y < UIScreen.main.bounds.height && frame.origin.y > 0 && isScrollingUp {
                DispatchQueue.main.async {
                    viewModel.loadMoreMessages()
                }
            }
            return Color.clear
        }
        .frame(height: 1)
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(sender: "slh", receiver: "", service: NullSocketService<String, TextMessage>(), messageService: NullMessageService()))
}
