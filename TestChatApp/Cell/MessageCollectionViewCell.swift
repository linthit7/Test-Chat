//
//  MessageCollectionViewCell.swift
//  TestChatApp
//
//  Created by Lin Thit Khant on 3/24/23.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: MessageCollectionViewCell.self)

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func createMessageCell(_ body: String, _ author: String) {
        DispatchQueue.main.async { [self] in
            bodyLabel.text = body
            authorLabel.text = author
        }
    }

}
