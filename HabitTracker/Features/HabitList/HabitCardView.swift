//
//  HabitCardView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 04.05.2026.
//

import UIKit
import SnapKit

final class HabitCardView: UIView {
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    private let emojiLabel = UILabel()
    private let doneButton = UIButton()
    private let calendarView = HabitCalendarView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var cardColor: UIColor = .systemOrange
    private var isDoneToday = false
    
    private let rightStackView = UIStackView()
    private let contentStackView = UIStackView()
    private let centerStackView = UIStackView()
    private let titleRowStackView = UIStackView()
    private let progressContainer = UIView()
    
    var onDoneTapped: (() -> Void)?
    
    private enum Layout {
        static let contentInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        static let doneButtonSize: CGFloat = 16
        static let emojiSize: CGFloat = 22
        static let progressHeight: CGFloat = 4
        static let progressWidth: CGFloat = 120
        static let calendarWidth: CGFloat = 84
        static let calendarHeight: CGFloat = 52
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
        setupContent()
        setupConstraints()
    }
    
    //MARK: - Configuration
    func configure(
        title: String,
        isDoneToday: Bool,
        emoji: String?,
        completedDays: Int,
        totalDays: Int,
        color: String?,
        days: [HabitCalendarDay],
        streak: Int
    ) {
        titleLabel.text = title
        progressView.progress = Float(completedDays) / Float(totalDays)
        calendarView.configure(days: days)
        self.isDoneToday = isDoneToday
        emojiLabel.text = emoji
        cardColor = makeColor(from: color)
        progressView.progressTintColor = cardColor
        doneButton.layer.borderColor = cardColor.withAlphaComponent(0.7).cgColor
        updateDoneButton(isDone: isDoneToday)
        updateCardState(isDone: isDoneToday)
        updateStreak(streak: streak)
    }
    
    //MARK: - Setup UI
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
    }
    
    private func setupContent() {
        emojiLabel.font = .systemFont(ofSize: 18)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .clear
        emojiLabel.layer.cornerRadius = 0
        emojiLabel.clipsToBounds = false
        
        streakLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        streakLabel.textColor = .systemRed
        streakLabel.numberOfLines = 1
        
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        
        progressView.progressTintColor = cardColor
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        
        doneButton.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.5).cgColor
        doneButton.layer.cornerRadius = 8
        doneButton.layer.borderWidth = 2
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(handleDoneButtonTap), for: .touchUpInside)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)
        emojiLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
       
        centerStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        centerStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        calendarView.clipsToBounds = true
        calendarView.setContentCompressionResistancePriority(.required, for: .horizontal)
        calendarView.setContentHuggingPriority(.required, for: .horizontal)
        
        rightStackView.setContentHuggingPriority(.required, for: .horizontal)
        rightStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleRowStackView.spacing = 4
        titleRowStackView.axis = .horizontal
        titleRowStackView.alignment = .center
        titleRowStackView.distribution = .fill
        titleRowStackView.addArrangedSubview(emojiLabel)
        titleRowStackView.addArrangedSubview(titleLabel)
        titleRowStackView.addArrangedSubview(streakLabel)

        
        progressContainer.addSubview(progressView)
        
        centerStackView.spacing = 10
        centerStackView.axis = .vertical
        centerStackView.alignment = .leading
        centerStackView.distribution = .fill
        centerStackView.addArrangedSubview(titleRowStackView)
        centerStackView.addArrangedSubview(progressContainer)
        
        rightStackView.spacing = 0
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        rightStackView.distribution = .fill
        rightStackView.addArrangedSubview(calendarView)
        
        contentStackView.spacing = 10
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.addArrangedSubview(doneButton)
        contentStackView.addArrangedSubview(centerStackView)
        contentStackView.addArrangedSubview(rightStackView)
        
        addSubview(contentStackView)
    }
    private func setupConstraints() {
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Layout.contentInsets)
        }
        
        doneButton.snp.makeConstraints { make in
            make.size.equalTo(Layout.doneButtonSize)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.size.equalTo(Layout.emojiSize)
        }
        
        progressContainer.snp.makeConstraints { make in
            make.height.equalTo(Layout.progressHeight)
            make.width.equalTo(Layout.progressWidth)
        }
        
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rightStackView.snp.makeConstraints { make in
            make.width.equalTo(Layout.calendarWidth)
        }
        
        calendarView.snp.makeConstraints { make in
            make.height.equalTo(Layout.calendarHeight)
            make.width.equalTo(Layout.calendarWidth)
        }
        
    }
    
    //MARK: - Actions
    
    @objc private func handleDoneButtonTap() {
        isDoneToday.toggle()
        updateCardState(isDone: isDoneToday)
        updateDoneButton(isDone: isDoneToday)
        onDoneTapped?()
    }
    
    //MARK: - Private Helpers
    private func updateDoneButton(isDone: Bool) {
        if isDone {
            doneButton.tintColor = .white
            doneButton.backgroundColor = cardColor
        } else {
            doneButton.tintColor = .systemGray4
            doneButton.backgroundColor = .clear
        }
    }
    
    private func updateCardState(isDone: Bool) {
        if isDone {
            layer.borderWidth = 1.5
            layer.borderColor = cardColor.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
        
    }
    
    private func makeColor(from hex: String?) -> UIColor {
        guard let hex else {
            return .systemOrange
        }
        
        return UIColor(hex: hex)
    }
    
    private func updateStreak(streak: Int) {
        if streak >= 5 {
            streakLabel.text = "🔥 \(streak)"
            streakLabel.textColor = .systemOrange
        } else {
            streakLabel.text = " "
            streakLabel.textColor = .clear
        }
    }
}
