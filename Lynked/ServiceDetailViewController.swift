//
//  ServiceDetailViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/21/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceDetailViewController: UIViewController {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var serviceBillingCurrentSwitch: UISwitch!
    @IBOutlet weak var serviceBillingCurrentLabel: UILabel!
    @IBOutlet weak var serviceUpdateBillingButton: UIButton!
    
    @IBOutlet weak var serviceTableView: UITableView!
    
    @IBOutlet weak var saveServiceButton: UIButton!
    @IBOutlet weak var deleteServiceButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    // MARK: - IB Actions
    
    @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func serviceUpdateBillingButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func saveServiceButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func deleteServiceButtonTapped(_ sender: UIButton) {
    }
    
    
    
} // MARK: - End of ServiceDetailViewController
