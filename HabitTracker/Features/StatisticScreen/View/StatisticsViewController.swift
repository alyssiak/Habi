//
//  StatisticsViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    //MARK: - Propetries
    private let viewModel: StatisticsViewModel
    private let profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let statisticsView = StatisticsView()
    
    //MARK: - Init
    init(
        viewModel: StatisticsViewModel,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.viewModel = viewModel
        self.profileRepository = profileRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupViewController()
        setupActions()
        bindViewModel()
        renderLanguage(profileRepository.fetchProfile().language)
        viewModel.loadStatistics()
    }
    
    override func loadView() {
        view = statisticsView
    }
    
    //MARK: - Private Methods
    private func setupActions() {
        statisticsView.onPeriodSelected = { [weak self] period in
            self?.viewModel.selectPeriod(period)
        }

        statisticsView.onPreviousMonthTapped = { [weak self] in
            self?.viewModel.showPreviousMonth()
        }

        statisticsView.onNextMonthTapped = { [weak self] in
            self?.viewModel.showNextMonth()
        }
    }
    
    private func setupViewController() {
        view.backgroundColor = .appBackground
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.statisticsView.render(state)
            }
            .store(in: &cancellables)

        profileRepository.changesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                renderLanguage(profileRepository.fetchProfile().language)
            }
            .store(in: &cancellables)
    }

    private func renderLanguage(_ language: AppLanguage) {
        title = AppStrings.statisticsTab(language)
        statisticsView.renderLanguage(language)
    }
}
