//
//  UserDefaultsManager.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 05.11.2023.
//

import UIKit

protocol RepositoryProtocol {
    func getJobs() -> [Models.Job]
    func saveJobs(_ jobs: [Models.Job])
}

class UserDefaultsManager: RepositoryProtocol {
    func getJobs() -> [Models.Job] {
        if let data = UserDefaults.standard.data(forKey: "allJobs") {
            do {
                let savedJobs = try PropertyListDecoder().decode([Models.Job].self, from: data)
                return savedJobs
            } catch {
                print("Failed to decode data from UserDefaults")
            }
        }
        return []
    }
    
    func saveJobs(_ jobs: [Models.Job]) {
        do {
            let data = try PropertyListEncoder().encode(jobs)
            UserDefaults.standard.set(data, forKey: "allJobs")
            print(try! PropertyListDecoder().decode([Models.Job].self, from: data))
        } catch {
            print("Failed to save data to UserDefaults")
        }
    }
}
