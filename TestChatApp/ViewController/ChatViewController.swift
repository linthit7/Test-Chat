//
//  ChatViewController.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/22/23.
//

import UIKit

class ChatViewController: UIViewController {
    
    var twilioConversationManager = TwilioConversationManager()
    var notificationObserver = NotificationObserver()
    
    @IBOutlet weak var chatCollectionView: UICollectionView!
    
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    deinit {
        removeNotificationCenterObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupDelegate()
        setupNotificationCenterObserver()
        registerCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loginWithTestAccessToken()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        twilioConversationManager.shutdown()
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async { [self] in
            chatTextField.resignFirstResponder()
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        twilioConversationManager.sendMessage(chatTextField.text!) { [self] (result, message) in
            if result.isSuccessful {
                chatTextField.text = ""
                chatTextField.resignFirstResponder()
            } else {
                displayErrorMessage("Unable to send message")
            }
        }
    }
    
    private func setupNotificationCenterObserver() {
        notificationObserver.addKeyboardWillShowAndHideObserver()
    }
    
    private func setupDelegate() {
        twilioConversationManager.delegate = self
        notificationObserver.delegate = self
        chatTextField.delegate = self
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
    }
    
    private func registerCell() {
        chatCollectionView.register(UINib(nibName: MessageCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: MessageCollectionViewCell.reuseIdentifier)
    }
    
    func loginWithTestAccessToken() {
        twilioConversationManager.loginWithAccessToken(TEST_ACCESS_TOKEN) { result in
            if result {
                DispatchQueue.main.async { [self] in
                    navigationItem.title = "Login Succeed"
                }
            } else {
                DispatchQueue.main.async { [self] in
                    navigationItem.title = "Login Failed"
                }
            }
        }
    }
    
    func scrollToBottomMessage() {
        if twilioConversationManager.messages.count == 0 {
            return
        }
        let bottomMessageIndex = IndexPath(row: twilioConversationManager.messages.count - 1,
                                           section: 0)
        chatCollectionView.scrollToItem(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
}

//MARK: - NotificationObserversDelegate

extension ChatViewController: NotificationObserverDelegate {
    
    func addKeyboardWillShowAndHideObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardWillShow(_ sender: NSNotification) {
        
        moveViewWithKeyboard(notification: sender, viewBottomConstraint: chatTextFieldBottomConstraint, keyboardWillShow: true)
        toggleSendButtonisHidden(false)
    }
    
    @objc
    func keyboardWillHide(_ sender: NSNotification) {
        
        moveViewWithKeyboard(notification: sender, viewBottomConstraint: chatTextFieldBottomConstraint, keyboardWillShow: false)
        toggleSendButtonisHidden(true)
    }
    
    func removeNotificationCenterObserver() { NotificationCenter.default.removeObserver(self) }
}

//MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return twilioConversationManager.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCollectionViewCell.reuseIdentifier, for: indexPath) as? MessageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let message = twilioConversationManager.messages[indexPath.row]
        cell.bodyLabel.text = message.body
        cell.authorLabel.text = message.author
        return cell
    }
}

// MARK: TwilioConversationManagerDelegate
extension ChatViewController: TwilioConversationManagerDelegate {
    func displayStatusMessage(_ statusMessage: String) {
        self.navigationItem.prompt = statusMessage
    }
    
    
    func displayErrorMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func reloadMessages() {
        self.chatCollectionView.reloadData()
    }

    // Scroll to bottom of table view for messages
    func receivedNewMessage() {
        scrollToBottomMessage()
    }
}



    


