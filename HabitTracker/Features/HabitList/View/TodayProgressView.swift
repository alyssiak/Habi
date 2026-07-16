//
//  TodayProgressView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

import Foundation
import UIKit
import SnapKit

final class TodayProgressView: UIView {
    private let weekStackView = UIStackView()

    private enum Layout {
        static let circleSize: CGFloat = 30
        static let itemSpacing: CGFloat = 6
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupContent()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with state: TodayProgressState) {
        renderWeekDays(state.weekDays)
    }
}

//MARK: - Setup View
private extension TodayProgressView {
    func setupView() {
        backgroundColor = .clear
    }

    func setupContent() {
        weekStackView.axis = .horizontal
        weekStackView.distribution = .fillEqually
        weekStackView.alignment = .top
        weekStackView.spacing = Layout.itemSpacing

        addSubview(weekStackView)
    }
}

//MARK: - Setup Constraints
private extension TodayProgressView {
    func setupConstraints() {
        weekStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

//MARK: - Render week
private extension TodayProgressView {
    func renderWeekDays(_ days: [TodayProgressDayState]) {
        weekStackView.arrangedSubviews.forEach {
            weekStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        days.forEach { day in
            weekStackView.addArrangedSubview(makeDayView(day))
        }
    }

    func makeDayView(_ day: TodayProgressDayState) -> UIView {
        let containerView = UIView()

        let weekdayLabel = UILabel()
        weekdayLabel.text = day.weekdayTitle
        weekdayLabel.font = UIFont(name: "Montserrat-Medium", size: 11)
        weekdayLabel.textAlignment = .center
        weekdayLabel.textColor = day.isToday ? UIColor(hex: "#708AF4") : .secondaryLabel

        let circleView = TodayProgressCircleView()
        circleView.configure(with: day)

        containerView.addSubview(weekdayLabel)
        containerView.addSubview(circleView)

        weekdayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        circleView.snp.makeConstraints { make in
            make.top.equalTo(weekdayLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.circleSize)
            make.bottom.equalToSuperview()
        }

        return containerView
    }
}

//MARK: - Progress circle
private final class TodayProgressCircleView: UIView {

    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let dayLabel = UILabel()

    private var progress: Double = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupContent()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.width / 2
        updateLayers()
    }

    func configure(with day: TodayProgressDayState) {
        progress = day.progress
        dayLabel.text = day.dayNumberText

        dayLabel.textColor = makeTextColor(for: day)
        backgroundColor = day.isToday ? UIColor(hex: "#E9EEFF") : .clear

        trackLayer.strokeColor = day.isFuture
            ? UIColor.clear.cgColor
            : UIColor(hex: "#E8ECFA").cgColor

        progressLayer.strokeColor = day.isFuture
            ? UIColor.clear.cgColor
            : UIColor(hex: "#7B8FF2").cgColor

        setNeedsLayout()
    }

    private func makeTextColor(for day: TodayProgressDayState) -> UIColor {
        if day.isFuture {
            return .secondaryLabel
        }

        if day.isToday {
            return UIColor(hex: "#708AF4")
        }

        return UIColor(hex: "#7B8FF2")
    }
}

//MARK: - Circle setup
private extension TodayProgressCircleView {
    func setupView() {
        backgroundColor = .clear

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    func setupContent() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 2.5

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 2.5
        progressLayer.lineCap = .round

        dayLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        dayLabel.textAlignment = .center

        addSubview(dayLabel)

        dayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateLayers() {
        let lineWidth: CGFloat = 2.5
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        trackLayer.frame = bounds

        progressLayer.path = path.cgPath
        progressLayer.frame = bounds
        progressLayer.strokeEnd = CGFloat(progress)
    }
}
