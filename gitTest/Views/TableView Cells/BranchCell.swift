//
//  BranchCell.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit


protocol BranchCellDelegate: class {
    func infoButtonPressed(_ cell: BranchCell)
}

class BranchCell: UITableViewCell {
    weak var delegate: BranchCellDelegate? = nil
    @IBOutlet weak var branchIcon: UIImageView!
    @IBOutlet weak var branchName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        delegate?.infoButtonPressed(self)
    }
    
}

extension UIImageView {
    func load(url: String) {
        guard let link = URL(string: url) else { return  }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: link) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
