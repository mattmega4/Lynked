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
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let viewModel = AcknowledgementsViewModel()
    
    var pods = [Library]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        pods = viewModel.getAcknowlwdgements()
        versionLabel.text = viewModel.getVersionInfo()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
    }
    
    // MARK: - IBActions
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AcknowledgeCell", for: indexPath as IndexPath) as! AcknowledgementsTableViewCell
        let pod = pods[indexPath.row]
        cell.nameLabel.text = pod.name
        cell.descriptionLabel.text = pod.legalDescription
        return cell
        
    }
    
    
}



