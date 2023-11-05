//
//  NetworkManager.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 31.10.2023.
//

import UIKit

enum NetworkingError: Error {
    case invalidURL
    case fileNotFound(url: String)
    case networkError(message: String)
}

protocol NetworkManagerProtocol {
    func fetchJobs(completion: @escaping(Result<[Models.Job], Error>) -> Void)
    func fetchImage(from urlString: String, completion: @escaping(UIImage?) -> Void)
}

class NetworkManager: NetworkManagerProtocol {

    func fetchJobs(completion: @escaping (Result<[Models.Job], Error>) -> Void) {
        guard let url = URL(string: "http://185.174.137.159/jobs") else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                guard let data else {
                    completion(.failure(NetworkingError.fileNotFound(url: url.description)))
                    return
                }

                do {
                    var jobs = try JSONDecoder().decode([Models.Job].self, from: data)

                    jobs = jobs.map { job in
                        var mutableJob = job
                        mutableJob.isSelected = false
                        return mutableJob
                    }
                    completion(.success(jobs))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }

    func fetchImage(from urlString: String, completion: @escaping(UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error {
                    print("Failed to load image: \(error)")
                    completion(nil)
                    return
                }

                guard let data, let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }

                completion(image)
            }.resume()
        }
    }
}

// P.S. Когда-нибудь файл с json на сервере умрёт, поэтому оставлю это здесь на будущее, чтоб вспомнить, че к чему =)
//
// [{"id":"1","profession":"Слесарь","employer":"Наша Мебель","salary":500,"date":"2023-11-05T23:05:43Z"},{"id":"2","logo":"https:\/\/i.imgur.com\/x8DcFXl.png","profession":"Кассир","employer":"Пятёрочка","salary":900,"date":"2023-11-06T01:52:23Z"},{"id":"3","logo":"https:\/\/i.imgur.com\/wIPhLsM.jpg","profession":"Мерчендайзер","employer":"Магнит","salary":800,"date":"2023-11-06T04:39:03Z"},{"id":"4","profession":"iOS-разработчик","employer":"MyGig","salary":111.11,"date":"2023-11-06T07:25:43Z"},{"id":"5","logo":"https:\/\/i.imgur.com\/x8DcFXl.png","profession":"Грузчик","employer":"Пятёрочка","salary":1500,"date":"2023-11-06T10:12:23Z"},{"id":"6","logo":"https:\/\/i.imgur.com\/x8DcFXl.png","profession":"Уборщик","employer":"Пятёрочка","salary":500,"date":"2023-11-06T12:59:03Z"},{"id":"7","profession":"Преподаватель","employer":"Skillbox","salary":100,"date":"2023-11-06T15:45:43Z"},{"id":"8","profession":"Человек-паук","employer":"Marvel","salary":50000,"date":"2023-11-06T18:32:23Z"},{"id":"9","profession":"Советник","employer":"Кремль","salary":5555.55,"date":"2023-11-06T21:19:03Z"},{"id":"10","profession":"Робокоп","employer":"МВД","salary":0.01,"date":"2023-11-07T00:05:43Z"}]
