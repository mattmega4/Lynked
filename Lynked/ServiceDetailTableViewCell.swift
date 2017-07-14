//
//  ServiceDetailTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/24/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit


class ServiceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceTitleLabel: UILabel!
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var fixedToggleSwitch: UISwitch?
    
    var delegate: ServiceDetailTableViewCellDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func amountTextFieldActive(_ sender: UITextField) {
        if fixedToggleSwitch?.isHidden == false {
            if let amountString = sender.text?.currencyInputFormatting() {
                sender.text = amountString
            }
        }
    }
    
    @IBAction func serviceFixedSwitched(_ sender: UISwitch) {
        delegate?.serviceDetailTableViewCell(cell: self, didChangeFixedSwitch: sender)
    }

}


protocol ServiceDetailTableViewCellDelegate {
    
    func serviceDetailTableViewCell(cell: ServiceDetailTableViewCell, didChangeFixedSwitch fixedSwitch: UISwitch)
}

