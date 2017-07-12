//
//  TempLetterImagePickerUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/22/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class TempLetterImagePickerUtility: NSObject {
    
    static let shared = TempLetterImagePickerUtility()

    func getLetterOrNumberAndChooseImage(text: String) -> String {
        
        if text == " " || text == "" {
            return "*"
        }
        
        let index = text.index(text.startIndex, offsetBy: 0)
        let letterImageToLoad = text[index]
        let letter = String(letterImageToLoad).lowercased()
        let imageName = { () -> String in
            switch letter {
            case "a":
                return "A.png"
            case "b":
                return "B.png"
            case "c":
                return "C.png"
            case "d":
                return "D.png"
            case "e":
                return "E.png"
            case "f":
                return "F.png"
            case "g":
                return "G.png"
            case "h":
                return "H.png"
            case "i":
                return "I.png"
            case "j":
                return "J.png"
            case "k":
                return "K.png"
            case "l":
                return "L.png"
            case "m":
                return "M.png"
            case "n":
                return "N.png"
            case "o":
                return "O.png"
            case "p":
                return "P.png"
            case "q":
                return "Q.png"
            case "r":
                return "R.png"
            case "s":
                return "S.png"
            case "t":
                return "T.png"
            case "u":
                return "U.png"
            case "v":
                return "V.png"
            case "w":
                return "W.png"
            case "x":
                return "X.png"
            case "y":
                return "Y.png"
            case "z":
                return "Z.png"
            case "0":
                return "Zero.png"
            case "1":
                return "One.png"
            case "2":
                return "Two.png"
            case "3":
                return "Three.png"
            case "4":
                return "Four.png"
            case "5":
                return "Five.png"
            case "6":
                return "Six.png"
            case "7":
                return "Seven.png"
            case "8":
                return "Eight.png"
            case "9":
                return "Nine.png"
            default:
                return "Star.png"
            }
        }()
        return imageName
    }
    
}
