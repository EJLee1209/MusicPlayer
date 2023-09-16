//
//  UIView+Extension.swift
//  MusicPlayer
//
//  Created by 이은재 on 2023/09/16.
//

import UIKit

extension UIView {
    func addCornerRadius(_ radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
    }
    
}
