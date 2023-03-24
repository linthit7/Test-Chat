//
//  TwilioConversationManager.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/22/23.
//

import UIKit
import TwilioConversationsClient

protocol TwilioConversationManagerDelegate: AnyObject {
    func reloadMessages()
    func receivedNewMessage()
}

class TwilioConversationManager: NSObject, TwilioConversationsClientDelegate {
    
    private let uniqueConversationName = "Test Chat"
    
    weak var delegate: TwilioConversationManagerDelegate?
    
    private var conversationClient: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private(set) var messages: [TCHMessage] = []
    private var identity: String?
    
    func conversationsClient(_ client: TwilioConversationsClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        
        guard status == .completed else { return }
        
        checkConversationCreation { (_, conversation) in
            if let conversation = conversation {
                self.joinConversation(conversation)
            } else {
                self.createConversation { (success, conversation) in
                    if success, let conversation = conversation {
                        self.joinConversation(conversation)
                    }
                }
            }
        }
    }
    
    func conversationsClient(_ client: TwilioConversationsClient, conversation: TCHConversation, messageAdded message: TCHMessage) {
        messages.append(message)
        
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadMessages()
                delegate.receivedNewMessage()
            }
        }
    }
    
    private func checkConversationCreation(_ completion: @escaping(TCHResult?, TCHConversation?) -> Void) {
        guard let client = conversationClient else { return }
        client.conversation(withSidOrUniqueName: uniqueConversationName) { (result, conversation) in
            completion(result, conversation)
        }
    }
    
    private func joinConversation(_ conversation: TCHConversation) {
        self.conversation = conversation
        if conversation.status == .joined {
            print("Current use already exists in conversation")
            self.loadPreviousMessages(conversation)
        } else {
            conversation.join { result in
                print("Result of conversation join: \(result.resultText ?? "No Result")")
                if result.isSuccessful {
                    self.loadPreviousMessages(conversation)
                }
            }
        }
    }
    
    private func loadPreviousMessages(_ conversation: TCHConversation) {
        conversation.getLastMessages(withCount: 100) { (result, messages) in
            if let messages = messages {
                self.messages = messages
                DispatchQueue.main.async {
                    self.delegate?.reloadMessages()
                }
            }
        }
    }
    
    private func createConversation(_ completion: @escaping(Bool, TCHConversation?) -> Void) {
        guard let conversationClient = conversationClient else { return }
        
        let options: [String: Any] = [
            TCHConversationOptionUniqueName: uniqueConversationName
        ]
        conversationClient.createConversation(options: options) { (result, conversation) in
            if result.isSuccessful {
                print("Conversation created")
            } else {
                print(result.error?.localizedDescription ?? "")
                print("Conversation cannot be created")
            }
            completion(result.isSuccessful, conversation)
        }
    }
    
    func sendMessage(_ messageText: String, completion: @escaping(TCHResult, TCHMessage?) -> Void) {
        
        let messageOptions = TCHMessageOptions().withBody(messageText)
        conversation?.sendMessage(with: messageOptions, completion: { (result, message) in
            completion(result, message)
        })
    }
    
    func loginWithAccessToken(_ token: String, completion: @escaping (Bool) -> Void) {
        TwilioConversationsClient.conversationsClient(withToken: token, properties: nil, delegate: self) { (result, conversationClient) in
            self.conversationClient = conversationClient
            
            if result.isSuccessful {
                completion(true)
            }
        }
        completion(false)
    }
    
    func shutdown() {
        if let conversationClient = conversationClient {
            conversationClient.delegate = nil
            conversationClient.shutdown()
            self.conversationClient = nil
        }
    }
}
