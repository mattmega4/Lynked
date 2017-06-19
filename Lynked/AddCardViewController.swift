//
//  AddCardViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import MBProgressHUD

class AddCardViewController: UIViewController {
    
    @IBOutlet weak var cancelNavBarButton: UIBarButtonItem!
    @IBOutlet weak var nextNavBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
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

        title = "Add Card"
       
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
    }
    
    
    
    
    // MARK: - Write to Firebase
    
    func addDataToFirebase() {
        
        
        
        let nicknameToAdd = firstContainerTextField.text ?? ""
        let nicknameWithoutWhiteSpaces = nicknameToAdd.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        finalNickname = nicknameWithoutWhiteSpaces.capitalized
        
        let last4 = secondContainerTextField.text
        
        let typeToAdd = finalType
        finalType = typeToAdd?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
        let color: Int = segControl.selectedSegmentIndex
        MBProgressHUD.showAdded(to: view, animated: true)
        FirebaseUtility.shared.addCard(name: finalNickname, type: finalType, color: color, last4: last4) { (card, errorMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let theCard = card {
                if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                    detailVC.card = theCard
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }

            }
            else {
                // Display error
            }
        }
    }
    
    
    // MARK: - Enable Next Button
    
    func checkIfAllConditionsAreMet() {
        if nickNameTextFieldIsEmpty == false && cardTypeTextFieldIsEmpty == false {
            nextNavBarButton.isEnabled = true
        } else {
            nextNavBarButton.isEnabled = false
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func navBarCancelButtonTapped(_ sender: UIBarButtonItem) {
        if let walletVC = storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? WalletViewController {
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
    
    // MARK: - Keyboard Methods
    
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
     
    
} // End of AddCardViewController Class


// MARK: - UITextField Methods

extension AddCardViewController: UITextFieldDelegate {
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstContainerTextField {
            firstContainerTextField.returnKeyType = .next
            secondContainerTextField.becomeFirstResponder()
        } else {
            secondContainerTextField.returnKeyType = .next
            self.view.endEditing(true)
            cardTypePickerView.isHidden = false
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    

    
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

// MARK: - UIPickerView Methods

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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = allCardTypes[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "GillSans", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
}






