//
//  JobListViewController.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 30.10.2023.
//

import UIKit

protocol JobListView: AnyObject {
    func updateJobs(_ jobs: [Models.Job])
    func updateBookButton(with count: Int)
    func updateSelectedJobsFromUserDefaults(_ jobs: [Models.Job])
}

fileprivate typealias JobDataSource = UICollectionViewDiffableDataSource<Models.Section, Models.Job>
fileprivate typealias JobDataSourceSnapshot = NSDiffableDataSourceSnapshot<Models.Section, Models.Job>

final class JobListViewController: UIViewController {

    var presenter: JobListPresenterProtocol?
    private lazy var dataSource = makeDataSource()

    // MARK: - UI

    private lazy var collectionView = {
        let layout = makeCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private lazy var bottomView: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        return bottomView
    }()

    private lazy var bookButton: UIButton =  {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.setTitle("Выберите подработки", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
        button.addTarget(self, action: #selector(didTapBookButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UISearchController

    private let searchController = UISearchController(searchResultsController: nil)

    private var selectedJobs: [Models.Job] = []
    private var allJobs: [Models.Job] = []
    private var filteredJobs: [Models.Job] = []

    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    private var searchBarIsFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    // MARK: - LyfeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        makeCollectionView()
        configureSearchController()

        presenter?.didLoadView()
    }

    // MARK: - Setup

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func makeCollectionView() {
        collectionView.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
        collectionView.allowsMultipleSelection = true
        collectionView.delaysContentTouches = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(JobCollectionViewCell.self, forCellWithReuseIdentifier: Models.CellIdentifier.jobCell.rawValue)
        collectionView.delegate = self
    }

    private func makeDataSource() -> JobDataSource {
        let dataSource = JobDataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, job) -> JobCollectionViewCell in

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Models.CellIdentifier.jobCell.rawValue,
                for: indexPath) as? JobCollectionViewCell
            else { return JobCollectionViewCell() }

            cell.configure(with: job)

            let imageURL = job.logo ?? ""
            self?.presenter?.didLoadImage(withUrl: imageURL) { image in
                DispatchQueue.main.async {
                    cell.logoImage.image = image
                }
            }

            return cell
        })

        return dataSource
    }

    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureUI() {
        addSubviews(for: view, subviews: collectionView)
        addSubviews(for: view, subviews: bottomView)
        addSubviews(for: bottomView, subviews: bookButton)

        view.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
        
        view.bringSubviewToFront(bottomView)
        bottomView.bringSubviewToFront(bookButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),

            bookButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 32),
            bookButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -32),
            bookButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 15),
            bookButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -32),

        ])
    }

    // MARK: - ObjC Selectors

    @objc private func didTapBookButton() {
        presenter?.didTapBookButton(selectedJobs, on: self)
    }
}

// MARK: - JobListView

extension JobListViewController: JobListView {
    func updateSelectedJobsFromUserDefaults(_ jobs: [Models.Job]) {
        self.selectedJobs = jobs
        presenter?.didUpdateBookButton(with: selectedJobs)
    }
    

    func updateJobs(_ jobs: [Models.Job]) {
        // для дальнейшей фильтрации
        allJobs = jobs

        var snapshot = JobDataSourceSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(jobs, toSection: .main)

        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updateBookButton(with count: Int) {
        if count > 0 {
            bookButton.isEnabled = true
            bookButton.backgroundColor = UIColor(red: 247 / 255, green: 206 / 255, blue: 23 / 255, alpha: 1)
            bookButton.setTitle("Забронировать " + getPodrabotkaFormat(count), for: .normal)
        } else {
            bookButton.isEnabled = false
            bookButton.backgroundColor = UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
            bookButton.setTitle("Выберите подработки", for: .normal)
        }
    }

    private func getPodrabotkaFormat(_ count: Int) -> String {
        let cases: [Int: String] = [1: "подработку", 2: "подработки", 3: "подработки", 4: "подработки"]

        if count % 100 >= 11 && count % 100 <= 14 {
            return "\(count) подработок"
        } else if let word = cases[count % 10] {
            return "\(count) \(word)"
        } else {
            return "\(count) подработок"
        }
    }
}

// MARK: - UICollectionViewDelegate

extension JobListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if searchBarIsFiltering {
            // 1) Получаем айтем, на который нажали, из фильтрованного списка
            let jobFromFiltered = filteredJobs[indexPath.row]
            var jobIndexFromAllJobs: Array.Index?

            // 2) Находим этот же айтем в основном списке
            allJobs.forEach { job in
                if jobFromFiltered == job {
                    jobIndexFromAllJobs = allJobs.firstIndex(of: job)
                }
            }

            // 3) Получаем индекс элемента из allJobs и извлекаем опционал из jobFromFiltered.isSelected
            guard
                let jobIndexFromAllJobs,
                let isSelected = jobFromFiltered.isSelected
            else { return }

