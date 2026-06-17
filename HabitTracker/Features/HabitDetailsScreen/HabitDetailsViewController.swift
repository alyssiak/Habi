//
//  HabitDetailsViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import UIKit
import SnapKit

final class HabitDetailsViewController: UIViewController {
    private let screenTitleLabel = UILabel()
    private let nameLabel = UILabel()
    private let habitHeaderView = UIView()
    private let habitHeaderStackView = UIStackView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)

    private let descriptionTitleLabel = UILabel()
    private let descriptionTextLabel = UILabel()
    private let descriptionContainerView = UIView()

    private let habit: HabitCardModel
    private let calendarView = HabitDetailsCalendarView()
    private let statsView = HabitDetailsStatsView()

    init(habit: HabitCardModel) {
        self.habit = habit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupHeader()
        setupNavigation()
        setupDescription()
        setupConstrainsts()
    }

    //MARK: - Setup views
    func setupView() {
        view.backgroundColor = .systemBackground
        calendarView.configure(month: "March", year: "2026")
        statsView.configure(completedDays: 20, bestStreak: 5)
        view.addSubview(statsView)
        view.addSubview(calendarView)

    }

    func setupNavigation() {
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 13)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        screenTitleLabel.text = "Habit details"
        screenTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        screenTitleLabel.textColor = .label
        screenTitleLabel.textAlignment = .center

        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.label, for: .normal)
        editButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 13)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(screenTitleLabel)
        view.addSubview(editButton)
    }

    func setupHeader() {
        nameLabel.text = "Name"
        nameLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        nameLabel.textColor = .secondaryLabel

        habitHeaderView.backgroundColor = makeColor(from: habit.colorHex)
        habitHeaderView.layer.cornerRadius = 8

        emojiLabel.text = habit.emoji
        emojiLabel.font = .systemFont(ofSize: 22)

        titleLabel.text = habit.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        titleLabel.numberOfLines = 0

        habitHeaderStackView.axis = .horizontal
        habitHeaderStackView.spacing = 8
        habitHeaderStackView.alignment = .center

        view.addSubview(nameLabel)
        view.addSubview(habitHeaderView)
        habitHeaderView.addSubview(habitHeaderStackView)
        habitHeaderStackView.addArrangedSubview(emojiLabel)
        habitHeaderStackView.addArrangedSubview(titleLabel)

    }

    func setupDescription() {
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        descriptionTitleLabel.textColor = .secondaryLabel

        descriptionContainerView.backgroundColor = .appGray
        descriptionContainerView.layer.cornerRadius = 8

        descriptionTextLabel.text = "No description yet"
        descriptionTextLabel.font = UIFont(name: "Montserrat-Medium", size: 18)
        descriptionTextLabel.textColor = .secondaryLabel
        descriptionTextLabel.numberOfLines = 0

        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionContainerView)
        descriptionContainerView.addSubview(descriptionTextLabel)
    }

    func setupConstrainsts() {

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        screenTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton.snp.centerY)
            make.centerX.equalToSuperview()
        }

        editButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.trailing.equalToSuperview().inset(20)

        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        habitHeaderView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }

        habitHeaderStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        calendarView.snp.makeConstraints { make in
            make.top.equalTo(habitHeaderView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(280)
        }

        statsView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(100)
        }

        descriptionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(statsView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        descriptionContainerView.snp.makeConstraints { make in
            make.top.equalTo(descriptionTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(72)
        }

        descriptionTextLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
        }
    }

    //MARK: - Actions

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapEdit() {
        //TODO: Open edit habit screen
    }

    //MARK: - Helpers
    private func makeColor(from hex: String?) -> UIColor {
        guard let hex else {
            return .systemOrange
        }

        return UIColor(hex: hex)
    }
}
