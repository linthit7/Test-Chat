//
//  NotificationObservers.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/23/23.
//

import UIKit

@objc protocol NotificationObserverDelegate: AnyObject {
    func addKeyboardWillShowAndHideObserver()
    @objc func keyboardWillShow(_ sender: NSNotification)
    @objc func keyboardWillHide(_ sender: NSNotification)
    func removeNotificationCenterObserver()
}

class NotificationObserver: NSObject {
    
    weak var delegate: NotificationObserverDelegate?
    
    func addKeyboardWillShowAndHideObserver() { delegate?.addKeyboardWillShowAndHideObserver() }
    
}
