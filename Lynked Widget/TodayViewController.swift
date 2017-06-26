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
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tableView: UITableView!
    let widgetCellIdentifier = "widgetCell"
    var serviceArray = [ServiceClass]()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        FirebaseApp.configure()
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getServices() {
        
        FirebaseUtility.shared.getAllServices { (services, error) in
            if let theServices = services {
                self.serviceArray = theServices
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        getServices()
        completionHandler(NCUpdateResult.newData)
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
        
        let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
        if let seviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
            let myURLString: String = "http://www.google.com/s2/favicons?domain=\(seviceURLString)"
            
            if let myURL = URL(string: myURLString) {
                cell.serviceImageView.sd_setImage(with: myURL, placeholderImage: placeholderImage)
            }
        }
            
        else {
            cell.serviceImageView.image = placeholderImage
        }
        
        cell.serviceNameLabel.text = service.serviceName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        
        
        cell.serviceDateLabel.text = dateFormatter.string(from: service.nextPaymentDate)



        return cell
    }
    
        


}
