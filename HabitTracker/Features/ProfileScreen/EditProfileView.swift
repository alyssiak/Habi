//
//  EditProfileView.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import UIKit
import SnapKit

final class EditProfileView: UIView {
    //MARK: - Properties
    private let avatarImageView = UIImageView()
    private let changePhotoButton = UIButton(type: .system)
    private let nameTitleLabel = UILabel()
    private let nameTextField = UITextField()
    private let saveButton = UIButton(type: .system)

    var onChangePhotoTapped: (() -> Void)?
    var onSaveTapped: ((String) -> Void)?

    private enum Layout {
        static let horizontalInset: CGFloat = 20
        static let topInset: CGFloat = 32
        static let avatarSize: CGFloat = 112
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 52
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

    //MARK: - Configuration
    func configure(with state: EditProfileViewState) {
        nameTextField.text = state.name

        if let avatarData = state.avatarData,
           let image = UIImage(data: avatarData) {
            avatarImageView.image = image
            avatarImageView.tintColor = nil
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .appOrange
        }
    }
}

//MARK: - Setup View
private extension EditProfileView {
    func setupView() {
        backgroundColor = .systemBackground
    }

    func setupContent() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarSize / 2
        avatarImageView.backgroundColor = .secondarySystemBackground

        changePhotoButton.setTitle("Change photo", for: .normal)
        changePhotoButton.setTitleColor(.appOrange, for: .normal)
        changePhotoButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 15)
        changePhotoButton.addTarget(self, action: #selector(didTapChangePhoto), for: .touchUpInside)

        nameTitleLabel.text = "Name"
        nameTitleLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        nameTitleLabel.textColor = .label

        nameTextField.font = UIFont(name: "Montserrat-Regular", size: 16)
        nameTextField.textColor = .label
        nameTextField.backgroundColor = .secondarySystemBackground
        nameTextField.layer.cornerRadius = Layout.cornerRadius
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        nameTextField.leftViewMode = .always
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.returnKeyType = .done

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        saveButton.backgroundColor = .appOrange
        saveButton.layer.cornerRadius = Layout.cornerRadius
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        addSubview(avatarImageView)
        addSubview(changePhotoButton)
        addSubview(nameTitleLabel)
        addSubview(nameTextField)
        addSubview(saveButton)
    }
}

//MARK: - Setup Constraints
private extension EditProfileView {
    func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(Layout.topInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.avatarSize)
        }

        changePhotoButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        nameTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(changePhotoButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.buttonHeight)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(Layout.buttonHeight)
        }
    }
}

//MARK: - Actions
private extension EditProfileView {
    @objc func didTapChangePhoto() {
        onChangePhotoTapped?()
    }

    @objc func didTapSave() {
        onSaveTapped?(nameTextField.text ?? "")
    }
}
