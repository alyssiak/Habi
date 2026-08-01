//
//  SettingsOptionPickerViewController.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

import UIKit
import SnapKit

struct SettingsOptionItem {
    let id: String
    let title: String
    let isSelected: Bool
}

final class SettingsOptionPickerViewController: UIViewController {
    private let pickerTitle: String
    private let options: [SettingsOptionItem]
    private let onSelect: (SettingsOptionItem) -> Void

    private let grabberView = UIView()
    private let titleLabel = UILabel()
    private let optionsStackView = UIStackView()

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let topInset: CGFloat = 12
        static let rowHeight: CGFloat = 56
        static let rowCornerRadius: CGFloat = 16
        static let grabberWidth: CGFloat = 36
        static let grabberHeight: CGFloat = 5
    }

    init(
        title: String,
        options: [SettingsOptionItem],
        onSelect: @escaping (SettingsOptionItem) -> Void
    ) {
        self.pickerTitle = title
        self.options = options
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSheet()
        setupView()
        setupContent()
        setupConstraints()
        renderOptions()
    }
}

//MARK: - Setup
private extension SettingsOptionPickerViewController {
    func setupSheet() {
        if let sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = false
            sheetPresentationController.preferredCornerRadius = 24
        }
    }

    func setupView() {
        view.backgroundColor = .appBackground
    }

    func setupContent() {
        grabberView.backgroundColor = .systemGray4
        grabberView.layer.cornerRadius = Layout.grabberHeight / 2

        titleLabel.text = pickerTitle
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        titleLabel.textColor = .label

        optionsStackView.axis = .vertical
        optionsStackView.spacing = 10

        view.addSubview(grabberView)
        view.addSubview(titleLabel)
        view.addSubview(optionsStackView)
    }

    func setupConstraints() {
        grabberView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.topInset)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.grabberWidth)
            make.height.equalTo(Layout.grabberHeight)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}

//MARK: - Render
private extension SettingsOptionPickerViewController {
    func renderOptions() {
        optionsStackView.arrangedSubviews.forEach {
            optionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        options.forEach { option in
            optionsStackView.addArrangedSubview(makeOptionRow(option))
        }
    }

    func makeOptionRow(_ option: SettingsOptionItem) -> UIControl {
        let rowView = SettingsOptionRowControl(option: option)
        rowView.backgroundColor = option.isSelected
            ? UIColor.appOrange.withAlphaComponent(0.12)
            : .appSecondaryBackground
        rowView.layer.cornerRadius = Layout.rowCornerRadius
        rowView.addTarget(self, action: #selector(didTapOption(_:)), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = option.title
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 16)
        titleLabel.textColor = .label

        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .appOrange
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = !option.isSelected

        rowView.addSubview(titleLabel)
        rowView.addSubview(checkmarkImageView)

        rowView.snp.makeConstraints { make in
            make.height.equalTo(Layout.rowHeight)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(checkmarkImageView.snp.leading).offset(-12)
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        return rowView
    }
}

//MARK: - Actions
private extension SettingsOptionPickerViewController {
    @objc func didTapOption(_ sender: UIControl) {
        guard let row = sender as? SettingsOptionRowControl else {
            return
        }

        onSelect(row.option)
        dismiss(animated: true)
    }
}

private final class SettingsOptionRowControl: UIControl {
    let option: SettingsOptionItem

    init(option: SettingsOptionItem) {
        self.option = option
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
