//
//  OfferPresenter.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 30.10.2023.
//

import UIKit

protocol JobListPresenterProtocol {
    func didLoadView()
    func didTapBookButton(_ jobs: [Models.Job], on viewController: UIViewController)
    func didUpdateBookButton(with jobs: [Models.Job])
    func didLoadImage(withUrl URL: String, completion: @escaping(UIImage) -> Void)
    func didSaveToUserDefaults(_ jobs: [Models.Job])
}

class JobListPresenter: JobListPresenterProtocol {

    weak var view: JobListView?

    private var networkManager: NetworkManagerProtocol
    private var imageCacheManager: ImageCacheManagerProtocol
    private var userDefaultsManager: RepositoryProtocol

    init(view: JobListView, networkManager: NetworkManagerProtocol, imageCacheManager: ImageCacheManagerProtocol, userDefaultsManager: RepositoryProtocol) {
        self.view = view
        self.networkManager = networkManager
        self.imageCacheManager = imageCacheManager
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Presenter Methods

    func didLoadView() {
        let savedJobs = userDefaultsManager.getJobs()

        // Если есть данные в UserDefaults
        if !savedJobs.isEmpty {
            self.updateView(with: savedJobs)

            // Для восстановления статуса кнопки, если данные берутся из UserDefaults
            var selectedJobs = savedJobs.filter { $0.isSelected == true }
            self.updateSelectedJobsFromUserDefaults(selectedJobs)
        } else {
            networkManager.fetchJobs { [weak self] result in
                switch result {
                case .success(let jobs):
                    self?.userDefaultsManager.saveJobs(jobs)
                    self?.updateView(with: jobs)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func didLoadImage(withUrl URL: String, completion: @escaping(UIImage) -> Void) {

        if let cachedImage = imageCacheManager.image(forKey: URL) {
            completion(cachedImage)
        } else {
            networkManager.fetchImage(from: URL) { [weak self] image in
                if let image {
                    completion(image)
                    self?.imageCacheManager.setImage(image, forKey: URL)
                } else {
                    guard let image = UIImage(named: "default") else { return }
                    completion(image)
                    self?.imageCacheManager.setImage(image, forKey: URL)
                }
            }
        }
    }

    func didSaveToUserDefaults(_ jobs: [Models.Job]) {
        userDefaultsManager.saveJobs(jobs)
    }

    func didTapBookButton(_ jobs: [Models.Job], on viewController: UIViewController) {
        var money = 0.0
        jobs.forEach { job in
            money += job.salary
        }
        let roundedAmount = roundedPrice(from: money.description)

        let alert = UIAlertController(
            title: "Ураа! Деняк насыпали!",
            message: "Вы заработали \(roundedAmount) рублей =)",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)

        viewController.present(alert, animated: true)
    }

    func didUpdateBookButton(with jobs: [Models.Job]) {
        view?.updateBookButton(with: jobs.count)
    }

    // MARK: - Private Methods

    private func updateSelectedJobsFromUserDefaults(_ jobs: [Models.Job]) {
        view?.updateSelectedJobsFromUserDefaults(jobs)
    }

    private func updateView(with jobs: [Models.Job]) {
        view?.updateJobs(jobs)
    }
}
