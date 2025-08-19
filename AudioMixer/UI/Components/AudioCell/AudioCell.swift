//
//  AudioCell.swift
//  AudioMixer
//
//  Created by EF2025 on 18/8/25.
//

import SwiftUI

struct AudioCell: View {
    var body: some View {
        VStack (spacing: 8) {
            HStack {
                Text("Tên file audio")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.neutral07)
                Spacer()
            }
            HStack {
                // Thời gian ghi/Thời gian thêm bản nhạc
                Text("15:00")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.grayPrimary)
                Spacer()
                // Độ dài bản ghi
                Text("0:54")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.grayPrimary)
            }
        }
    }
}

#Preview {
    AudioCell()
}
