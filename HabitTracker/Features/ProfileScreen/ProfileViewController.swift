//
//  ProfileViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    private let profileView = ProfileView()
    private let viewModel: ProfileViewModel
    private let makeEditProfileViewController: () -> UIViewController
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Initialization
    init(
        viewModel: ProfileViewModel,
        makeEditProfileViewController: @escaping () -> UIViewController
    ) {
        self.viewModel = viewModel
        self.makeEditProfileViewController = makeEditProfileViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupActions()
        viewModel.loadProfile()
        Task {
            await viewModel.loadQuote()
        }
    }
}

private extension ProfileViewController {
    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.profileView.configure(with: state)
                self?.applyTheme(state.theme)
            }
            .store(in: &cancellables)
    }

    func setupActions() {
        profileView.onEditProfileTapped = { [weak self] in
            self?.openEditProfile()
        }

        profileView.onSettingsItemTapped = { [weak self] action in
            self?.handleSettingsAction(action)
        }
    }

    func openEditProfile() {
        let editProfileViewController = makeEditProfileViewController()
        let navigationController = UINavigationController(rootViewController: editProfileViewController)

        present(navigationController, animated: true)
    }

    func handleSettingsAction(_ action: ProfileSettingsAction) {
        switch action {
        case .theme:
            showThemePicker()
        case .language, .reminders, .about:
            break
        }
    }

    func showThemePicker() {
        let selectedTheme = viewModel.state.theme
        let options = AppTheme.allCases.map { theme in
            SettingsOptionItem(
                id: theme.rawValue,
                title: theme.title,
                isSelected: theme == selectedTheme
            )
        }

        let viewController = SettingsOptionPickerViewController(
            title: "Theme",
            options: options
        ) { [weak self] option in
            guard let theme = AppTheme(rawValue: option.id) else {
                return
            }

            self?.viewModel.updateTheme(theme)
            self?.applyTheme(theme)
        }

        present(viewController, animated: true)
    }

    func applyTheme(_ theme: AppTheme) {
        view.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
    }
}
