//
//  Job.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 30.10.2023.
//

import Foundation

enum Models {

    struct Job: Codable, Hashable, Identifiable {
        let salary: Double
        let profession: String
        let id: String
        let date: String
        let employer: String
        let logo: String?

        var isSelected: Bool?
    }

    enum Section {
        case main
    }

    enum CellIdentifier: String {
        case jobCell
    }
}


