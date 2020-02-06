//
//  PullRequestCell.swift
//  gitTest
//
//  Created by Ankur Sehdev on 06/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

class PullRequestCell: UITableViewCell {

    @IBOutlet weak var prLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
