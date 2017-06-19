//
//  FirebaseUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/17/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebasePerformance
import Fabric
import Crashlytics

class FirebaseUtility: NSObject {
    
    static let shared = FirebaseUtility()
    
    let ref = Database.database().reference()
    var user = Auth.auth().currentUser
    
    
    // MARK: - Get Card
    
    func getCards(completion: @escaping (_ cards: [CardClass]?, _ errorMessage: String?) -> Void) {
        
        guard let userID = user?.uid else {
            let error = "Unknown error occured! User is not logged in."
            completion(nil, error)
            return
        }
        
        let userCardRef = ref.child("newCards").child(userID)
        userCardRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            var cards = [CardClass]()
            let cardTrace = Performance.startTrace(name: "PullCardTrace")
            while let cardSnapshot = enumerator.nextObject() as? DataSnapshot {
                
                if let cardDict = cardSnapshot.value as? [String : Any] {
                    let card = CardClass(id: cardSnapshot.key, cardDict: cardDict)
                    cards.append(card)
                }
            }
            completion(cards, nil)
            cardTrace?.stop()
        })
    }
    
    
    // MARK: - Add Card
    
    func addCard(name: String?, type: String?, color: Int, last4: String?, completion: @escaping (_ card: CardClass?, _ errMessage: String?) -> Void) {
        guard let theName = name else {
            let errorMessage = "Please enter the card name"
            completion(nil, errorMessage)
            return
        }
        
        guard let theType = type else {
            let errorMessage = "Please enter the card type"
            completion(nil, errorMessage)
            return
        }
        
        guard let theLast4 = last4 else {
            let errorMessage = "Please enter the card last four"
            completion(nil, errorMessage)
            return
        }
        
        if let userId = user?.uid {
            let cardRef = ref.child("newCards").child(userId).childByAutoId()
            let cardDict: [String : Any] = ["nickname": theName, "last4": theLast4, "type": theType, "color": color]
            cardRef.setValue(cardDict, withCompletionBlock: { (error, ref) in
                
                if let theError = error?.localizedDescription {
                    let errorMessage = theError
                    completion(nil, errorMessage)
                    
                } else {
                    Analytics.logEvent("New_Card_Added", parameters: ["success" : true])
                    
                    Answers.logCustomEvent(withName: "New Card Added",
                                           customAttributes: nil)
                    let card = CardClass(id: ref.key, cardDict: cardDict)
                    completion(card, nil)
                }
            })
        }
    }
    
    
    // MARK: - Delete Card
    
    func delete(card: CardClass, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        guard let userId = user?.uid else {
            let errMessage = "Something went wrong"
            completion(false, errMessage)
            return
        }
        let cardRef = ref.child("newCards").child(userId).child(card.cardID)
        cardRef.removeValue { (error, ref) in
            
            if let theError = error?.localizedDescription {
                let errMessage = theError
                completion(false, errMessage)
            } else {
                let serviceRef = self.ref.child("newServices").child(card.cardID)
                serviceRef.removeValue()
                
                Analytics.logEvent("Card_Deleted", parameters: ["success" : true])
                
                Answers.logCustomEvent(withName: "Card Deleted",
                                       customAttributes: nil)
                
                completion(true, nil)
            }
        }
    }
    
    
    // MARK: - Update Card
    
    func update(card: CardClass, nickName: String?, last4: String?, color: Int, completion: @escaping (_ card: CardClass?, _ error: String?) -> Void) {
        guard let userId = user?.uid else {
            let errMessage = "Something went wrong"
            completion(nil, errMessage)
            return
        }
        guard let name = nickName else {
            let errMessage = "Something went wrong"
            completion(nil, errMessage)
            return
        }
        guard let last4Digits = last4 else {
            let errMessage = "Something went wrong"
            completion(nil, errMessage)
            return
        }
        let cardDict: [String : Any] = ["nickname": name, "last4": last4Digits, "type": card.type ?? "", "color": color]
        let cardRef = ref.child("newCards").child(userId).child(card.cardID)
        cardRef.setValue(cardDict, withCompletionBlock: { (error, ref) in
            if let theError = error?.localizedDescription {
                let errorMessage = theError
                completion(nil, errorMessage)
            } else {
                Analytics.logEvent("Update_Card", parameters: ["success" : true])
                
                Answers.logCustomEvent(withName: "Update Card",
                                       customAttributes: nil)
                
                let card = CardClass(id: ref.key, cardDict: cardDict)
                completion(card, nil)
            }
        })
    }
    
    
    // MARK: - Add Service
    
    func addService(name: String?, forCard card: CardClass?, completion: @escaping (_ service: ServiceClass?, _ errMessage: String?) -> Void) {
        guard let theName = name else {
            let errorMessage = "Please enter the service name"
            completion(nil, errorMessage)
            return
        }
        
        guard let theCard = card else {
            let errorMessage = "No cards available to add service to"
            completion(nil, errorMessage)
            return
        }
        
        let serviceRef = ref.child("newServices").child(theCard.cardID).childByAutoId()
        let serviceDict: [String : Any] = ["serviceName": theName, "serviceURL": theName.createServiceURL(), "serviceStatus": true, "serviceFixed": false, "serviceAmount" : 0, "attentionInt" : 0]
        serviceRef.setValue(serviceDict, withCompletionBlock: { (error, ref) in
            
            if let theError = error?.localizedDescription {
                let errorMessage = theError
                completion(nil, errorMessage)
                
            } else {
                Analytics.logEvent("New_Service_Added", parameters: ["success" : true])
                
                Answers.logCustomEvent(withName: "New Service Added",
                                       customAttributes: nil)
                let service = ServiceClass(id: ref.key, cardId: theCard.cardID, serviceDict: serviceDict)
                completion(service, nil)
            }
        })
    }
    
    
    // MARK: - Reset Services
    
    func resetServices(services: [ServiceClass], completion: @escaping (_ services: [ServiceClass]) -> Void) {
        resetServices(services: services, updatedServices: [ServiceClass](), index: 0, completion: completion)
    }
    
    
    private func resetServices(services: [ServiceClass], updatedServices:[ServiceClass], index: Int, completion: @escaping (_ services: [ServiceClass]) -> Void) {
        var theServices = updatedServices
        if index < services.count {
            let service = services[index]
            update(service: service, name: service.serviceName, url: service.serviceUrl, amount: String(service.serviceAmount), isFixed: service.serviceFixed ?? false, state: false,  completion: { (service, errMessage) in
                if let theService = service {
                    theServices.append(theService)
                }
                self.resetServices(services: services, updatedServices: theServices, index: index + 1, completion: completion)
            })
        }
        else {
            Analytics.logEvent("Card_Altered", parameters: ["success" : true])
            
            Answers.logCustomEvent(withName: "Card was Altered",
                                   customAttributes: nil)
            completion(theServices)
        }
    }
    
    
    // MARK: - Update Service
    
    func update(service: ServiceClass?, name: String?, url: String?, amount: String?, isFixed: Bool, state: Bool, completion: @escaping (_ service: ServiceClass?, _ errMessage: String?) -> Void) {
        
        guard let service = service else {
            let errorMessage = "Something went wrong"
            completion(nil, errorMessage)
            return
        }
        
        guard let theName = name else {
            let errorMessage = "Please enter the service name"
            completion(nil, errorMessage)
            return
        }
        
        guard let theURL = url else {
            let errorMessage = "Please enter the service url"
            completion(nil, errorMessage)
            return
        }
        
        var serviceAmount: Double = 0
        if let theAmount = amount {
            var amountWhiteSpacesRemoved = theAmount.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if amountWhiteSpacesRemoved.hasPrefix("$") && amountWhiteSpacesRemoved.characters.count > 1 {
                amountWhiteSpacesRemoved.remove(at: amountWhiteSpacesRemoved.startIndex)
            }
            serviceAmount = Double(amountWhiteSpacesRemoved) ?? 0.0
        }
        
        let attention: Int = state ? 0 : 1
        serviceAmount = isFixed ? serviceAmount : 0
        
        let serviceRef = ref.child("newServices").child(service.cardID).child(service.serviceID)
        let serviceDict: [String : Any] = ["serviceName": theName, "serviceURL": theURL, "serviceStatus": state, "serviceFixed": isFixed, "serviceAmount" : serviceAmount, "attentionInt" : attention]
        serviceRef.setValue(serviceDict, withCompletionBlock: { (error, ref) in
            
            if let theError = error?.localizedDescription {
                let errorMessage = theError
                completion(nil, errorMessage)
                
            } else {
                
                Analytics.logEvent("Service_Details_Updated", parameters: ["success" : true])
                
                Answers.logCustomEvent(withName: "Service Details Updated",
                                       customAttributes: nil)
                
                
                let service = ServiceClass(id: ref.key, cardId: service.cardID, serviceDict: serviceDict)
                completion(service, nil)
            }
        })
    }
    
    
    // MARK: - Sign User In
    
    func signUserInWith(email: String?, password: String?, completion: @escaping (_ user: User?, _ errorMessage: String?) -> Void) {
        
        guard let theEmail = email else {
            let errMessage = "Please enter an email"
            completion(nil, errMessage)
            return
        }
        
        guard let thePassword = password else {
            let errMessage = "Please enter a password"
            completion(nil, errMessage)
            return
        }
        
        
        Auth.auth().signIn(withEmail: theEmail, password: thePassword, completion: { (user, error) in
            if let theError = error {
                
                var errMessage = "An unknown error occured."
                if let errCode = AuthErrorCode(rawValue: (theError._code)) {
                    switch errCode {
                        
                    case .invalidEmail:
                        errMessage = "The entered email does not meet requirements."
                    case .weakPassword:
                        errMessage = "The entered password does not meet minimum requirements."
                    case .wrongPassword:
                        errMessage = "The entered password is not correct."
                    default:
                        errMessage = "Please try again."
                    }
                }
                completion(nil, errMessage)
            } else {
                
                Analytics.logEvent("Email_Login", parameters: ["success" : true])
                
                Answers.logLogin(withMethod: "Email Login",
                                 success: true,
                                 customAttributes: [:])
                
                self.user = user
                completion(user, nil)
            }
        })
    }
    
    
    // MARK: - Register User
    
    func registerUserWith(email: String?, password: String?, confirmPassword: String?, completion: @escaping (_ user: User?, _ errorMessage: String?) -> Void) {
        
        guard let theEmail = email else {
            let errMessage = "Please enter an email"
            completion(nil, errMessage)
            return
        }
        
        guard let thePassword = password else {
            let errMessage = "Please enter a password"
            completion(nil, errMessage)
            return
        }
        
        guard password == confirmPassword else {
            let errMessage = "Passwords do not match"
            completion(nil, errMessage)
            return
        }
        
        Auth.auth().createUser(withEmail: theEmail, password: thePassword, completion: { (user, error) in
            if let theError = error {
                
                var errMessage = "An unknown error occured."
                if let errCode = AuthErrorCode(rawValue: (theError._code)) {
                    switch errCode {
                        
                    case .invalidEmail:
                        errMessage = "The entered email does not meet requirements."
                    case .emailAlreadyInUse:
                        errMessage = "The entered email has already been registered."
                    case .weakPassword:
                        errMessage = "The entered password does not meet minimum requirements."
                    default:
                        errMessage = "Please try again."
                    }
                }
                completion(nil, errMessage)
            } else {
                Analytics.logEvent("Email_Register", parameters: ["success" : true])
                
                Answers.logSignUp(withMethod: "Email Register",
                                  success: true,
                                  customAttributes: [:])
                self.user = user
                completion(user, nil)
            }
        })
    }
    
    
    // MARK: - Get Services
    
    func getServicesFor(card: CardClass, completion: @escaping (_ services: [ServiceClass]?, _ error: Error?) -> Void) {
        let servicesRef = ref.child("newServices").child(card.cardID)
        servicesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            var serviceArray = [ServiceClass]()
            let serviceTrace = Performance.startTrace(name: "PullServiceTrace")
            while let serviceSnapshot = enumerator.nextObject() as? DataSnapshot {
                
                if let serviceDict = serviceSnapshot.value as? [String : Any] {
                    let service = ServiceClass(id:serviceSnapshot.key, cardId: card.cardID, serviceDict: serviceDict)
                    serviceArray.append(service)
                }
            }
            completion(serviceArray, nil)
            serviceTrace?.stop()
        })
    }
    
    
    // TODO: - Delete Service
    
    func delete(service: ServiceClass, completion: (_ success: Bool, _ error: Error?) -> Void) {
        
    }
    
    
    // TODO: - Delete Account
    
    func deleteAccount(completion: (_ success: Bool, _ error: Error?) -> Void) {
        
    }
    
}




// use this somehow

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
