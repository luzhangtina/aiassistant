//
//  User.swift
//  BoardOutlook
//
//  Created by lu on 29/3/2025.
//

struct InterviewProgress: Codable {
    var numberOfTotalQuestions: Int
    var questions: [InterviewQuestions]
    var currentNumberOfQuestion: Int
    var progress: Int
    var currentQuestion: String
    var audioBase64: String
}
