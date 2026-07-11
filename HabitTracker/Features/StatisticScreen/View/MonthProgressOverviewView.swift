//
//  MonthProgressOverviewView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 11.07.2026.
//

import UIKit
import SnapKit

final class MonthProgressOverviewView: UIView {
    var onPreviousMonthTapped: (() -> Void)?
    var onNextMonthTapped: (() -> Void)?

    private let headerStackView = UIStackView()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let gridStackView = UIStackView()
    private let legendStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupHeader()
        setupGrid()
        setupLegend()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(
        monthTitle: String?,
        days: [MonthProgressDay],
        canShowNextMonth: Bool
    ) {
        clearGrid()
        titleLabel.text = monthTitle ?? "Monthly overview"
        nextButton.isEnabled = canShowNextMonth
        nextButton.alpha = canShowNextMonth ? 1 : 0.35

        days.chunked(into: 7).forEach { rowDays in
            let rowStackView = makeRowStackView()

            rowDays.forEach { day in
                rowStackView.addArrangedSubview(makeDayView(day))
            }

            let missingDays = 7 - rowDays.count
            if missingDays > 0 {
                (0..<missingDays).forEach { _ in
                    rowStackView.addArrangedSubview(UIView())
                }
            }

            gridStackView.addArrangedSubview(rowStackView)
        }
    }
}

//MARK: - Setup
private extension MonthProgressOverviewView {
    func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }

    func setupHeader() {
        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.tintColor = .label
        previousButton.addTarget(self, action: #selector(didTapPreviousMonth), for: .touchUpInside)

        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .label
        nextButton.addTarget(self, action: #selector(didTapNextMonth), for: .touchUpInside)

        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .fill
        headerStackView.spacing = 12
        headerStackView.addArrangedSubview(previousButton)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(nextButton)

        previousButton.setContentHuggingPriority(.required, for: .horizontal)
        nextButton.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(headerStackView)
    }

    func setupGrid() {
        gridStackView.axis = .vertical
        gridStackView.spacing = 8

        addSubview(gridStackView)
    }

    func setupLegend() {
        legendStackView.axis = .horizontal
        legendStackView.spacing = 14
        legendStackView.alignment = .center

        legendStackView.addArrangedSubview(makeLegendItem(color: .appOrange, title: "Done"))
        legendStackView.addArrangedSubview(makeLegendItem(color: UIColor.appOrange.withAlphaComponent(0.55), title: "Partial"))
        legendStackView.addArrangedSubview(makeLegendItem(color: .systemGray5, title: "Upcoming"))

        addSubview(legendStackView)
    }

    func setupConstraints() {
        headerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        previousButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        nextButton.snp.makeConstraints { make in
            make.size.equalTo(32)
        }

        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        legendStackView.snp.makeConstraints { make in
            make.top.equalTo(gridStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
}

//MARK: - Helpers
private extension MonthProgressOverviewView {
    @objc func didTapPreviousMonth() {
        onPreviousMonthTapped?()
    }

    @objc func didTapNextMonth() {
        onNextMonthTapped?()
    }

    func makeRowStackView() -> UIStackView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.distribution = .fillEqually
        rowStackView.spacing = 8
        return rowStackView
    }

    func makeDayView(_ day: MonthProgressDay) -> UIView {
        let dayView = UIView()
        dayView.layer.cornerRadius = 16
        dayView.backgroundColor = color(for: day)

        let titleLabel = UILabel()
        titleLabel.text = day.title
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = day.progress >= 1 ? .white : .secondaryLabel

        dayView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        dayView.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        return dayView
    }

    func color(for day: MonthProgressDay) -> UIColor {
        if day.isFuture {
            return .systemGray5
        }

        if day.progress >= 1 {
            return .appOrange
        }

        if day.progress > 0 {
            return UIColor.appOrange.withAlphaComponent(0.35 + (CGFloat(day.progress) * 0.35))
        }

        return UIColor(hex: "#E9DDF5")
    }

    func makeLegendItem(color: UIColor, title: String) -> UIView {
        let containerView = UIView()
        let dotView = UIView()
        let titleLabel = UILabel()

        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 4

        titleLabel.text = title
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 12)
        titleLabel.textColor = .secondaryLabel

        containerView.addSubview(dotView)
        containerView.addSubview(titleLabel)

        dotView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(dotView.snp.trailing).offset(6)
            make.top.bottom.trailing.equalToSuperview()
        }

        return containerView
    }

    func clearGrid() {
        gridStackView.arrangedSubviews.forEach { view in
            gridStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
