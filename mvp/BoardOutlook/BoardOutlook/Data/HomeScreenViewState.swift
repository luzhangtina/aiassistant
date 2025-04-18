//
//  HomeViewState.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//

enum HomeScreenViewState {
    case loading
    case preparing
    case tryToObtainMicphonePermission
    case testMicrophone
    case checkIfUserIsReady
    case waitingForUserToConfirmReady
    case countdown
    case playingQuestion
    case waitForAnswer
    case answering
    case waitingForResponse
    case surveyIsCompleted
}

