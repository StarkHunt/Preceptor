//
//  HistoryTableViewCell.swift
//  imagepicker
//
//  Created by Sugat Nagavkar on 22/04/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var picture: UIImageView!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
