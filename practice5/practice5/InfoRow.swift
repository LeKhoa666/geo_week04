//
//  InfoRow.swift
//  practice5
//
//  Created by MAY 05 on 26/10/26.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .fontWeight(.medium)
                    .foregroundColor(valueColor)
                    .monospacedDigit()
            }
            .padding(.vertical, 8)
            Divider()
        }
    }
}

