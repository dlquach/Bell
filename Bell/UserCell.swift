//
//  UserCell.swift
//  Bell
//
//  Created by Derek Quach on 12/6/15.
//  Copyright © 2015 Derek Quach. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}