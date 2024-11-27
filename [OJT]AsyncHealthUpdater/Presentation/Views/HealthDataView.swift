//
//  HealthDataView.swift
//  [OJT]AsyncHealthUpdater
//
//  Created by 구지연 on 11/26/24.
//

import UIKit

import SnapKit

final class HealthDataView: UIView {
    // MARK: - Components
    
    private let titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17.0, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let dataStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3.0
        stackView.alignment = .lastBaseline
        return stackView
    }()
    
    private let countLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25.0, weight: .black)
        label.textColor = .systemTeal
        return label
    }()
    
    private let unitLabel = {
        let label = UILabel()
        label.text = "개"
        label.font = .systemFont(ofSize: 15.0, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Init
    
    init(dataType: HealthDataType) {
        super.init(frame: .zero)
        setupView(with: dataType.description)
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView(with title: String) {
        titleLabel.text = title
        backgroundColor = .systemBackground
        layer.cornerRadius = 15.0
        dataStackView.isHidden = true
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(15)
        }
        
        [countLabel, unitLabel].forEach { dataStackView.addArrangedSubview($0) }
        addSubview(dataStackView)
        dataStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    // MARK: - Configure Methods
    
    func configure(with count: Int?) {
        if let count = count {
            countLabel.text = String(count)
            dataStackView.isHidden = false
        } else {
            dataStackView.isHidden = true
        }
    }
}
