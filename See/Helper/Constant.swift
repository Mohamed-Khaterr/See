//
//  Constant.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import Foundation
import UIKit


struct Constant {
    
    static let appName = "See"
    
    static let currentYear: Int = Calendar.current.component(.year, from: .now)
    
    
    // MARK: - UI Images
    static let profileImage = UIImage(named: "Profile Image")
    static let favouriteImage = UIImage(named: "Favourite")
    static let favouriteFillImage = UIImage(named: "Favourite-fill")
    static let bookmarkImage = UIImage(named: "Bookmark")
    static let bookmarkFillImage = UIImage(named: "Bookmark-fill")
    static let starImage = UIImage(named: "star")
    static let starFillImage = UIImage(named: "star.fill")
    static let chevronRightImage = UIImage(named: "Chevron-right")
    static let chevronLeftImage = UIImage(named: "Chevron-left")
    static let shareImage = UIImage(named: "Share")
    static let settingImage = UIImage(named: "Settings")
    static let eyeImage = UIImage(named: "Eye Hide")
    static let defualtImage = UIImage(named: "Icon")
    
    static let testImage1 = UIImage(named: "PosterImage")
    static let testImage2 = UIImage(named: "PosterImage2")
    static let testImage3 = UIImage(named: "PosterImage3")
    static let testImage4 = UIImage(named: "PosterImage4")
}
