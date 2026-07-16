//
//  ViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit
import SnapKit
import CoreData
import Combine

final class HabitTrackerViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    // MARK: - Properties

    private let avatarImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let quoteTextLabel = UILabel()
    private let quoteAuthorLabel = UILabel()
    private let addHabitButton = UIButton()
    private let archiveButton = UIButton(type: .system)
    private let headerStackView = UIStackView()
    private let textStackView = UIStackView()
    private let habitsTableView = UITableView()
    private let emptyStateStackView = UIStackView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    private let undoBannerView = UIView()
    private let undoBannerStackView = UIStackView()
    private let undoMessageLabel = UILabel()
    private let undoButton = UIButton(type: .system)

    private var habitModels: [HabitCardModel] = []
    private let viewModel: HabitTrackerViewModel
    private var archivedHabitStack: [ArchivedHabitUndoItem] = []
    private var hideUndoBannerWorkItem: DispatchWorkItem?
    private let makeDetailsViewController: (HabitCardModel) -> UIViewController
    private let makeHabitFormViewController: (AddHabitViewController.Mode) -> UIViewController
    private let makeArchiveViewController: () -> UIViewController
    // MARK: - Layout

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let headerTopOffset: CGFloat = 24
        static let tableTopOffset: CGFloat = 26
        static let avatarSize: CGFloat = 56
        static let addButtonSize: CGFloat = 56
        static let addButtonBottomOffset: CGFloat = 20
        static let tableBottomInset: CGFloat = 88
        static let rowHeight: CGFloat = 88
        static let rowSpacing: CGFloat = 12
        static let undoBannerHeight: CGFloat = 52
        static let undoBannerBottomOffset: CGFloat = 12
        static let undoBannerHideDelay: TimeInterval = 10
        static let archiveButtonSize: CGFloat = 40
    }

    private struct ArchivedHabitUndoItem {
        let id: NSManagedObjectID
        let title: String
    }

    // MARK: - Init

    init(
        viewModel: HabitTrackerViewModel,
        makeDetailsViewController: @escaping (HabitCardModel) -> UIViewController,
        makeHabitFormViewController: @escaping (AddHabitViewController.Mode) -> UIViewController,
        makeArchiveViewController: @escaping () -> UIViewController
    ) {
        self.viewModel = viewModel
        self.makeDetailsViewController = makeDetailsViewController
        self.makeHabitFormViewController = makeHabitFormViewController
        self.makeArchiveViewController = makeArchiveViewController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    

        setupView()
        setupHeader()
        setupHabitsTableView()
        setupEmptyState()
        setupUndoBanner()
        setupConstraints()
        bindViewModel()
        viewModel.loadHabits()
        viewModel.loadProfile()
        Task {
            await viewModel.loadQuote()
        }
    }
}

// MARK: - Setup

private extension HabitTrackerViewController {

    func setupView() {
        view.backgroundColor = .systemBackground
    }

    func setupHeader() {
        avatarImageView.image = UIImage(systemName: "person.circle")
        avatarImageView.tintColor = .systemGray
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
        avatarImageView.clipsToBounds = true

        greetingLabel.text = "Hello!"
        greetingLabel.font = UIFont(name: "Montserrat-SemiBold", size: 24)

        quoteTextLabel.numberOfLines = 0
        quoteTextLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        quoteTextLabel.textColor = .label

        quoteAuthorLabel.font = UIFont(name: "Montserrat-SemiBold", size: 13)
        quoteAuthorLabel.textColor = .secondaryLabel

        addHabitButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addHabitButton.backgroundColor = .systemOrange
        addHabitButton.tintColor = .white
        addHabitButton.layer.cornerRadius = 8
        addHabitButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        
        archiveButton.setImage(UIImage(systemName: "archivebox"), for: .normal)
        archiveButton.tintColor = .label
        archiveButton.backgroundColor = .secondarySystemBackground
        archiveButton.layer.cornerRadius = 8
        archiveButton.addTarget(self, action: #selector(didTapArchiveButton), for: .touchUpInside)
        
        textStackView.axis = .vertical
        textStackView.spacing = 6
        textStackView.addArrangedSubview(greetingLabel)
        textStackView.addArrangedSubview(quoteTextLabel)
        textStackView.addArrangedSubview(quoteAuthorLabel)

        headerStackView.axis = .horizontal
        headerStackView.spacing = 16
        headerStackView.alignment = .center
        
        textStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        archiveButton.setContentHuggingPriority(.required, for: .horizontal)
        archiveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        headerStackView.addArrangedSubview(avatarImageView)
        headerStackView.addArrangedSubview(textStackView)
        headerStackView.addArrangedSubview(archiveButton)
        view.addSubview(headerStackView)
        view.addSubview(addHabitButton)
    }

    func setupHabitsTableView() {
        habitsTableView.dataSource = self
        habitsTableView.delegate = self

        habitsTableView.register(
            HabitCardCell.self,
            forCellReuseIdentifier: HabitCardCell.reuseIdentifier
        )

        habitsTableView.separatorStyle = .none
        habitsTableView.backgroundColor = .clear
        habitsTableView.showsVerticalScrollIndicator = false

        habitsTableView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Layout.tableBottomInset,
            right: 0
        )

        view.addSubview(habitsTableView)
        view.bringSubviewToFront(addHabitButton)
    }

