//
//  TopHabitsChartView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 11.07.2026.
//

import UIKit
import SnapKit

final class TopHabitsChartView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let barsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupTitle()
        setupBars()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(items: [TopHabitProgressItem]) {
        isHidden = items.isEmpty
        clearBars()

        items.forEach { item in
            barsStackView.addArrangedSubview(makeBarItemView(item))
        }
    }
}

//MARK: - Setup
private extension TopHabitsChartView {
    func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }

    func setupTitle() {
        titleLabel.text = "Top habits"
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        titleLabel.textColor = .label

        subtitleLabel.text = "Most completed this month"
        subtitleLabel.font = UIFont(name: "Montserrat-Medium", size: 13)
        subtitleLabel.textColor = .secondaryLabel

        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }

    func setupBars() {
        barsStackView.axis = .horizontal
        barsStackView.alignment = .bottom
        barsStackView.distribution = .fillEqually
        barsStackView.spacing = 14

        addSubview(barsStackView)
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }

        barsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(132)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

//MARK: - Bar
private extension TopHabitsChartView {
    func makeBarItemView(_ item: TopHabitProgressItem) -> UIView {
        let containerView = UIView()
        let percentLabel = UILabel()
        let barBackgroundView = UIView()
        let barFillView = UIView()
        let titleLabel = UILabel()
        let completedLabel = UILabel()

        let accentColor = UIColor(hex: item.colorHex ?? "#F59733")

        percentLabel.text = item.progressText
        percentLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        percentLabel.textColor = .label
        percentLabel.textAlignment = .center

        barBackgroundView.backgroundColor = accentColor.withAlphaComponent(0.18)
        barBackgroundView.layer.cornerRadius = 6
        barBackgroundView.clipsToBounds = true

        barFillView.backgroundColor = accentColor
        barFillView.layer.cornerRadius = 6

        titleLabel.text = item.title
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 11)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        completedLabel.text = item.completedText
        completedLabel.font = UIFont(name: "Montserrat-Medium", size: 11)
        completedLabel.textColor = .tertiaryLabel
        completedLabel.textAlignment = .center

        containerView.addSubview(percentLabel)
        containerView.addSubview(barBackgroundView)
        barBackgroundView.addSubview(barFillView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(completedLabel)

        percentLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        barBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(percentLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(72)
        }

        barFillView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(CGFloat(72 * max(0.08, item.progress)))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(barBackgroundView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        completedLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return containerView
    }

    func clearBars() {
        barsStackView.arrangedSubviews.forEach { view in
            barsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
