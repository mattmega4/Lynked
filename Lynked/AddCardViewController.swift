//
//  AddCardViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddCardViewController: UIViewController {
    
    @IBOutlet weak var cancelNavBarButton: UIBarButtonItem!
    @IBOutlet weak var nextNavBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!


    @IBOutlet weak var firstContainerTextField: UITextField!
    @IBOutlet weak var secondContainerTextField: UITextField!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    @IBOutlet weak var fourthContainerView: UIView!

    @IBOutlet weak var thirdContainerButton: UIButton!
 
    @IBOutlet weak var cardTypePickerView: UIPickerView!
    

    
    let ref = Database.database().reference()
    var nickNameTextFieldIsEmpty = true
    var cardTypeTextFieldIsEmpty = true
    var allCardTypes: [String] = []
    var finalNickname: String?
    var final4: String?
    var finalType: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstContainerTextField.delegate = self
        secondContainerTextField.delegate = self
        cardTypePickerView.delegate = self
        cardTypePickerView.dataSource = self
        
        setNavBar()
        nextNavBarButton.isEnabled = false
        firstContainerTextField.addTarget(self, action: #selector(checkNicknameTextField(textField:)), for: .editingChanged)
        secondContainerTextField.addTarget(self, action: #selector(checkTypeTextField(textField:)), for: .editingChanged)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddCardViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfAllConditionsAreMet()
        allCardTypes+=["Visa", "MasterCard", "American Express", "Discover", "Capital One", "China UnionPay", "RuPay", "Diner's Club", "JCB", "Other" ]
        print("bar")
    }
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = "Add Card"
        navigationController?.navigationBar.barTintColor = UIColor(red: 108.0/255.0,
                                                                   green: 158.0/255.0,
                                                                   blue: 236.0/255.0,
                                                                   alpha: 1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                   NSFontAttributeName: UIFont(name: "GillSans-Bold",
                                                                                               size: 18)!]
    }
    
    
    
    // MARK: Write to Firebase
    
    func addDataToFirebase() {
        
        let user = Auth.auth().currentUser
        let card = ref.child("cards").childByAutoId()
        
        let nicknameToAdd = firstContainerTextField.text ?? ""
        let nicknameWithoutWhiteSpaces = nicknameToAdd.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        finalNickname = nicknameWithoutWhiteSpaces.capitalized
        
        let last4 = secondContainerTextField.text
        
        let typeToAdd = finalType
        finalType = typeToAdd?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let tempNick = finalNickname, let temp4 = last4 {
            card.setValue(["nickname": tempNick, "last4": temp4, "type": finalType])
        }
        ref.child("users").child((user?.uid)!).child("cards").child(card.key).setValue(true)
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
            detailVC.cardID = card.key
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    
    // MARK: Enable Next Button
    
    func checkIfAllConditionsAreMet() {
        if nickNameTextFieldIsEmpty == false && cardTypeTextFieldIsEmpty == false {
            nextNavBarButton.isEnabled = true
        } else {
            nextNavBarButton.isEnabled = false
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func navBarCancelButtonTapped(_ sender: UIBarButtonItem) {
        if let walletVC = storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? CardWalletViewController {
            navigationController?.pushViewController(walletVC, animated: true)
        }
    }
    
    @IBAction func navBarNextButtonTapped(_ sender: UIBarButtonItem) {
        addDataToFirebase()
    }
    
    @IBAction func thirdContainerButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        cardTypePickerView.isHidden = false
    }
    
    // MARK: Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        self.scrollView.contentInset = contentInset
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
} // End of AddCardViewController Class


// MARK: UITextField Methods

extension AddCardViewController: UITextFieldDelegate {
    
    func checkNicknameTextField(textField: UITextField) {
        if textField == firstContainerTextField {
            if textField.text?.isEmpty == true {
                nickNameTextFieldIsEmpty = true
            } else {
                nickNameTextFieldIsEmpty = false
            }
        }
        checkIfAllConditionsAreMet()
    }
    
    
    func checkTypeTextField(textField: UITextField) {
        if textField == secondContainerTextField {
            if textField.text?.isEmpty == true {
                cardTypeTextFieldIsEmpty = true
            } else {
                cardTypeTextFieldIsEmpty = false
            }
        }
        checkIfAllConditionsAreMet()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == secondContainerTextField {
            
            guard let text = textField.text else { return true }
            
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            let newLength = text.characters.count + string.characters.count - range.length
            return  allowedCharacters.isSuperset(of: characterSet) && newLength <= 4 // Bool
        }
        
        return true
    }
    
}

// MARK: UIPickerView Methods

extension AddCardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return allCardTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCardTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        thirdContainerButton.setTitle("\(allCardTypes[row])", for: .normal)
        cardTypePickerView.isHidden = true
        finalType = allCardTypes[row]
    }
}




