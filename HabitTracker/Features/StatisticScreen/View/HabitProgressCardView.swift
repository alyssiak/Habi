//
//  HabitProgressCardView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import SnapKit

final class HabitProgressCardView: UIView {
    private let accentView = UIView()
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    
    private let daysView = HabitProgressDaysView()

    private let progressTitleLabel = UILabel()
    private let progressPercentLabel = UILabel()
    private let progressBackgroundView = UIView()
    private let progressFillView = UIView()
    private let completedLabel = UILabel()

    private var progressFillWidthConstraint: Constraint?
    private var progress: Double = 0
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupHeader()
        setupDays()
        setupProgress()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateProgressWidth()
    }
    
    func render(_ item: HabitProgressItem) {
        let accentColor = UIColor(hex: item.colorHex ?? "#F59733")
    
        accentView.backgroundColor = accentColor
        titleLabel.text = item.title
        streakLabel.text = "🔥 \(item.streak)"

        progressPercentLabel.text = item.progressText
        completedLabel.text = item.completedText
        progressFillView.backgroundColor = accentColor

        daysView.render(
            days: item.days,
            accentColor: accentColor
        )
        updateProgress(item.progress)
    }
    
}


//MARK: - Setup View
private extension HabitProgressCardView {
    func setupView() {
        backgroundColor = .appSecondaryBackground
        layer.cornerRadius = 16
    }

    func setupHeader() {
        accentView.layer.cornerRadius = 2

        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        streakLabel.font = UIFont(name: "Montserrat-SemiBold", size: 13)
        streakLabel.textColor = .secondaryLabel
        streakLabel.backgroundColor = .appBackground
        streakLabel.textAlignment = .center
        streakLabel.layer.cornerRadius = 12
        streakLabel.layer.masksToBounds = true

        addSubview(accentView)
        addSubview(titleLabel)
        addSubview(streakLabel)
    }

    func setupDays() {
        addSubview(daysView)
    }

    func setupProgress() {
        progressTitleLabel.text = "Progress"
        progressTitleLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        progressTitleLabel.textColor = .secondaryLabel

        progressPercentLabel.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        progressPercentLabel.textColor = .secondaryLabel
        progressPercentLabel.textAlignment = .right

        progressBackgroundView.backgroundColor = .systemGray5
        progressBackgroundView.layer.cornerRadius = 4
        progressBackgroundView.clipsToBounds = true

        progressFillView.layer.cornerRadius = 4

        completedLabel.font = UIFont(name: "Montserrat-Medium", size: 13)
        completedLabel.textColor = .secondaryLabel

        addSubview(progressTitleLabel)
        addSubview(progressPercentLabel)
        addSubview(progressBackgroundView)
        progressBackgroundView.addSubview(progressFillView)
        addSubview(completedLabel)
    }
}

//MARK: - Setup constraints
private extension HabitProgressCardView {
    func setupConstraints() {
        accentView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(22)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(4)
            make.height.equalTo(34)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(accentView)
            make.leading.equalTo(accentView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(streakLabel.snp.leading).offset(-12)
        }

        streakLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.greaterThanOrEqualTo(44)
            make.height.equalTo(28)
        }

        daysView.snp.makeConstraints { make in
            make.top.equalTo(accentView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        progressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(daysView.snp.bottom).offset(18)
            make.leading.equalToSuperview().inset(22)
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressTitleLabel)
            make.trailing.equalToSuperview().inset(22)
        }

        progressBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(progressTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(8)
        }

        progressFillView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            progressFillWidthConstraint = make.width.equalTo(0).constraint
        }

        completedLabel.snp.makeConstraints { make in
            make.top.equalTo(progressBackgroundView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

//MARK: - Render
private extension HabitProgressCardView {
    func updateProgress(_ progress: Double) {
        self.progress = max(0, min(progress, 1))
        setNeedsLayout()
    }

    func updateProgressWidth() {
        let width = progressBackgroundView.bounds.width * progress
        progressFillWidthConstraint?.update(offset: width)
    }
}
