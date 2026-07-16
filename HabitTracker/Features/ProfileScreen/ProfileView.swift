//
//  ProfileView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    //MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileCardView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let profileMessageLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)

    private let bubbleStatsView = ProfileBubbleStatsView()

    private let settingsTitleLabel = UILabel()
    private let settingsStackView = UIStackView()

    var onEditProfileTapped: (() -> Void)?

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let topInset: CGFloat = 20
        static let avatarSize: CGFloat = 72
        static let editButtonSize: CGFloat = 36
        static let cardCornerRadius: CGFloat = 20
        static let rowCornerRadius: CGFloat = 16
        static let cardInset: CGFloat = 16
    }

    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupContent()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with state: ProfileViewState) {
        nameLabel.text = state.userName
        subtitleLabel.text = state.subtitle
        profileMessageLabel.text = state.profileMessage
        bubbleStatsView.configure(with: state.bubbleMetrics)

        renderSettingsItems(state.settingsItems)
    }
}

//MARK: - Setup
private extension ProfileView {
    func setupView() {
        backgroundColor = .systemBackground

        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    func setupContent() {
        profileCardView.backgroundColor = .clear
        profileCardView.layer.cornerRadius = Layout.cardCornerRadius

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .appOrange
        avatarImageView.contentMode = .scaleAspectFit

        nameLabel.font = UIFont(name: "Montserrat-SemiBold", size: 28)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1

        subtitleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        subtitleLabel.textColor = .secondaryLabel

        profileMessageLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        profileMessageLabel.textColor = .secondaryLabel
        profileMessageLabel.numberOfLines = 0

        editProfileButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        editProfileButton.tintColor = .label
        editProfileButton.backgroundColor = .clear
        editProfileButton.layer.cornerRadius = Layout.editButtonSize / 2
        editProfileButton.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)

        settingsTitleLabel.text = "Settings"
        settingsTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        settingsTitleLabel.textColor = .label

        settingsStackView.axis = .vertical
        settingsStackView.spacing = 10

        contentView.addSubview(profileCardView)
        contentView.addSubview(bubbleStatsView)
        contentView.addSubview(settingsTitleLabel)
        contentView.addSubview(settingsStackView)

        profileCardView.addSubview(avatarImageView)
        profileCardView.addSubview(nameLabel)
        profileCardView.addSubview(subtitleLabel)
        profileCardView.addSubview(profileMessageLabel)
        profileCardView.addSubview(editProfileButton)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        profileCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.topInset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Layout.cardInset)
            make.size.equalTo(Layout.avatarSize)
        }

        editProfileButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Layout.cardInset)
            make.size.equalTo(Layout.editButtonSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top).offset(6)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualTo(editProfileButton.snp.leading).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualTo(editProfileButton.snp.leading).offset(-12)
        }

        profileMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(18)
            make.leading.trailing.bottom.equalToSuperview().inset(Layout.cardInset)
        }

        bubbleStatsView.snp.makeConstraints { make in
            make.top.equalTo(profileCardView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(280)
        }

        settingsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bubbleStatsView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

//MARK: - Actions
private extension ProfileView {
    @objc func didTapEditProfile() {
        onEditProfileTapped?()
    }
}

//MARK: - Render
private extension ProfileView {
    func renderSettingsItems(_ items: [ProfileSettingsItem]) {
        settingsStackView.arrangedSubviews.forEach {
            settingsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        items.forEach { item in
            settingsStackView.addArrangedSubview(makeSettingsRow(item))
        }
    }

    func makeSettingsRow(_ item: ProfileSettingsItem) -> UIView {
        let rowView = UIView()
        rowView.backgroundColor = .clear
        rowView.layer.cornerRadius = Layout.rowCornerRadius

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: item.iconName)
        iconImageView.tintColor = .appOrange
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 15)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = item.subtitle
        subtitleLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        subtitleLabel.textColor = .secondaryLabel

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 2

        let accessoryView = makeAccessoryView(item.accessory)

        rowView.addSubview(iconImageView)
        rowView.addSubview(textStackView)
        rowView.addSubview(accessoryView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        textStackView.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(accessoryView.snp.leading).offset(-12)
        }

        accessoryView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }

        rowView.snp.makeConstraints { make in
            make.height.equalTo(64)
        }

        return rowView
    }

    func makeAccessoryView(_ accessory: ProfileSettingsAccessory) -> UIView {
        switch accessory {
        case .chevron:
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "chevron.right")
            imageView.tintColor = .tertiaryLabel
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { make in
                make.size.equalTo(14)
            }
            return imageView
        case .switcher(let isOn):
            let switchView = UISwitch()
            switchView.isOn = isOn
            switchView.isUserInteractionEnabled = false
            return switchView
        }
    }
}

//MARK: - Bubble Statistics
private final class ProfileBubbleStatsView: UIView {
    private let titleLabel = UILabel()
    private let currentStreakBubble = ProfileMetricBubbleView()
    private let bestStreakBubble = ProfileMetricBubbleView()
    private let completionRateBubble = ProfileMetricBubbleView()
    private let perfectDaysBubble = ProfileMetricBubbleView()

    private enum Layout {
        static let cornerRadius: CGFloat = 20
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with metrics: [ProfileBubbleMetric]) {
        let bubbles = [
            currentStreakBubble,
            bestStreakBubble,
            completionRateBubble,
            perfectDaysBubble
        ]

        zip(bubbles, metrics).forEach { bubble, metric in
            bubble.configure(with: metric)
        }
    }

    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = Layout.cornerRadius

        titleLabel.text = "Weekly snapshot"
        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        titleLabel.textColor = .label

        addSubview(titleLabel)
        addSubview(currentStreakBubble)
        addSubview(bestStreakBubble)
        addSubview(completionRateBubble)
        addSubview(perfectDaysBubble)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        currentStreakBubble.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.size.equalTo(94)
        }

        bestStreakBubble.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(58)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.size.equalTo(68)
        }

        completionRateBubble.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(92)
            make.size.equalTo(100)
        }

        perfectDaysBubble.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(22)
            make.top.equalTo(titleLabel.snp.bottom).offset(82)
            make.size.equalTo(80)
        }
    }
}

private final class ProfileMetricBubbleView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }

    func configure(with metric: ProfileBubbleMetric) {
        valueLabel.text = metric.value
        titleLabel.text = metric.title
        backgroundColor = metric.style.backgroundColor
    }

    private func setupView() {
        clipsToBounds = true

        valueLabel.font = UIFont(name: "Montserrat-Bold", size: 17)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75

        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 10)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        addSubview(valueLabel)
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
}

private extension ProfileBubbleMetricStyle {
    var backgroundColor: UIColor {
        switch self {
        case .pink:
            return UIColor(hex: "#F2B8C6")
        case .blue:
            return UIColor(hex: "#9DBAF6")
        case .purple:
            return UIColor(hex: "#B79AF6")
        case .orange:
            return UIColor(hex: "#F3B37C")
        }
    }
}
