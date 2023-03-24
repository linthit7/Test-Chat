//
//  ChatViewController+TextField.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/23/23.
//

import UIKit

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async { [self] in
            chatTextField.resignFirstResponder()
        }
        return true
    }
}

extension ChatViewController {
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: NSLayoutConstraint, keyboardWillShow: Bool) {
            // Keyboard's size
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            let keyboardHeight = keyboardSize.height
            
            // Keyboard's animation duration
            let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            
            // Keyboard's animation curve
            let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
            
            // Change the constant
            if keyboardWillShow {
                let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // Check if safe area exists
                let bottomConstant: CGFloat = 16
                viewBottomConstraint.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
            }else {
                viewBottomConstraint.constant = 16
            }
            
            // Animate the view the same way the keyboard animates
            let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
                // Update Constraints
                self?.view.layoutIfNeeded()
            }
            // Perform the animation
            animator.startAnimation()
        }
    
    func toggleSendButtonisHidden(_ state: Bool) {
        
        let startingPointForSendButton = CGPoint(x: sendButton.center.x + 100, y: sendButton.center.y)
        let endingPointForSendButton = sendButton.center
        
        if state {
            DispatchQueue.main.async { [self] in
                sendButton.isHidden = state
            }
        } else {
            DispatchQueue.main.async { [self] in
                sendButton.isHidden = state
                sendButton.center = startingPointForSendButton
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut]) { [self] in
                    sendButton.center = endingPointForSendButton
                }
            }
        }
    }
}

