//
//  HabitDetailsCalendarView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.06.2026.
//

import UIKit
import SnapKit

final class HabitDetailsCalendarView: UIView {
    private let headerStackView = UIStackView()
    private let previousMonthButton = UIButton()
    private let nextMonthButton = UIButton()
    private let monthLabel = UILabel()
    private let yearLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupHeader()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(month: String, year: String) {
        monthLabel.text = month
        yearLabel.text = year
    }
}

private extension HabitDetailsCalendarView {
    //MARK: - Setup views
    func setupView() {
        backgroundColor = .appGray
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.borderColor = UIColor.systemGray5.cgColor
    }

    func setupHeader() {
        previousMonthButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        monthLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        monthLabel.textColor = .label

        yearLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        yearLabel.textColor = .secondaryLabel
        yearLabel.textAlignment = .center

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = 16

        headerStackView.addArrangedSubview(previousMonthButton)
        headerStackView.addArrangedSubview(monthLabel)
        headerStackView.addArrangedSubview(nextMonthButton)

        addSubview(headerStackView)
        addSubview(yearLabel)
    }

    func setupConstraints() {
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        yearLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
}
