//
//  LoadingView.swift
//  Weather
//
//  Created by Akram El Gouri on 14/11/2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
