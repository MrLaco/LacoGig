//
//  JobCollectionViewCell.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 30.10.2023.
//

import UIKit

class JobCollectionViewCell: UICollectionViewCell {

    // MARK: - UI

    lazy var professionLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var salaryView: RoundedView = {
        let view = RoundedView()
        view.backgroundColor = UIColor(red: 247 / 255, green: 206 / 255, blue: 23 / 255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = CGColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var employerLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var dateView: RoundedView = {
        let view = RoundedView()
        view.backgroundColor = UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
        return view
    }()

    lazy var timeView: RoundedView = {
        let view = RoundedView()
        view.backgroundColor = UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
        return view
    }()

    lazy var dateTimeView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - LyfeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowRadius = 4
    }

    // MARK: - Setup

    func configure(with job: Models.Job) {
        professionLabel.text = job.profession

        salaryView.label.text = roundedPrice(from: job.salary.description) + " ₽"
        employerLabel.text = job.employer

        dateView.label.text = getDate(from: job.date)
        timeView.label.text = getTime(from: job.date)

        guard let isSelected = job.isSelected else { return }

        if isSelected {
            contentView.layer.borderWidth = 2.0
            contentView.layer.borderColor = UIColor(red: 247 / 255, green: 206 / 255, blue: 23 / 255, alpha: 1).cgColor
            contentView.layer.shadowColor = UIColor(red: 247 / 255, green: 206 / 255, blue: 23 / 255, alpha: 0.4).cgColor
        } else {
            contentView.layer.borderWidth = 0.0
            contentView.layer.borderColor = nil
            contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        }
    }

    private func setupConstraints() {
        addSubviews(for: contentView, subviews: professionLabel, salaryView, dateTimeView, separator, logoImage, employerLabel)
        addSubviews(for: dateTimeView, subviews: dateView, timeView)

        NSLayoutConstraint.activate([
            professionLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            professionLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 15),

            salaryView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            salaryView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 15),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            separator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            logoImage.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            logoImage.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            logoImage.widthAnchor.constraint(equalToConstant: 32),
            logoImage.heightAnchor.constraint(equalToConstant: 32),

            employerLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 10),
            employerLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -18),

            dateTimeView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            dateTimeView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -18),
        ])
    }

    // MARK: - Private Methods

    private func getDate(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: dateString) {
            let dateFormatterDate = DateFormatter()
            dateFormatterDate.dateFormat = "dd.MM"
            let formattedDate = dateFormatterDate.string(from: date)

            return formattedDate
        } else {
            print("Error while parsing date")
            return ""
        }
    }

    private func getTime(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: dateString) {
            let dateFormatterTime = DateFormatter()
            dateFormatterTime.dateFormat = "HH:mm"
            let formattedTime = dateFormatterTime.string(from: date)

            return formattedTime
        } else {
            print("Error while parsing time")
            return ""
        }
    }
}
