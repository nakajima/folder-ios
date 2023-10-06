//
//  Path.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import Foundation

#if canImport(SwiftUI)
    import SwiftUI

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public extension Path {
        func roundedPath(radius: CGFloat) -> Self {
            let cgCopy = cgPath.copy(roundingCornersToRadius: radius)
            return Path(cgCopy)
        }
    }

#endif
