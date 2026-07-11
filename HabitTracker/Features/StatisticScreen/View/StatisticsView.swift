//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import SnapKit

final class StatisticsView: UIView {
    //MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let periodSegmentedControl = UISegmentedControl(items: ["Weekly", "Monthly"])
    
    private let overallCardView = UIView()
    private let overallTitleLabel = UILabel()
    private let overallSubtitleLabel = UILabel()
    private let progressRingView = StatisticsProgressRingView()
    private let sectionsStackView = UIStackView()
    private let habitsStackView = UIStackView()
    private let monthOverviewView = MonthProgressOverviewView()
    private let topHabitsChartView = TopHabitsChartView()
    
    var onPeriodSelected: ((StatisticsPeriod) -> Void)?
    var onPreviousMonthTapped: (() -> Void)?
    var onNextMonthTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupSegmentedControl()
        setupOverallCard()
        setupSectionsStackView()
        setupHabitsStackView()
        setupMonthOverviewView()
        setupTopHabitsChartView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func render(_ state: StatisticsViewState) {
        overallTitleLabel.text = state.title
        overallSubtitleLabel.text = state.subtitle
        progressRingView.render(progress: state.overallProgress, percentText: state.overallPercentText)
        updateSelectedPeriod(state.selectedPeriod)
        renderHabitCards(state.habitProgressItems)
        renderMonthOverview(
            days: state.monthDays,
            monthTitle: state.selectedMonthText,
            canShowNextMonth: state.canShowNextMonth
        )
        renderTopHabits(state.topHabitProgressItems)
        
    }
    
    //MARK: - Actions
    @objc private func didChangePeriod() {
        switch periodSegmentedControl.selectedSegmentIndex {
            case 0:
                onPeriodSelected?(.weekly)
            case 1:
                onPeriodSelected?(.monthly)
            default:
                break
        }
    }
}

//MARK: - Setup methods
private extension StatisticsView {
    func setupView() {
        backgroundColor = .systemBackground

        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    func setupSegmentedControl() {
        periodSegmentedControl.selectedSegmentIndex = 0
        contentView.addSubview(periodSegmentedControl)
        periodSegmentedControl.addTarget(self, action: #selector(didChangePeriod), for: .valueChanged)
    }
    
    func updateSelectedPeriod(_ period: StatisticsPeriod) {
       switch period {
       case .weekly:
           periodSegmentedControl.selectedSegmentIndex = 0
       case .monthly:
           periodSegmentedControl.selectedSegmentIndex = 1
       }
   }

    func setupOverallCard() {
        overallCardView.backgroundColor = .clear
        overallCardView.layer.cornerRadius = 0

        overallTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        overallTitleLabel.textColor = .label

        overallSubtitleLabel.font = UIFont(name: "Montserrat-Medium", size: 15)
        overallSubtitleLabel.textColor = .appOrange

        contentView.addSubview(overallCardView)
        overallCardView.addSubview(overallTitleLabel)
        overallCardView.addSubview(overallSubtitleLabel)
        overallCardView.addSubview(progressRingView)
    }

    func setupHabitsStackView() {
        habitsStackView.axis = .vertical
        habitsStackView.spacing = 16

        sectionsStackView.addArrangedSubview(habitsStackView)
    }

    func setupMonthOverviewView() {
        monthOverviewView.isHidden = true
        monthOverviewView.onPreviousMonthTapped = { [weak self] in
            self?.onPreviousMonthTapped?()
        }
        monthOverviewView.onNextMonthTapped = { [weak self] in
            self?.onNextMonthTapped?()
        }
        sectionsStackView.addArrangedSubview(monthOverviewView)
    }

    func setupTopHabitsChartView() {
        topHabitsChartView.isHidden = true
        sectionsStackView.addArrangedSubview(topHabitsChartView)
    }

    func setupSectionsStackView() {
        sectionsStackView.axis = .vertical
        sectionsStackView.spacing = 16
        contentView.addSubview(sectionsStackView)
    }
    
}

//MARK: - Constraints Methods
private extension StatisticsView {
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        periodSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        overallCardView.snp.makeConstraints { make in
            make.top.equalTo(periodSegmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(96)
        }

        overallTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualTo(progressRingView.snp.leading).offset(-12)
        }

        overallSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(overallTitleLabel.snp.bottom).offset(6)
            make.leading.equalTo(overallTitleLabel)
            make.bottom.equalToSuperview().inset(20)
        }

        progressRingView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            
            make.width.height.equalTo(86)
        }

        sectionsStackView.snp.makeConstraints { make in
            make.top.equalTo(overallCardView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

//MARK: - Card render
private extension StatisticsView {
    func renderHabitCards(_ items: [HabitProgressItem]) {
        habitsStackView.isHidden = items.isEmpty

        habitsStackView.arrangedSubviews.forEach { view in
            habitsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        items.forEach { item in
            let cardView = HabitProgressCardView()
            cardView.render(item)
            habitsStackView.addArrangedSubview(cardView)
        }
    }

    func renderMonthOverview(
        days: [MonthProgressDay],
        monthTitle: String?,
        canShowNextMonth: Bool
    ) {
        monthOverviewView.isHidden = days.isEmpty
        monthOverviewView.render(
            monthTitle: monthTitle,
            days: days,
            canShowNextMonth: canShowNextMonth
        )
    }

    func renderTopHabits(_ items: [TopHabitProgressItem]) {
        topHabitsChartView.render(items: items)
    }
}
