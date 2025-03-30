//
//  InterviewSummary.swift
//  BoardOutlook
//
//  Created by lu on 30/3/2025.
//

struct InterviewHistoryItem: Codable {
    var title: String
    var duration: Int
    var date: String
    var interviewSummary: [InterviewSummaryItem]
}
