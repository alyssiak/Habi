//
//  HabitDetailsStatsView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.06.2026.
//

import UIKit
import SnapKit

final class HabitDetailsStatsView: UIView {
    private let mainStackView = UIStackView()
    private let completedDaysStackView = UIStackView()
    private let bestStreakStackView = UIStackView()

    private let completedDaysCardView = UIView()
    private let bestStreakCardView = UIView()

    private let completedDaysValueLabel = UILabel()
    private let completedDaysTitleLabel = UILabel()

    private let bestStreakValueLabel = UILabel()
    private let bestStreakTitleLabel = UILabel()

    override init (frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupCards()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(completedDays: Int, bestStreak: Int) {
        completedDaysValueLabel.text = "\(completedDays)"
        bestStreakValueLabel.text = "\(bestStreak)"
    }
}


private extension HabitDetailsStatsView {
    func setupView() {
        backgroundColor = .clear

        mainStackView.axis = .horizontal
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 20
        mainStackView.alignment = .fill

        addSubview(mainStackView)
    }

    func setupCards() {
        completedDaysTitleLabel.text = "Completed days"
        completedDaysTitleLabel.textColor = .secondaryLabel
        completedDaysTitleLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        completedDaysTitleLabel.textAlignment = .center

        completedDaysValueLabel.textColor = .appOrange
        completedDaysValueLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        completedDaysValueLabel.textAlignment = .center

        bestStreakTitleLabel.text = "Best streak"
        bestStreakTitleLabel.textColor = .secondaryLabel
        bestStreakTitleLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        bestStreakTitleLabel.textAlignment = .center

        bestStreakValueLabel.textColor = .appOrange
        bestStreakValueLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        bestStreakValueLabel.textAlignment = .center

        completedDaysCardView.backgroundColor = .appGray
        completedDaysCardView.layer.cornerRadius = 8
        completedDaysCardView.layer.borderWidth = 1
        completedDaysCardView.layer.borderColor = UIColor.systemGray5.cgColor

        bestStreakCardView.backgroundColor = .appGray
        bestStreakCardView.layer.cornerRadius = 8
        bestStreakCardView.layer.borderWidth = 1
        bestStreakCardView.layer.borderColor = UIColor.systemGray5.cgColor

        completedDaysStackView.axis = .vertical
        completedDaysStackView.alignment = .center
        completedDaysStackView.spacing = 4

        bestStreakStackView.axis = .vertical
        bestStreakStackView.alignment = .center
        bestStreakStackView.spacing = 4

        mainStackView.addArrangedSubview(completedDaysCardView)
        mainStackView.addArrangedSubview(bestStreakCardView)

        completedDaysCardView.addSubview(completedDaysStackView)
        completedDaysStackView.addArrangedSubview(completedDaysValueLabel)
        completedDaysStackView.addArrangedSubview(completedDaysTitleLabel)

        bestStreakCardView.addSubview(bestStreakStackView)
        bestStreakStackView.addArrangedSubview(bestStreakValueLabel)
        bestStreakStackView.addArrangedSubview(bestStreakTitleLabel)
    }

    func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        completedDaysStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }

        bestStreakStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
}
