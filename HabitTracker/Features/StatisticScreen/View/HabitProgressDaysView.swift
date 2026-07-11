//
//  HabitProgressDaysView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 11.07.2026.
//

import UIKit
import SnapKit

final class HabitProgressDaysView: UIView {
    private let weekTitleStackView = UIStackView()
    private let weekSquaresStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupWeekStackViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(
        days: [HabitProgressDay],
        accentColor: UIColor
    ) {
        clearWeekDays()
        renderWeekDays(days, accentColor: accentColor)
    }
}

//MARK: - Setup View
private extension HabitProgressDaysView {
    func setupView() {
        backgroundColor = .clear
    }

    func setupWeekStackViews() {
        weekTitleStackView.axis = .horizontal
        weekTitleStackView.distribution = .fillEqually
        weekTitleStackView.spacing = 8

        weekSquaresStackView.axis = .horizontal
        weekSquaresStackView.distribution = .fillEqually
        weekSquaresStackView.spacing = 8

        addSubview(weekTitleStackView)
        addSubview(weekSquaresStackView)
    }

    func setupConstraints() {
        weekTitleStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }

        weekSquaresStackView.snp.makeConstraints { make in
            make.top.equalTo(weekTitleStackView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(34)
            make.bottom.equalToSuperview()
        }
    }
}

//MARK: - Render week/month
private extension HabitProgressDaysView {
    func renderWeekDays(_ days: [HabitProgressDay], accentColor: UIColor) {
        days.forEach { day in
            let titleLabel = UILabel()
            titleLabel.text = day.title
            titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
            titleLabel.textColor = .secondaryLabel
            titleLabel.textAlignment = .center

            let dayView = makeDayView(
                day,
                accentColor: accentColor,
                size: 34,
                showsTitleInside: false
            )

            weekTitleStackView.addArrangedSubview(titleLabel)
            weekSquaresStackView.addArrangedSubview(dayView)
        }
    }

}

//MARK: - Helpers
private extension HabitProgressDaysView {
    func makeDayView(
        _ day: HabitProgressDay,
        accentColor: UIColor,
        size: CGFloat,
        showsTitleInside: Bool
    ) -> UIView {
        let dayView = UIView()
        dayView.layer.cornerRadius = size / 2

        if day.isFuture {
            dayView.backgroundColor = .systemGray5
        } else {
            dayView.backgroundColor = day.isCompleted
                ? accentColor
                : UIColor(hex: "#E9DDF5")
        }

        if day.isCompleted {
            addCheckmark(to: dayView)
        } else if showsTitleInside {
            addTitle(day.title, to: dayView, isFuture: day.isFuture)
        }

        dayView.snp.makeConstraints { make in
            make.height.equalTo(size)
        }

        return dayView
    }

    func addTitle(_ title: String, to view: UIView, isFuture: Bool) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        titleLabel.textColor = isFuture ? .tertiaryLabel : .secondaryLabel
        titleLabel.textAlignment = .center

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func addCheckmark(to view: UIView) {
        let image = UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)
        )

        let checkImageView = UIImageView(image: image)
        checkImageView.tintColor = .white
        checkImageView.contentMode = .scaleAspectFit

        view.addSubview(checkImageView)

        checkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(14)
        }
    }

    func clearWeekDays() {
        weekTitleStackView.arrangedSubviews.forEach { view in
            weekTitleStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        weekSquaresStackView.arrangedSubviews.forEach { view in
            weekSquaresStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

}
