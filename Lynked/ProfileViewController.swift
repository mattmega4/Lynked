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
import Instabug
import MBProgressHUD
import Kingfisher


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileViewBorder: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var leftSideButton: UIButton!
    @IBOutlet weak var rightSideButton: UIButton!
    
    //
    //
    
    @IBOutlet weak var rightViewContainer: UIView!
    
    @IBOutlet weak var tellFriendButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var acknowledgementsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    let storage = Storage.storage()
    
    var leftOnRightOff = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        setNavBar()
        profileNameLabel.isHidden = false
        profileNameTextField.isHidden = true
        self.profileNameTextField.delegate = self
        profileNameTextField.placeHolderTextColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileViewBorder.createRoundView()
        profileImageView.createRoundView()
    }
    
    
    // Mark: - Firebase Methods
    
    func pullUserData() {
        FirebaseUtility.shared.pullUserData { (userInfo, errorMessage) in
            if let profilePictureLink = userInfo?["profilePicture"] {
                if let profilePictureURL = URL(string: profilePictureLink) {
                    self.profileImageView.kf.setImage(with: profilePictureURL, placeholder: #imageLiteral(resourceName: "E"), options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
            
            if let profileName = userInfo?["userName"] {
                
                self.profileNameLabel.text = profileName
                self.editNameButton.isHidden = false
                self.profileNameLabel.isHidden = false
                self.profileNameTextField.isHidden = true
            }
            else {
                self.editNameButton.isHidden = true
                self.profileNameLabel.isHidden = true
                self.profileNameTextField.isHidden = false
                self.profileNameTextField.becomeFirstResponder()
                self.profileNameTextField.placeholder = "Enter Your Name Here!"
            }

        }
    }
    
    func saveNameToFirebase() {
        
        profileNameTextField.resignFirstResponder()
        
        
        let userName = profileNameTextField.text ?? ""
        
        
        
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
        profileNameLabel.isHidden = true
        profileNameTextField.isHidden = false
    }
    
    
    //MARK: - Left Container IBActions
    
    
    
    
    //MARK: - Right Container IBActions
    
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
    
    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
        Instabug.invoke()
        Instabug.setCommentFieldRequired(true)
        Instabug.setEmailFieldRequired(false)
    }
    
    @IBAction func acknowledgementsButtonTapped(_ sender: UIButton) {
        if let ackVC = self.storyboard?.instantiateViewController(withIdentifier: ACKNOWLEDGEMENTS_STORYBOARD_IDENTIFIER) as? AcknowledgementsViewController {
            self.navigationController?.pushViewController(ackVC, animated: true)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
                self.navigationController?.pushViewController(loginVC, animated: true)
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
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    
}


extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == profileNameTextField {
            //profileNameTextField.returnKeyType = .done
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
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = editedImage
            if let userId = user?.uid, let imageData = UIImageJPEGRepresentation(editedImage, 1.0) {
                let storageRef = storage.reference().child("profilePictures").child(userId)
                storageRef.putData(imageData, metadata: nil, completion: { (storageMetaData, error) in
                    if let profilePictureLink = storageMetaData?.downloadURL()?.absoluteString {
                        let userProfileRef = self.ref.child("users").child(userId)
                        userProfileRef.updateChildValues(["profilePicture" : profilePictureLink])
                    }
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}
