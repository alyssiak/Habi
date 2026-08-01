//
//  ArchivedHabitCell.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 24.06.2026.
//

import UIKit
import SnapKit

final class ArchivedHabitCell: UITableViewCell {
    static let reuseIdentifier = "ArchivedHabitCell"
    //MARK: - Properties

    var onRestoreTapped: (() -> Void)?
    
    private let containerView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let textStackView = UIStackView()
    private let contentStackView = UIStackView()
    private let restoreButton = UIButton(type: .system)
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.isHidden = false
        onRestoreTapped = nil
    }
    
    //MARK: - Configuration
    func configure(with model: ArchivedHabitModel) {
        emojiLabel.text = model.emoji
        titleLabel.text = model.title
        descriptionLabel.text = model.descriptionText
        descriptionLabel.isHidden = model.descriptionText.isEmpty
        containerView.backgroundColor = UIColor(hex: model.colorHex).withAlphaComponent(0.12)
    }
    
    //MARK: - Setup
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = .appSecondaryBackground
    }
    
    private func setupContent() {
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.textAlignment = .center

        titleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail

        restoreButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        restoreButton.tintColor = .systemOrange
        restoreButton.backgroundColor = .appBackground
        restoreButton.layer.cornerRadius = 18
        restoreButton.addTarget(self, action: #selector(didTapRestore), for: .touchUpInside)

        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)

        contentStackView.axis = .horizontal
        contentStackView.spacing = 12
        contentStackView.alignment = .center
        contentStackView.addArrangedSubview(emojiLabel)
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(restoreButton)

        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(14)
        }
        
        emojiLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }
        
        restoreButton.snp.makeConstraints { make in
            make.size.equalTo(36)
        }
    }
    
    //MARK: - Actions
    @objc private func didTapRestore() {
        onRestoreTapped?()
    }
}