    func setupEmptyState() {
        emptyTitleLabel.text = "No habits yet"
        emptyTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        emptyTitleLabel.textColor = .label
        emptyTitleLabel.textAlignment = .center

        emptySubtitleLabel.text = "Tap + to add your first habit"
        emptySubtitleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        emptySubtitleLabel.textColor = .secondaryLabel
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 0

        emptyStateStackView.axis = .vertical
        emptyStateStackView.spacing = 8
        emptyStateStackView.alignment = .center
        emptyStateStackView.isHidden = true
        emptyStateStackView.addArrangedSubview(emptyTitleLabel)
        emptyStateStackView.addArrangedSubview(emptySubtitleLabel)

        view.addSubview(emptyStateStackView)
        view.bringSubviewToFront(addHabitButton)
    }

    func setupUndoBanner() {
        undoBannerView.backgroundColor = .label
        undoBannerView.layer.cornerRadius = 8
        undoBannerView.alpha = 0
        undoBannerView.isHidden = true

        undoMessageLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        undoMessageLabel.textColor = .systemBackground
        undoMessageLabel.numberOfLines = 1
        undoMessageLabel.lineBreakMode = .byTruncatingTail

        undoButton.setTitle("Undo", for: .normal)
        undoButton.setTitleColor(.systemOrange, for: .normal)
        undoButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        undoButton.addTarget(self, action: #selector(didTapUndoDelete), for: .touchUpInside)

        undoBannerStackView.axis = .horizontal
        undoBannerStackView.alignment = .center
        undoBannerStackView.spacing = 12
        undoBannerStackView.addArrangedSubview(undoMessageLabel)
        undoBannerStackView.addArrangedSubview(undoButton)

        undoButton.setContentHuggingPriority(.required, for: .horizontal)
        undoButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        undoMessageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        undoBannerView.addSubview(undoBannerStackView)
        view.addSubview(undoBannerView)
        view.bringSubviewToFront(undoBannerView)
        view.bringSubviewToFront(addHabitButton)
    }

    func setupConstraints() {

        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(Layout.avatarSize)
        }

        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.headerTopOffset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        
        archiveButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        
        habitsTableView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(Layout.tableTopOffset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview()
        }

        emptyStateStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.centerY.equalToSuperview().offset(40)
        }

        addHabitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Layout.addButtonBottomOffset)
            make.size.equalTo(Layout.addButtonSize)
        }
        
        
        undoBannerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(addHabitButton.snp.top).offset(-Layout.undoBannerBottomOffset)
            make.height.equalTo(Layout.undoBannerHeight)
        }

        undoBannerStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Binding

private extension HabitTrackerViewController {

    func bindViewModel() {
        viewModel.onHabitsChanged = { [weak self] models in
            self?.renderHabits(models)
        }
        
        viewModel.$quote
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quote in
                self?.renderQuote(quote)
            }
            // & здесь значит, что мы передаем cancellables как изменяемое хранилище.
            .store(in: &cancellables)
        
