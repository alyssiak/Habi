//
//  HabitDetailsViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.06.2026.
//

import UIKit
import SnapKit
import Combine

final class HabitDetailsViewController: UIViewController {
    //MARK: - Properties
    private let descriptionContainerView = UIView()
    private let habitHeaderView = UIView()
    
    private let habitHeaderStackView = UIStackView()
    private let nameRowStackView = UIStackView()
    
    private let screenTitleLabel = UILabel()
    private let nameLabel = UILabel()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let currentStreakLabel = UILabel()
    private let descriptionTitleLabel = UILabel()
    private let descriptionTextLabel = UILabel()
    
    private let closeButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    
    private var calendarHeightConstraint: Constraint?
    private var cancellables = Set<AnyCancellable>()
    
    private let calendarView = HabitDetailsCalendarView()
    private let statsView = HabitDetailsStatsView()
    
    private let habit: HabitCardModel
    private var currentFormModel: HabitFormModel?
    private let viewModel: HabitDetailsViewModel
    private let makeHabitFormViewController: (AddHabitViewController.Mode) -> UIViewController
    
    //MARK: - Init
    init(
        habit: HabitCardModel,
        viewModel: HabitDetailsViewModel,
        makeHabitFormViewController: @escaping (AddHabitViewController.Mode) -> UIViewController
    ) {
        self.habit = habit
        self.viewModel = viewModel
        self.makeHabitFormViewController = makeHabitFormViewController
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
        setupConstraints()
        bindViewModel()
        bindCalendarView()
        viewModel.loadDetails()

    }
    //MARK: - Bind
    func bindCalendarView() {
        calendarView.onDaySelected = { [weak self] date in
            self?.viewModel.toggleDay(date)
        }
        
        calendarView.onPreviousMonthTap = { [weak self] in
            self?.viewModel.showPreviousMonth()
        }
        
        calendarView.onNextMonthTap = { [weak self] in
            self?.viewModel.showNextMonth()
        }
    }

    private func bindViewModel() {
        viewModel.$viewState
            .compactMap { $0 }
            .sink { [weak self] model in
                self?.calendarView.configure(
                    month: model.calendar.monthTitle,
                    year: model.calendar.yearTitle,
                    days: model.calendar.days
                )
                self?.statsView.configure(
                    completedDays: model.stats.completedDays,
                    bestStreak: model.stats.bestStreak
                )
                self?.currentFormModel = model.form
                self?.configureHeader(model.header)
                self?.configureCurrentStreak(model.stats.currentStreak)
                self?.configureDescription(model.description)
                self?.updateCalendarHeight(for: model.calendar.days)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Setup views
    func setupView() {
        view.backgroundColor = .systemBackground
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

        emojiLabel.font = .systemFont(ofSize: 22)

        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        titleLabel.numberOfLines = 0

        currentStreakLabel.font = UIFont(name:"Montserrat-SemiBold", size: 12)
        currentStreakLabel.textAlignment = .center
        currentStreakLabel.layer.cornerRadius = 10
        currentStreakLabel.clipsToBounds = true
        
        nameRowStackView.axis = .horizontal
        nameRowStackView.alignment = .center
        nameRowStackView.spacing = 8
        nameRowStackView.distribution = .equalSpacing
        
        habitHeaderStackView.axis = .horizontal
        habitHeaderStackView.spacing = 8
        habitHeaderStackView.alignment = .center

        view.addSubview(nameRowStackView)
        view.addSubview(habitHeaderView)
        
        nameRowStackView.addArrangedSubview(nameLabel)
        nameRowStackView.addArrangedSubview(currentStreakLabel)
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

        descriptionTextLabel.font = UIFont(name: "Montserrat-Regular", size: 14)
        descriptionTextLabel.textColor = .secondaryLabel
        descriptionTextLabel.numberOfLines = 0

        view.addSubview(descriptionTitleLabel)
        view.addSubview(descriptionContainerView)
        descriptionContainerView.addSubview(descriptionTextLabel)
    }

    func setupConstraints() {

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
        
        currentStreakLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.greaterThanOrEqualTo(88)
        }
        
        nameRowStackView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        habitHeaderView.snp.makeConstraints { make in
            make.top.equalTo(nameRowStackView.snp.bottom).offset(8)
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
            calendarHeightConstraint = make.height.equalTo(280).constraint
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
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }

    //MARK: - Actions

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapEdit() {
        guard let currentFormModel else {
            return
        }
        let editViewController = makeHabitFormViewController(.edit(currentFormModel))
        present(editViewController, animated: true)
    }

    //MARK: - Helpers
    private func makeColor(from hex: String?) -> UIColor {
        guard let hex else {
            return .systemOrange
        }

        return UIColor(hex: hex)
    }
    
    private func configureCurrentStreak(_ streak: Int) {
        currentStreakLabel.text = "\(streak) day streak"
        
        if streak >= 5 {
            currentStreakLabel.textColor = .white
            currentStreakLabel.backgroundColor = .appOrange
        } else {
            currentStreakLabel.textColor = .secondaryLabel
            currentStreakLabel.backgroundColor = .lastDaysGray
        }
    }
    
    private func configureHeader(_ model: HabitDetailsHeaderModel) {
        titleLabel.text = model.title
        emojiLabel.text = model.emoji
        habitHeaderView.backgroundColor = makeColor(from: model.colorHex)
    }
    private func updateCalendarHeight(for days: [HabitDetailsCalendarDayCellModel]) {
        let rows = ceil(Double(days.count) / 7.0)
        
        let cellHeight: CGFloat = 28
        let lineSpacing: CGFloat = 8
        let headerHeight: CGFloat = 24
        let yearHeight: CGFloat = 17
        let topInset: CGFloat = 16
        let headerToYearSpacing: CGFloat = 2
        let yearToGridSpacing: CGFloat = 16
        let bottomInset: CGFloat = 16
        
        let gridHeight = CGFloat(rows) * cellHeight + CGFloat(rows - 1) * lineSpacing
        
        let totalHeight =
            topInset +
            headerHeight +
            headerToYearSpacing +
            yearHeight +
            yearToGridSpacing +
            gridHeight +
            bottomInset
        
        calendarHeightConstraint?.update(offset: totalHeight)
    }
    
    private func configureDescription(_ model: HabitDetailsDescriptionModel) {
        let isPlaceholder = model.text == "No description yet"
        
        descriptionTextLabel.text = model.text
        descriptionTextLabel.font = UIFont(
            name: isPlaceholder ? "Montserrat-Medium" : "Montserrat-Regular",
            size: 14
        )
        descriptionTextLabel.textColor = isPlaceholder ? .tertiaryLabel : .secondaryLabel
    }
}
