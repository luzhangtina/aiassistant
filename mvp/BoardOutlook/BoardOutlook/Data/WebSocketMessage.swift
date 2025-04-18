//
//  WebSocketMessage.swift
//  BoardOutlook
//
//  Created by lu on 18/4/2025.
//

import Foundation

enum WebSocketMessageType: String, Codable {
    case isUserReadyRequest = "IsUserReadyRequest"
    case isUserReadyResponse = "IsUserReadyResponse"
    case userInterviewAnswer = "UserInterviewAnswer"
}

struct UserInterviewAnswer: Codable {
    var userId: String
    var interviewId: String?
    var audioBase64: String?
    var isFirstAudioChunk: Bool
    var isLastAudioChunk: Bool
}

struct IsUserReadyResponse: Codable {
    var userId: String
    var isUserReady: Bool
    var transcript: String
}

enum WebSocketMessageData {
    case isUserReadyResponse(IsUserReadyResponse)
    case userInterviewAnswer(UserInterviewAnswer)
}

struct WebSocketMessage: Codable {
    let messageType: WebSocketMessageType
    let data: WebSocketMessageData

    enum CodingKeys: String, CodingKey {
        case messageType
        case data
    }

    init(messageType: WebSocketMessageType, data: WebSocketMessageData) {
        self.messageType = messageType
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageType = try container.decode(WebSocketMessageType.self, forKey: .messageType)

        switch messageType {
        case .isUserReadyRequest, .userInterviewAnswer:
            let value = try container.decode(UserInterviewAnswer.self, forKey: .data)
            data = .userInterviewAnswer(value)
        case .isUserReadyResponse:
            let value = try container.decode(IsUserReadyResponse.self, forKey: .data)
            data = .isUserReadyResponse(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageType, forKey: .messageType)

        switch data {
        case .isUserReadyResponse(let value):
            try container.encode(value, forKey: .data)
        case .userInterviewAnswer(let value):
            try container.encode(value, forKey: .data)
        }
    }
}
