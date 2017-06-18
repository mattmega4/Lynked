//
//  AcknowledgementsViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class AcknowledgementsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var pods = [
        "Firebase" : "Authentication, Performance & Analytics, Database Storage, Crash Reporting",
        "Fabric" : "Performance & Analytics, Crash Reporting",
        "SDWebImage" : "Asynchronous image downloader with cache support as a UIImageView category"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getVersionInfo()
    }
    
    
    // MARK: App Version Info
    
    func getVersionInfo() {
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Lynked Version: \(version)"
        }
    }
    
    
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
    }
    
    
}

extension AcknowledgementsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! AcknowledgementsTableViewCell
        let row = indexPath.row
        
        var names: [String] {
            get{
                return Array(pods.keys)
            }
        }
        
        cell.nameLabel.text = names[row]
        
        var descriptions: [String] {
            get{
                return Array(pods.values)
            }
        }
        
        cell.descriptionLabel.text = descriptions[row]
        
        
        return cell
        
    }
    
    
}



