//
//  NailsMask.swift
//  ARBeauty
//
//  Created by Huong Lam on 05/30/2021.
//

import Foundation
import SwiftUI

struct NailMask: View {
    var image: UIImage!
    var scaleFactor: CGFloat = 1.0
    var offset = CGSize()
    var shape: String!
    var mask: some View {
        Image(shape)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80)
    }
    
    var body: some View {
        if let image = image {
            mask
                .overlay(
                    Image(uiImage: image)
                        .scaleEffect(scaleFactor)
                        .offset(offset)
                        .mask(mask)
                )
        } else {
            mask.foregroundColor(.accentColor)
        }
        
    }
}
