//
//  FirebaseUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/17/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebasePerformance
import Fabric
import Crashlytics


class FirebaseUtility: NSObject {
  
  static let shared = FirebaseUtility()
  
  let ref = Database.database().reference()
  var user = Auth.auth().currentUser
  let storage = Storage.storage()
  
  
  // MARK: - Cards
  
  func getCards(completion: @escaping (_ cards: [Card]?, _ errorMessage: String?) -> Void) {
    
    guard let userID = user?.uid else {
      let error = "Unknown error occured! User is not logged in."
      completion(nil, error)
      return
    }
    
    let userCardRef = ref.child(FirebaseKeys.newCards).child(userID)
    userCardRef.observe(.value, with: { (snapshot) in // changed from Single Event
      let enumerator = snapshot.children
      var cards = [Card]()
      
      while let cardSnapshot = enumerator.nextObject() as? DataSnapshot {
        if let cardDict = cardSnapshot.value as? [String : Any] {
          let card = Card(id: cardSnapshot.key, cardDict: cardDict)
          cards.append(card)
        }
      }
      completion(cards, nil)
    })
  }
  
  func addCard(name: String?, type: String?, color: Int, last4: String?, completion: @escaping (_ card: Card?, _ errMessage: String?) -> Void) {
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
      let cardRef = ref.child(FirebaseKeys.newCards).child(userId).childByAutoId()
      let cardDict: [String : Any] = [FirebaseKeys.nickname : theName, FirebaseKeys.last4 : theLast4, FirebaseKeys.type : theType, FirebaseKeys.color : color]
      
      cardRef.setValue(cardDict, withCompletionBlock: { (error, ref) in
        
        if let theError = error?.localizedDescription {
          let errorMessage = theError
          completion(nil, errorMessage)
          
        } else {
          
          let card = Card(id: ref.key, cardDict: cardDict)
          completion(card, nil)
        }
      })
    }
  }
  
  
  func delete(card: Card, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
    
    guard let userId = user?.uid else {
      let errMessage = "Something went wrong"
      completion(false, errMessage)
      return
    }
    
    let cardRef = ref.child(FirebaseKeys.newCards).child(userId).child(card.cardID)
    cardRef.removeValue { (error, ref) in
      
      if let theError = error?.localizedDescription {
        let errMessage = theError
        completion(false, errMessage)
      } else {
        let serviceRef = self.ref.child(FirebaseKeys.newServices).child(card.cardID)
        serviceRef.removeValue()
        
        
        completion(true, nil)
      }
    }
  }
  
  func update(card: Card, nickName: String?, last4: String?, color: Int, completion: @escaping (_ card: Card?, _ error: String?) -> Void) {
    
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
    
    let cardDict: [String : Any] = [FirebaseKeys.nickname : name, FirebaseKeys.last4 : last4Digits, FirebaseKeys.type : card.type ?? "", FirebaseKeys.color : color]
    
    let cardRef = ref.child(FirebaseKeys.newCards).child(userId).child(card.cardID)
    
    cardRef.setValue(cardDict, withCompletionBlock: { (error, ref) in
      
      if let theError = error?.localizedDescription {
        let errorMessage = theError
        completion(nil, errorMessage)
      } else {
        
        let card = Card(id: ref.key, cardDict: cardDict)
        completion(card, nil)
        
      }
    })
  }
  
  
  // MARK: - Services
  
  func getServicesFor(card: Card, completion: @escaping (_ services: [Service]?, _ error: Error?) -> Void) {
    let servicesRef = ref.child(FirebaseKeys.newServices).child(card.cardID)
    servicesRef.observeSingleEvent(of: .value, with: { (snapshot) in
      let enumerator = snapshot.children
      var serviceArray = [Service]()
      while let serviceSnapshot = enumerator.nextObject() as? DataSnapshot {
        
        if let serviceDict = serviceSnapshot.value as? [String : Any] {
          let service = Service(id:serviceSnapshot.key, cardId: card.cardID, serviceDict: serviceDict)
          serviceArray.append(service)
        }
      }
      completion(serviceArray, nil)
    })
  }
  
  
  func addService(name: String?, forCard card: Card?, withCategory category: String?, completion: @escaping (_ service: Service?, _ errMessage: String?) -> Void) {
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
    
    
    let serviceRef = ref.child(FirebaseKeys.newServices).child(theCard.cardID).childByAutoId()
    
    var selectedCategory = FirebaseKeys.miscellaneous
    if let theCategory = category {
      if !theCategory.isEmpty {
        selectedCategory = theCategory
      }
    }
    let serviceDict: [String : Any] = [FirebaseKeys.serviceName : theName,
                                       FirebaseKeys.serviceURL : theName.createServiceURL(),
                                       FirebaseKeys.serviceStatus : true,
                                       FirebaseKeys.serviceFixed : false,
                                       FirebaseKeys.serviceAmount : 0,
                                       FirebaseKeys.attentionInt : 0,
                                       FirebaseKeys.category : selectedCategory]
    
    serviceRef.setValue(serviceDict, withCompletionBlock: { (error, ref) in
      
      if let theError = error?.localizedDescription {
        let errorMessage = theError
        completion(nil, errorMessage)
        
      } else {
        
        let service = Service(id: ref.key, cardId: theCard.cardID, serviceDict: serviceDict)
        completion(service, nil)
      }
    })
  }
  
  func resetServices(services: [Service], completion: @escaping (_ services: [Service]) -> Void) {
    resetServices(services: services, updatedServices: [Service](), index: 0, completion: completion)
  }
  
  
  private func resetServices(services: [Service], updatedServices:[Service], index: Int, completion: @escaping (_ services: [Service]) -> Void) {
    var theServices = updatedServices
    if index < services.count {
      let service = services[index]
      update(service: service,
             name: service.serviceName,
             url: service.serviceUrl,
             amount: String(service.serviceAmount),
             isFixed: service.serviceFixed ?? false,
             state: false,
             rate: service.paymentRate,
             scheduled: service.nextPaymentDate?.timeIntervalSinceReferenceDate,
             categ: service.category,
             paymentDate: service.nextPaymentDate,
             completion: { (service, error) in
              if let theService = service {
                theServices.append(theService)
              }
              self.resetServices(services: services, updatedServices: theServices, index: index + 1, completion: completion)
      })
    } else {
      
      completion(theServices)
    }
  }
  
  func update(service: Service?, name: String?, url: String?, amount: String?, isFixed: Bool, state: Bool, rate: String?, scheduled: Double?, categ: String?, paymentDate: Date?, completion: @escaping (_ service: Service?, _ errMessage: String?) -> Void) {
    
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
    
    guard let theCat = categ else {
      let errorMessage = "Please enter the category"
      completion(nil, errorMessage)
      return
    }
    
    let attention: Int = state ? 0 : 1
    
    let serviceRef = ref.child(FirebaseKeys.newServices).child(service.cardID).child(service.serviceID)
    
    var serviceDict: [String : Any] = [FirebaseKeys.serviceName : theName,
                                       FirebaseKeys.serviceURL : theURL,
                                       FirebaseKeys.serviceStatus : state,
                                       FirebaseKeys.serviceFixed : isFixed,
                                       FirebaseKeys.attentionInt : attention,
                                       FirebaseKeys.category : theCat]
    
    if isFixed, let theRate = rate, let theAmount = amount, let paymentDate = paymentDate?.timeIntervalSince1970 {
      var serviceAmount: Double = 0
      var amountWhiteSpacesRemoved = theAmount.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      if amountWhiteSpacesRemoved.hasPrefix("$") && amountWhiteSpacesRemoved.count > 1 {
        amountWhiteSpacesRemoved.remove(at: amountWhiteSpacesRemoved.startIndex)
      }
      serviceAmount = Double(amountWhiteSpacesRemoved) ?? 0.0
      
      serviceDict = [FirebaseKeys.serviceName : theName,
                     FirebaseKeys.serviceURL : theURL,
                     FirebaseKeys.serviceStatus : state,
                     FirebaseKeys.serviceFixed : isFixed,
                     FirebaseKeys.serviceAmount : serviceAmount,
                     FirebaseKeys.attentionInt : attention,
                     FirebaseKeys.category : theCat,
                     FirebaseKeys.paymentRate : theRate,
                     FirebaseKeys.nextPaymentDate : paymentDate]
    }
    
    serviceRef.setValue(serviceDict, withCompletionBlock: { (error, ref) in
      
      if let theError = error?.localizedDescription {
        let errorMessage = theError
        completion(nil, errorMessage)
      } else {
        
        let service = Service(id: ref.key, cardId: service.cardID, serviceDict: serviceDict)
        completion(service, nil)
      }
    })
  }
  
  
  func delete(service: Service?, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
    
    guard let service = service else {
      let errorMessage = "Something went wrong"
      completion(false, errorMessage)
      return
    }
    
    let serviceRef = ref.child(FirebaseKeys.newServices).child(service.cardID).child(service.serviceID)
    serviceRef.removeValue { (error, ref) in
      
      if let theError = error?.localizedDescription {
        let errMessage = theError
        completion(false, errMessage)
        
      } else {
        
        let serviceRef = self.ref.child(FirebaseKeys.newServices).child(service.cardID).child(service.serviceID)
        serviceRef.removeValue()
        
        
        
        completion(true, nil)
      }
    }
  }
  
  // MARK: - Today Extension Services
  
  func getAllServices(completion: @escaping (_ services: [Service]?, _ errorMessage: String?) -> Void) {
    getCards { (cards, error) in
      if let theCards = cards {
        self.getServices(cards: theCards, index: 0, services: [], completion: { (services, error) in
          completion(services, error)
          let groupDefaults = UserDefaults(suiteName: UserDefaultsKeys.groupDefaultsKey)
          if let theServices = services {
            let simpleArray = self.getSimpleArrayFrom(services: theServices)
            groupDefaults?.set(simpleArray, forKey: UserDefaultsKeys.groupDefaultsKey)
          }
        })
      } else {
        completion(nil, error)
      }
    }
  }
  
  private func getSimpleArrayFrom(services: [Service]) -> [[String : String]] {
    
    var simpleArray = [[String : String]]()
    
//    let relevantSortedServices = services.filter({ $0.timeIntervalSinceNow > 0 }) .sorted ()
    
    let sortedServices = services.sorted { (service1, service2) -> Bool in
      
      
      
      guard let service1Date = service1.nextPaymentDate else {
        return false
      }
      guard let service2Date = service2.nextPaymentDate else {
        return true
      }
      return service1Date.compare(service2Date) == .orderedAscending
    }
    
    
    for i in 0..<sortedServices.count {
      
      let aService = sortedServices[i]
      if let name = aService.serviceName, let url = aService.serviceUrl, let nextPaymentDate = aService.nextPaymentDate, aService.serviceFixed == true {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let date = formatter.string(from: nextPaymentDate)
        let object = ["name": name, "url": url, "date": date]
        simpleArray.append(object)
      }
    }
    
    
    return simpleArray
    
  }
  
  
  private func getServices(cards: [Card], index: Int, services: [Service], completion: @escaping (_ services: [Service]?, _ errorMessage: String?) -> Void) {
    if index < cards.count {
      let card = cards[index]
      getServicesFor(card: card, completion: { (serviceArray, error) in
        if let theServices = serviceArray {
          self.getServices(cards: cards, index: index + 1, services: services + theServices, completion: completion)
        } else {
          self.getServices(cards: cards, index: index + 1, services: services, completion: completion)
        }
      })
    } else {
      completion(services, nil)
    }
  }
  
  
  // MARK: - Auth
  
  func resetPasswordWith(email: String, completion: (_ error: String) -> Void) {
    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
      print(error.debugDescription)
    }
  }
  
  
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
        
        self.user = user
        completion(user, nil)
      }
    })
  }
  
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
        
        self.user = user
        completion(user, nil)
      }
    })
  }
  
  
  // MARK: - User Information
  
  func pullUserData(completion: @escaping (_ userInfo: [String : Any]?, _ errorMessage: String?) -> Void) {
    
    if let userID = user?.uid {
      let userRef = ref.child(FirebaseKeys.users).child(userID) //.child(FirebaseKeys.profilePicture)
      
      userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let info = snapshot.value as? [String: Any] {
          completion(info, nil)
        } else {
          completion(nil, "We could not get user info from firebase")
        }
      })
    } else {
      completion(nil, "You are not authorized to get this information")
    }
  }
  
  func saveUserName(name: String) {
    if let userID = user?.uid {
      let userRef = ref.child(FirebaseKeys.users).child(userID)
      userRef.updateChildValues([FirebaseKeys.userName: name])
    }
    
    if let user = Auth.auth().currentUser {
      let changeRequest = user.createProfileChangeRequest()
      changeRequest.displayName = name
      changeRequest.commitChanges(completion: nil)
    }
  }
  
  func saveUserPicture(image: UIImage) {
    if let userId = user?.uid, let imageData = UIImageJPEGRepresentation(image, 1.0) {
      let storageRef = storage.reference().child(FirebaseKeys.profilePicture).child(userId)
      storageRef.putData(imageData, metadata: nil, completion: { (storageMetaData, error) in
        if let profilePictureLink = storageMetaData?.downloadURL()?.absoluteString {
          let userProfileRef = self.ref.child(FirebaseKeys.users).child(userId)
          userProfileRef.updateChildValues([FirebaseKeys.profilePicture : profilePictureLink])
        }
      })
    }
  }
  
  func deleteAccount(completion: (_ success: Bool, _ error: Error?) -> Void) {
    user?.delete(completion: { (error) in
      
    })
  }
}




