//
//  TodayViewController.swift
//  Lynked Widget
//
//  Created by Matthew Howes Singleton on 6/24/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import NotificationCenter
import Kingfisher
import Firebase
import CoreMedia


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let WIDGET_CELL_IDENTIFIER = "widgetCell"
    var serviceArray = [[String : String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let groupDefaults = UserDefaults(suiteName: "group.Lynked")
        if let services = groupDefaults?.object(forKey: "services") as? [[String : String]] {
            serviceArray = services
            print(services)
            self.tableView.reloadData()
            signInLabel.isHidden = true
            completionHandler(NCUpdateResult.newData)
        } else {
            signInLabel.isHidden = false
            completionHandler(NCUpdateResult.noData)
        }
        
    }
    
}


extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(serviceArray.count, 2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WIDGET_CELL_IDENTIFIER, for: indexPath) as! WidgetTableViewCell
        
        let service = serviceArray[indexPath.row]
        if let serviceName = service["name"], let serviceURL = service["url"] {
            
            cell.serviceNameLabel.text = serviceName.capitalized
            cell.serviceDateLabel.text = service["date"]?.capitalized
            
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: serviceName))")
            if serviceURL.isEmpty == false {
                let myURLString: String = "https://logo.clearbit.com/\(serviceURL)"
                
                if let myURL = URL(string: myURLString) {
                    cell.serviceImageView.kf.setImage(with: myURL, placeholder: placeholderImage)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extensionContext?.open(URL(string: "Instagram://")! , completionHandler: nil)
    }
    
    
    
}
