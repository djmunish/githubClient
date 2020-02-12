//
//  PopupView.swift
//  gitTest
//
//  Created by Ankur Sehdev on 05/02/20.
//  Copyright © 2020 Munish. All rights reserved.
//

import UIKit

protocol PopUpViewDelegate : class{
    func closeButtonPressed(_ sender: Any)
}

class PopupView: UIView {
    weak var delegate: PopUpViewDelegate? = nil

    let kCONTENT_XIB_NAME = "PopupView"
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var shaLbl: UILabel!
    @IBOutlet weak var messageLblPlcHolder: UILabel!
    @IBOutlet weak var shaLblPlcHolder: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        if #available(iOS 11.0, *) {
            shaLblPlcHolder.textColor = UIColor(named: "LabelText")
            messageLbl.textColor = UIColor(named: "LabelText")
            shaLbl.textColor = UIColor(named: "LabelText")
            messageLblPlcHolder.textColor = UIColor(named: "LabelText")
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func showData(){
        messageLblPlcHolder.isHidden = false
        shaLblPlcHolder.isHidden = false
        messageLbl.isHidden = false
        shaLbl.isHidden = false
    }
    func hideData(){
        messageLblPlcHolder.isHidden = true
        shaLblPlcHolder.isHidden = true
        messageLbl.isHidden = true
        shaLbl.isHidden = true
    }
        
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        delegate?.closeButtonPressed(sender)
    }
        
}
