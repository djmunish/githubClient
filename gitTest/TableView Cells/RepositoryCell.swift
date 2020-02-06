//
//  RepositoryCell.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {

    @IBOutlet weak var repoIcon: UIImageView!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoTypeIcon: UIImageView!
    @IBOutlet weak var forkIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
