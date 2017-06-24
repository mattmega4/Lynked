//
//  ServicesViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/20/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class ServicesViewController: UIViewController {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segControl: UISegmentedControl!
    let serviceCellId = "ServiceCell"
    let categoryCellId = "CategoryCell"
    var services = [ServiceClass]()
    var categories = [String]()
    var isDisplayingCategories = false
    
    var card: CardClass?
    
    let margin: CGFloat = 10
    let cellsPerC = 3
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getServices()
        
    }
    
    func getServices() {
        if let theCard = card {
            FirebaseUtility.shared.getServicesFor(card: theCard, completion: { (services, error) in
                if let theServices = services {
                    
                    self.services = theServices
                    self.getCategories()
                    self.collectionView.reloadData()
                } else {
                    if let theError = error?.localizedDescription {
                        let errorMessage = theError
                        print(errorMessage)
                    }
                }
            })
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    func getCategories() {
        
        // big array contains
        let allCategories = services.flatMap({ (service) -> String? in
            return service.category
        })
        
        categories = Array(Set(allCategories))
        categories.sort { (category1, category2) -> Bool in
            return allCategories.filter({$0 == category1}).count > allCategories.filter({$0 == category2}).count
        }
    }
    
    @IBAction func changeSegment(sender: UISegmentedControl) {
        isDisplayingCategories = sender.selectedSegmentIndex == 1
        collectionView.reloadData()
    }
    
}

extension ServicesViewController: UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerC - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerC)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isDisplayingCategories {
            return services.count
        }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isDisplayingCategories {
            
            // Populate services
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: serviceCellId, for: indexPath) as! ServiceCollectionViewCell
            let service = services[indexPath.row]
            cell.colorStatusView.backgroundColor = service.serviceStatus ? .green : .red
            cell.serviceNameLabel.text = service.serviceName
            cell.serviceFixedAmountLabel.text = String(service.serviceAmount)
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
            if let seviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
                let myURLString: String = "http://www.google.com/s2/favicons?domain=\(seviceURLString)"
                
                if let myURL = URL(string: myURLString) {
                    cell.serviceLogoImage.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                }
            }
                
            else {
                cell.serviceLogoImage.image = placeholderImage
            }
            return cell
        }
        // Populate CAtegories
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath) as! ServiceCategoryCollectionViewCell
        cell.categoryNameLabel.text = categories[indexPath.row]
        let categoryServices = services.filter({$0.category == categories[indexPath.row]})
        for i in 0..<min(categoryServices.count, 3) {
            let service = categoryServices[i]
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
            if let seviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
                let myURLString: String = "http://www.google.com/s2/favicons?domain=\(seviceURLString)"
                
                if let myURL = URL(string: myURLString) {
                    switch i {
                    case 0:
                        cell.previewImageViewOne.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                    case 1:
                        cell.previewImageViewTwo.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                    case 2:
                        cell.previewImageViewThree.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                        
                    default:
                        print("I shouldn't have been printed")
                    }
                }
            }
        }
        return cell
    }
}















