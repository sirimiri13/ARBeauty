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
    var scaleFactor: CGFloat = 2
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



struct NailMaskRealtime: View {
    var image: UIImage!
    var scaleFactor: CGFloat = 2
    var offset = CGSize()
    var shape: UIImage!
    var mask: some View {
        Image(uiImage: shape)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80)
    }
    
    var body: some View {
        if let image = image {
            mask
                .overlay(
                    Image(uiImage: UIImage(named: "Layer1")!)
                        .scaleEffect(scaleFactor)
                        .offset(offset)
                        .mask(mask)
                )
               
        } else {
            mask.foregroundColor(.accentColor)
        }
        
    }
}
