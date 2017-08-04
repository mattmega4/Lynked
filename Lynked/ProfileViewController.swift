//
//  ProfileViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/2/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MBProgressHUD
import Kingfisher


class ProfileViewController: UITableViewController {
  
  @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var profileImageBorderView: UIView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var invisibleProfileButton: UIButton!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var editNameButton: UIButton!
  
  @IBOutlet weak var feedbackCell: UITableViewCell!
  @IBOutlet weak var feedbackButton: UIButton!
  
  @IBOutlet weak var recommendCell: UITableViewCell!
  @IBOutlet weak var recommendButton: UIButton!
  
  @IBOutlet weak var acknowledgementCell: UITableViewCell!
  @IBOutlet weak var acknowledgementButton: UIButton!
  
  @IBOutlet weak var legalCell: UITableViewCell!
  @IBOutlet weak var legalButton: UIButton!
  
  @IBOutlet weak var logoutCell: UITableViewCell!
  @IBOutlet weak var logoutButton: UIButton!
  
  @IBOutlet weak var deleteCell: UITableViewCell!
  @IBOutlet weak var deleteButton: UIButton!
  
  let ref = Database.database().reference()
  let user = Auth.auth().currentUser
  let storage = Storage.storage()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Profile"
    setNavBar()
    nameLabel.isHidden = false
    nameTextField.isHidden = true
    self.nameTextField.delegate = self
    nameTextField.placeHolderTextColor = .white
  }
  
  var whetherCameraJustDismissed = false
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if !whetherCameraJustDismissed {
      pullUserData()
      whetherCameraJustDismissed = false
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageBorderView.createRoundView()
    profileImageView.createRoundView()
  }
  
  
  // Mark: - Firebase Methods
  
  func pullUserData() {
    FirebaseUtility.shared.pullUserData { (userInfo, errorMessage) in
      if let profilePictureLink = userInfo?[FirebaseKeys.profilePicture] {
        if let profilePictureURL = URL(string: profilePictureLink) {
          self.profileImageView.kf.setImage(with: profilePictureURL, placeholder: #imageLiteral(resourceName: "camera"), options: nil, progressBlock: nil, completionHandler: nil)
        }
      }
      else {
        self.profileImageView.image = #imageLiteral(resourceName: "camera")
      }
      if let profileName = userInfo?[FirebaseKeys.userName] {
        self.nameLabel.text = profileName
        self.editNameButton.isHidden = false
        self.nameLabel.isHidden = false
        self.nameTextField.isHidden = true
      } else {
        self.editNameButton.isHidden = true
        self.nameLabel.isHidden = true
        self.nameTextField.isHidden = false
        self.nameTextField.placeholder = "Enter Your Name Here!"
      }
    }
  }
  
  func saveNameToFirebase() {
    nameTextField.resignFirstResponder()
    let userName = nameTextField.text ?? ""
    if !userName.isEmpty {
      self.nameLabel.text = userName
      self.editNameButton.isHidden = false
      self.nameLabel.isHidden = false
      self.nameTextField.isHidden = true
      FirebaseUtility.shared.saveUserName(name: userName)
    }
  }

  
  // Mark: - Use Camera Roll
  
  func pickAccountImage() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    picker.sourceType = .photoLibrary
    present(picker, animated: true, completion: nil)
  }
  
  
  // Mark: - Use Camera
  
  func useCamera() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.allowsEditing = true
      picker.sourceType = .camera
      present(picker, animated: true, completion: nil)
    }
  }
  
  
  //MARK: - Profile IBActions
  
  
  @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  
  @IBAction func editImageButtonTapped(_ sender: UIButton) {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let choosePictureAction = UIAlertAction(title: "Choose Profile Picture", style: .default) { (action) in
      self.pickAccountImage()
    }
    let takePictureAction = UIAlertAction(title: "Take Profile Picture", style: .default) { (action) in
      self.useCamera()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(choosePictureAction)
    actionSheet.addAction(takePictureAction)
    actionSheet.addAction(cancelAction)
    actionSheet.popoverPresentationController?.sourceView = sender
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  
  @IBAction func editNameButtonTapped(_ sender: UIButton) {
    nameLabel.isHidden = true
    nameTextField.isHidden = false
  }
  
  
  //MARK: - Right Container IBActions
  
  
  
  @IBAction func feedbackButtonTapped(_ sender: UIButton) {
    
    if let feedbackVC = self.storyboard?.instantiateViewController(withIdentifier: FEEDBACK_STORYBOARD_IDENTIFIER) as? FeedbackViewController {
      self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
  }
  
  @IBAction func tellFriendButtonTapped(_ sender: UIButton) {
    
    MBProgressHUD.showAdded(to: view, animated: true)
    BranchUtility.shared.generateBranchLinkFor(promoCode: "AX9I3410") { (link) in
      if let theLink = link {
        let activityController = UIActivityViewController(activityItems: [theLink], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        self.present(activityController, animated: true, completion: nil)
      }
      MBProgressHUD.hide(for: self.view, animated: true)
    }
  }
  
  
  @IBAction func acknowledgementsButtonTapped(_ sender: UIButton) {
    if let ackVC = self.storyboard?.instantiateViewController(withIdentifier: ACKNOWLEDGEMENTS_STORYBOARD_IDENTIFIER) as? AcknowledgementsViewController {
      self.navigationController?.pushViewController(ackVC, animated: true)
    }
  }
  
  
  @IBAction func legalButtonTapped(_ sender: UIButton) {
    if let legalVC = self.storyboard?.instantiateViewController(withIdentifier: LEGAL_STORYBOARD_IDENTIFIER) as? LegalViewController {
      self.navigationController?.pushViewController(legalVC, animated: true)
    }
  }
  
  @IBAction func logoutButtonTapped(_ sender: UIButton) {
    do {
      try Auth.auth().signOut()
      
      if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
        //self.navigationController?.pushViewController(loginVC, animated: true)
        dismiss(animated: true, completion: nil)
      }
    }
    catch {
      debugPrint(error)
    }
  }
  
  @IBAction func deleteButtonTapped(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
    let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
      self.user?.delete { error in
        if let error = error {
          debugPrint(error)
        } else {
          if let walletvc = self.storyboard?.instantiateViewController(withIdentifier: WALLET_STORYBOARD_IDENTIFIER) as? WalletViewController {
            self.navigationController?.pushViewController(walletvc, animated: true)
          }
        }
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

}


extension ProfileViewController: UITextFieldDelegate {
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameTextField {
      saveNameToFirebase()
    }
    return false
  }
  
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    guard let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
      return
    }
    self.profileImageView.image = editedImage
    whetherCameraJustDismissed = true
    FirebaseUtility.shared.saveUserPicture(image: editedImage)
    
    //    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
    //      self.profileImageView.image = editedImage
    //      FirebaseUtility.shared.saveUserPicture(image: editedImage)
    //
    //    } 
    dismiss(animated: true, completion: nil)

  }
  
  
}
