//
//  HomeView.swift
//  [OJT]AsyncHealthUpdater
//
//  Created by 구지연 on 11/26/24.
//

import UIKit

import SnapKit

final class HomeView: UIView {
    let refreshButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        if let image = UIImage(systemName: "arrow.clockwise") {
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            let resizedImage = image.withConfiguration(configuration)
            button.setImage(resizedImage, for: .normal)
        }
        button.tintColor = .label
        return button
    }()
    
    let healthDataButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8.0
        let attributedTitle = NSAttributedString(
            string: "건강 데이터 가져오기",
            attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .heavy)]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var stackView = createStackView(axis: .vertical)
    
    private lazy var topStackView = createStackView(axis: .horizontal)
    
    private lazy var bottomStackView = createStackView(axis: .horizontal)
    
    let stepCountView = HealthDataView(dataType: .stepCount)
    
    let distanceCountView = HealthDataView(dataType: .distance)
    
    let sleepCountView = HealthDataView(dataType: .sleepAnalysis)
    
    let heartRateCountView = HealthDataView(dataType: .heartRate)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
    }
    
    private func setupLayout() {
        addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.top.equalToSuperview().inset(72)
            make.trailing.equalToSuperview().inset(20)
        }
        
        addSubview(healthDataButton)
        healthDataButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(150)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(healthDataButton.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(210)
        }
        
        [topStackView, bottomStackView].forEach { stackView.addArrangedSubview($0) }
        [stepCountView, distanceCountView].forEach { topStackView.addArrangedSubview($0) }
        [sleepCountView, heartRateCountView].forEach { bottomStackView.addArrangedSubview($0) }
    }
    
    func update(isFetchEnabled: Bool) {
        refreshButton.isHidden = isFetchEnabled
        healthDataButton.isEnabled = isFetchEnabled
        healthDataButton.backgroundColor = isFetchEnabled ? .systemTeal : .systemGray
        if isFetchEnabled {
            [stepCountView, distanceCountView, sleepCountView, heartRateCountView].forEach {
                $0.configure(with: nil)
            }
        }
    }
}

private extension HomeView {
    func createStackView(axis: NSLayoutConstraint.Axis) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.spacing = 10.0
        stackView.distribution = .fillEqually
        return stackView
    }
}
