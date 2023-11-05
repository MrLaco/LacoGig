//
//  SalaryView.swift
//  LacoGig
//
//  Created by Данил Терлецкий on 05.11.2023.
//

import UIKit

class RoundedView: UIView {

    // MARK: - UI

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - LyfeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupView() {
        layer.cornerRadius = 4
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

    private func setupConstraints() {
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
}
