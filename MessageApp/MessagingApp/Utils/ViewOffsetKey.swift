//
//  ViewOffsetKey.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 26/5/25.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