            if !isSelected {
                // Ставим в обоих списках isSelected = true
                filteredJobs[indexPath.row].isSelected = true
                allJobs[jobIndexFromAllJobs].isSelected = true

                // 4) Делаем новый снапшот и сохраняем датасурс с фильтрованным обновлённым списком
                var snapshot = JobDataSourceSnapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(filteredJobs, toSection: .main)

                DispatchQueue.main.async { [weak self] in
                    self?.dataSource.apply(snapshot, animatingDifferences: true)
                }

                // 5) Добавляем в selectedJobs для отображения количества в кнопке
                selectedJobs.append(jobFromFiltered)

                // 6) Обновляем кол-во в кнопке и сохраняем изменения в UserDefaults
                presenter?.didUpdateBookButton(with: selectedJobs)
                presenter?.didSaveToUserDefaults(allJobs)
            } else {
                // 3) Ставим в обоих списках isSelected = false
                filteredJobs[indexPath.row].isSelected = false
                allJobs[jobIndexFromAllJobs].isSelected = false

                // 4) Делаем новый снапшот и сохраняем датасурс с фильтрованным обновлённым списком
                var snapshot = JobDataSourceSnapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(filteredJobs, toSection: .main)

                DispatchQueue.main.async { [weak self] in
                    self?.dataSource.apply(snapshot, animatingDifferences: true)
                }

                // 5) Убираем из selectedJobs для отображения количества в кнопке
                if let jobIndexToDeselect = selectedJobs.firstIndex(where: { $0.id == jobFromFiltered.id }) {
                    selectedJobs.remove(at: jobIndexToDeselect)
                }

                // 6) Обновляем кол-во в кнопке и сохраняем изменения в UserDefaults
                presenter?.didUpdateBookButton(with: selectedJobs)
                presenter?.didSaveToUserDefaults(allJobs)
            }
        } else {
            // 1) Делаем новый снапшот и сохраняем датасурс с основным списком, вдруг после фильтрации были апдейты
            var snapshot = JobDataSourceSnapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(allJobs, toSection: .main)

            DispatchQueue.main.async { [weak self] in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }

            presenter?.didSaveToUserDefaults(allJobs)

            // 2) Получаем айтем, на который нажали
            let jobFromAllJobs = allJobs[indexPath.row]

            // 3) Находим индекс айтема в фильтрованном списке, но его может не быть
            var jobIndexFromFilteredJobs: Array.Index?

            filteredJobs.forEach { filteredJob in
                if filteredJob == jobFromAllJobs {
                    jobIndexFromFilteredJobs = filteredJobs.firstIndex(of: filteredJob)
                }
            }

            // Извлекаем опционал из jobFromAllJobs.isSelected
            guard let isSelected = jobFromAllJobs.isSelected else { return }

            if !isSelected {
                // 4) Если в фильтрованном списке нашлось, то ставим в обоих списках isSelected = true
                allJobs[indexPath.row].isSelected = true

                if let jobIndexFromFilteredJobs {
                    filteredJobs[jobIndexFromFilteredJobs].isSelected = true
                }

                // 5) Добавляем в selectedJobs для отображения количества в кнопке
                selectedJobs.append(jobFromAllJobs)

                // 6) Обновляем изменения в кнопке
                presenter?.didUpdateBookButton(with: selectedJobs)

                // 7) Делаем новый снапшот и сохраняем датасурс с обновлённым списком
                var anotherSnapshot = JobDataSourceSnapshot()
                anotherSnapshot.appendSections([.main])
                anotherSnapshot.appendItems(allJobs, toSection: .main)

                DispatchQueue.main.async { [weak self] in
                    self?.dataSource.apply(anotherSnapshot, animatingDifferences: true)
                }

                // 8) Сохраняем данные в UserDefaults
                presenter?.didSaveToUserDefaults(allJobs)
            } else {
                // 4) Если в фильтрованном списке нашлось, то ставим в обоих списках isSelected = true
                allJobs[indexPath.row].isSelected = false

                if let jobIndexFromFilteredJobs {
                    filteredJobs[jobIndexFromFilteredJobs].isSelected = false
                }

                // 5) Убираем из selectedJobs для отображения количества в кнопке
                if let jobIndexToDeselect = selectedJobs.firstIndex(where: { $0.id == jobFromAllJobs.id }) {
                    selectedJobs.remove(at: jobIndexToDeselect)
                }

                // 6) Обновляем кол-во в кнопке
                presenter?.didUpdateBookButton(with: selectedJobs)

                // 7) Делаем новый снапшот и сохраняем датасурс с обновлённым списком
                var anotherSnapshot = JobDataSourceSnapshot()
                anotherSnapshot.appendSections([.main])
                anotherSnapshot.appendItems(allJobs, toSection: .main)

                DispatchQueue.main.async { [weak self] in
                    self?.dataSource.apply(anotherSnapshot, animatingDifferences: true)
                }

                // 8) Сохраняем данные в UserDefaults
                presenter?.didSaveToUserDefaults(allJobs)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating

extension JobListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        filterContentForSearchText(searchText)
    }

    private func filterContentForSearchText(_ searchText: String) {
        let jobs = allJobs

        if searchBarIsFiltering {
            filteredJobs = jobs.filter({ job in
                job.profession.lowercased().contains(searchText.lowercased()) || job.employer.lowercased().contains(searchText.lowercased())
            })
            var newSnapshot = JobDataSourceSnapshot()
            newSnapshot.appendSections([.main])
            newSnapshot.appendItems(filteredJobs, toSection: .main)
            dataSource.apply(newSnapshot, animatingDifferences: true)
        } else {
            var snapshot = JobDataSourceSnapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(jobs, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}
