//
//  Loader.swift
//  gitTest
//
//  Created by Ankur Sehdev on 08/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

class Loader: UIView {
    
    let kLoader_XIB_NAME = "Loader"

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var title: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed(kLoader_XIB_NAME, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        if #available(iOS 11.0, *) {
            title.textColor = UIColor(named: "LabelText")
        } else {
            // Fallback on earlier versions
        }
    }
    func loaderMessage(message: String) {
        title.text = message
    }
    
}
