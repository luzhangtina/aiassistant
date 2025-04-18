//
//  User.swift
//  BoardOutlook
//
//  Created by lu on 29/3/2025.
//

struct UserAnswer: Codable {
    var messageType: String
    var userId: String
    var audioBase64: String?
    var isFirstChunk: Bool
    var isLastChunk: Bool
}
