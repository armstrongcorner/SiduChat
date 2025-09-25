//
//  ShareViewModel.swift
//  SiduChat
//
//  Created by Armstrong Liu on 15/09/2025.
//

import Foundation

@MainActor
final class ShareViewModel: ObservableObject {
    @Published var currentTopic: TopicMessage?
    @Published var currentLoadedModel: Model? {
        didSet {
            onModelLoaded?(currentLoadedModel)
        }
    }
    
    var onModelLoaded: ((Model?) -> ())?
    
//    init(selectedTopic: TopicMessage) {
//        self.selectedTopic = selectedTopic
//    }
}
