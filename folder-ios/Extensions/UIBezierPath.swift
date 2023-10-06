//
//  UIBezierPath.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

#if canImport(UIKit)

    import UIKit

    public extension UIBezierPath {
        func copy(roundingCornersToRadius radius: CGFloat) -> UIBezierPath {
            let cgCopy = cgPath.copy(roundingCornersToRadius: radius)
            return UIBezierPath(cgPath: cgCopy)
        }
    }

#endif
