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
    @IBOutlet weak var userImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImg.image = #imageLiteral(resourceName: "user")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
