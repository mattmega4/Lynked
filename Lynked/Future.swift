//
//  Future.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit


//    var autoCompletePossibilities: [String] = []
//    var autoComplete: [String] = []
//
//    var countedSet: NSCountedSet?
//    var dataArray = [String]()


// MARK: Predictive Text FOr TableView Logic

//    func getListOfAllServicesFromFirebase() {
//        DispatchQueue.global().async {
//            let servicesRef = self.ref.child("services")
//            servicesRef.observe( .value, with: { (snapshot) in
//                for services in snapshot.children {
//                    let allServiceIDs = (services as AnyObject).key as String
//                    let serviceDrilled = servicesRef.child(allServiceIDs)
//                    serviceDrilled.observeSingleEvent(of: .value, with: { (snap) in
//                        let sD = snap as DataSnapshot
//                        if let serviceDict = sD.value as? [String: AnyObject] {
//                            let aService = ServiceClass(id: sD.key, serviceDict: serviceDict)
//                            self.serviceArray.append(aService)
//                            if let sName = serviceDict["serviceName"] as? String {
//                                self.autoCompletePossibilities.append(sName.lowercased())
//                            }
//                        }
//                    })
//                }
//            })
//        }
//    }


//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField == serviceNameTextField {
//            let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//            searchAutocompleteEntriesWithSubstring(substring)
//        }
//        return true
//    }
//
//
//    func searchAutocompleteEntriesWithSubstring(_ substring: String) {
//        autoComplete.removeAll(keepingCapacity: false)
//        for key in autoCompletePossibilities {
//            let myString:NSString! = key as NSString
//            let substringRange :NSRange! = myString.range(of: substring)
//            if (substringRange.location  == 0) {
//
//                autoComplete.append(key)
//                self.countedSet = NSCountedSet(array: self.autoComplete)
//                self.dataArray = self.countedSet?.allObjects as! [String]
//            }
//
//        }
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }



//  extension : UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataArray.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "autoComCell", for: indexPath) as! AutoCompleteTableViewCell
//        let item = dataArray[indexPath.row]
//        
//        cell.previewNameLabel.text = item
//        
//        let myURLString: String = "http://www.google.com/s2/favicons?domain=www.\(item.removingWhitespaces()).com"
//        if let myURL = URL(string: myURLString) {
//            cell.previewImageView.sd_setImage(with: myURL, placeholderImage: #imageLiteral(resourceName: "Ly"))
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let selectedCell: AutoCompleteTableViewCell = tableView.cellForRow(at: indexPath)! as! AutoCompleteTableViewCell
//        
//        serviceNameTextField.text = selectedCell.previewNameLabel.text
//        
//        tableView.isHidden = true
//        collectionView.isUserInteractionEnabled = true
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 34.0
//    }
//    
//}


// TODO: Fixed Expense Sum

//  self.totalArr.append((serviceDict["serviceAmount"] as? String)!)
//  self.doubleArray = self.totalArr.flatMap{ Double($0) }
//  let arraySum = self.doubleArray.reduce(0, +)
//  self.title = self.selectedCard?.nickname ?? ""


//let connectedRef = Database.database().reference(withPath: ".info/connected")
//
//func checkFirebaseConnection() {
//    connectedRef.observe(.value, with: { snapshot in
//        if snapshot.value as? Bool ?? false {
//            print("Connected")
//        } else {
//            print("Not connected")
//        }
//    })
//}