        viewModel.onProfileChanged = { [weak self] state in
            self?.renderProfile(state)
        }
    }

    func renderHabits(_ models: [HabitCardModel]) {
        habitModels = models
        habitsTableView.reloadData()
        updateEmptyState()
    }
    
    func renderQuote(_ quote: Quote?) {
        guard let quote else {
            quoteTextLabel.text = "Track your habits to stay motivated."
            quoteAuthorLabel.text = nil
            return
        }
        
        quoteTextLabel.text = "\(quote.text)"
        quoteAuthorLabel.text = "— \(quote.author)"
    }
    
    func renderProfile(_ state: HabitHeaderProfileState) {
        greetingLabel.text = "Hello, \(state.name)!"

        if let avatarData = state.avatarData,
           let image = UIImage(data: avatarData) {
            avatarImageView.image = image
            avatarImageView.tintColor = nil
            avatarImageView.contentMode = .scaleAspectFill
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
            avatarImageView.tintColor = .systemGray
            avatarImageView.contentMode = .scaleAspectFit
        }
    }
    
    func updateEmptyState() {
        let isEmpty = habitModels.isEmpty

        habitsTableView.isHidden = isEmpty
        emptyStateStackView.isHidden = !isEmpty
    }
}

// MARK: - Actions

private extension HabitTrackerViewController {

    @objc func didTapAddButton() {
        let addHabitViewController = makeHabitFormViewController(.add)
        present(addHabitViewController, animated: true)
    }

    @objc func didTapArchiveButton() {
        let archiveViewController = makeArchiveViewController()
        present(archiveViewController, animated: true)
    }
    
    func openEditHabit(model: HabitCardModel) {
        let addHabitViewController = makeHabitFormViewController(.edit(HabitFormModel(cardModel: model)))

        present(addHabitViewController, animated: true)
    }

    func confirmDeleteHabit(
        model: HabitCardModel,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let alertController = UIAlertController(
            title: "Delete habit?",
            message: "This will remove \"\(model.title)\" from your list. You can undo it right after.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })

        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else {
                completion(false)
                return
            }

            viewModel.deleteHabit(for: model.id)
            showUndoBanner(for: model)
            completion(true)
        })

        present(alertController, animated: true)
    }

    func showUndoBanner(for model: HabitCardModel) {
        archivedHabitStack.append(
            ArchivedHabitUndoItem(
                id: model.id,
                title: model.title
            )
        )

        updateUndoBannerText()
        showUndoBanner()
        scheduleUndoBannerHide()
    }

    func showUndoBanner() {
        undoBannerView.isHidden = false

        UIView.animate(withDuration: 0.2) {
            self.undoBannerView.alpha = 1
        }
    }

    func hideUndoBanner(clearStack: Bool) {
        if clearStack {
            archivedHabitStack.removeAll()
        }

        hideUndoBannerWorkItem?.cancel()

        UIView.animate(withDuration: 0.2) {
            self.undoBannerView.alpha = 0
        } completion: { [weak self] _ in
            self?.undoBannerView.isHidden = true
        }
    }

    func updateUndoBannerText() {
        if archivedHabitStack.count > 1 {
            undoMessageLabel.text = "\(archivedHabitStack.count) habits deleted"
        } else if let item = archivedHabitStack.last {
            undoMessageLabel.text = "\"\(item.title)\" deleted"
        }
    }

    func scheduleUndoBannerHide() {
        hideUndoBannerWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.hideUndoBanner(clearStack: true)
        }

        hideUndoBannerWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Layout.undoBannerHideDelay,
            execute: workItem
        )
    }

    @objc func didTapUndoDelete() {
        guard let item = archivedHabitStack.popLast() else {
            hideUndoBanner(clearStack: false)
            return
        }

        viewModel.restoreHabit(for: item.id)

        if archivedHabitStack.isEmpty {
            hideUndoBanner(clearStack: false)
        } else {
            updateUndoBannerText()
            scheduleUndoBannerHide()
        }
    }

}

// MARK: - UITableViewDataSource

extension HabitTrackerViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return habitModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HabitCardCell.reuseIdentifier,
            for: indexPath
        ) as? HabitCardCell else {
            return UITableViewCell()
        }

        let model = habitModels[indexPath.section]
        cell.configure(with: model)

        cell.onDoneTapped = { [weak self] in
            self?.viewModel.toggleToday(for: model.id)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HabitTrackerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Layout.rowSpacing
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let model = habitModels[indexPath.section]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            confirmDeleteHabit(model: model, completion: completion)
        }
        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let model = habitModels[indexPath.section]

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            openEditHabit(model: model)
            completion(true)
        }

        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "square.and.pencil")

        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let model = habitModels[indexPath.section]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: "Edit",
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                self?.openEditHabit(model: model)
            }

            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.confirmDeleteHabit(model: model)
            }

            return UIMenu(children: [editAction, deleteAction])
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = habitModels[indexPath.section]
        let detailsViewController = makeDetailsViewController(model)
        
        present(detailsViewController, animated: true)
    }
}
