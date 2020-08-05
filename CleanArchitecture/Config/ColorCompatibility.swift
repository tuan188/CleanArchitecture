//
//  ColorCompatibility.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit

enum ColorCompatibility {
    static var newCard: UIColor {
        return ColorCompatibility.systemBlue
    }
    
    static var learningCard: UIColor {
        return ColorCompatibility.systemGreen
    }
    
    static var reviewingCard: UIColor {
        return ColorCompatibility.systemRed
    }
    
    static var label: UIColor {
        if #available(iOS 13, *) {
            return .label
        }
        return UIColor.black
    }
    
    static var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    static var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.6)
    }
    
    static var separator: UIColor {
        if #available(iOS 13, *) {
            return .separator
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.29)
    }
    
    static var opaqueSeparator: UIColor {
        if #available(iOS 13, *) {
            return .opaqueSeparator
        }
        return UIColor(red: 0.7764705882352941, green: 0.7764705882352941, blue: 0.7843137254901961, alpha: 1.0)
    }
    
    static var systemGray5: UIColor {
        if #available(iOS 13, *) {
            return .systemGray5
        }
        return UIColor(red: 0.8980392156862745, green: 0.8980392156862745, blue: 0.9176470588235294, alpha: 1.0)
    }
    
    static var systemBlue: UIColor {
        if #available(iOS 13, *) {
            return .systemBlue
        }
        return UIColor(red: 0.0, green: 0.47843137254901963, blue: 1.0, alpha: 1.0)
    }
    
    static var systemGreen: UIColor {
        if #available(iOS 13, *) {
            return .systemGreen
        }
        return UIColor(red: 0.20392156862745098, green: 0.7803921568627451, blue: 0.34901960784313724, alpha: 1.0)
    }
    
    static var systemRed: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        }
        return UIColor(red: 1.0, green: 0.23137254901960785, blue: 0.18823529411764706, alpha: 1.0)
    }
    
    static var systemOrange: UIColor {
        if #available(iOS 13, *) {
            return .systemOrange
        }
        return UIColor(red: 1.0, green: 0.5843137254901961, blue: 0.0, alpha: 1.0)
    }
}
