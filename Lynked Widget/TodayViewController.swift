//
//  TodayViewController.swift
//  Lynked Widget
//
//  Created by Matthew Howes Singleton on 6/24/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import NotificationCenter
import SDWebImage


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let widgetCellIdentifier = "widgetCell"
    var serviceArray = [[String : String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("foooodfdajla")
        //FirebaseApp.configure()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        let groupDefaults = UserDefaults(suiteName: "group.Lynked")
//        if let services = groupDefaults?.object(forKey: "services") as? [[String : String]] {
//            serviceArray = services
//            print(services)
//            signInLabel.isHidden = true
//        } else {
//            signInLabel.isHidden = false
//        }

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
        return min(serviceArray.count, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: widgetCellIdentifier, for: indexPath) as! WidgetTableViewCell
        
        let service = serviceArray[indexPath.row]
        if let serviceName = service["name"], let serviceURL = service["url"] {
            
            cell.serviceNameLabel.text = serviceName.capitalized
            cell.serviceDateLabel.text = service["date"]?.capitalized
            
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: serviceName))")
            if serviceURL.isEmpty == false {
                let myURLString: String = "http://www.google.com/s2/favicons?domain=\(serviceURL)"
                
                if let myURL = URL(string: myURLString) {
                    cell.serviceImageView.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                }
            }
        }
        
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "MMM dd, yyyy"
        //
        //
        //
        //        cell.serviceDateLabel.text = dateFormatter.string(from: service.nextPaymentDate)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extensionContext?.open(URL(string: "Instagram://")! , completionHandler: nil)
    }
    
    
    
}
