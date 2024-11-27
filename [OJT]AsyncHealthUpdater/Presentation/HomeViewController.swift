//
//  HomeViewController.swift
//  [OJT]AsyncHealthUpdater
//
//  Created by 구지연 on 11/26/24.
//

import Combine
import UIKit

final class HomeViewController: UIViewController {
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Components
    
    private let homeView = HomeView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAction()
        setupBindings()
        viewModel.send(.viewDidLoad)
    }
    
    // MARK: - Setup Methods
    
    private func setupAction() {
        refreshButton.addTarget(
            self,
            action: #selector(handleRefreshButtonDidTap),
            for: .touchUpInside
        )
        
        healthDataButton.addTarget(
            self,
            action: #selector(handleHealthDataButtonDidTap),
            for: .touchUpInside
        )
    }
    
    private func setupBindings() {
        viewModel.state.isFetchEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnabled in
                self?.homeView.update(isFetchEnabled: isEnabled)
            }
            .store(in: &cancellables)
        
        viewModel.state.stepDataCount
            .receive(on: RunLoop.main)
            .sink { [weak self] count in
                self?.stepCountView.configure(with: count)
            }
            .store(in: &cancellables)
        
        viewModel.state.distanceDataCount
            .receive(on: RunLoop.main)
            .sink { [weak self] count in
                self?.distanceCountView.configure(with: count)
            }
            .store(in: &cancellables)
        
        viewModel.state.sleepDataCount
            .receive(on: RunLoop.main)
            .sink { [weak self] count in
                self?.sleepCountView.configure(with: count)
            }
            .store(in: &cancellables)
        
        viewModel.state.heartRateDataCount
            .receive(on: RunLoop.main)
            .sink { [weak self] count in
                self?.heartRateCountView.configure(with: count)
            }
            .store(in: &cancellables)
    }
    
    @objc private func handleRefreshButtonDidTap() {
        viewModel.send(.refresh)
    }
    
    @objc private func handleHealthDataButtonDidTap() {
        viewModel.send(.healthDataButtonDidTap)
    }
}

private extension HomeViewController {
    var refreshButton: UIButton {
        homeView.refreshButton
    }
    
    var healthDataButton: UIButton {
        homeView.healthDataButton
    }
    
    var stepCountView: HealthDataView {
        homeView.stepCountView
    }
    
    var distanceCountView: HealthDataView {
        homeView.distanceCountView
    }
    
    var sleepCountView: HealthDataView {
        homeView.sleepCountView
    }
    
    var heartRateCountView: HealthDataView {
        homeView.heartRateCountView
    }
}
