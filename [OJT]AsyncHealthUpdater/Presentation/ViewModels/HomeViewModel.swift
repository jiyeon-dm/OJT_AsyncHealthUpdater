//
//  HomeViewModel.swift
//  [OJT]AsyncHealthUpdater
//
//  Created by 구지연 on 11/26/24.
//

import Combine
import Foundation

final class HomeViewModel {
    // MARK: - Action
    
    enum Action {
        case viewDidLoad
        case refresh
        case healthDataButtonDidTap
    }
    
    // MARK: - State
    
    struct State {
        let isFetchEnabled = CurrentValueSubject<Bool, Never>(true)
        let stepDataCount = CurrentValueSubject<Int?, Never>(nil)
        let distanceDataCount = CurrentValueSubject<Int?, Never>(nil)
        let sleepDataCount = CurrentValueSubject<Int?, Never>(nil)
        let heartRateDataCount = CurrentValueSubject<Int?, Never>(nil)
    }
    
    // MARK: - Properties
    
    private let healthKitManager: HealthKitManager
    private let dispatchGroup = DispatchGroup()
    
    private var actionPublisher = PassthroughSubject<Action, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var state: State
    
    // MARK: - Init
    
    init(healthKitManager: HealthKitManager = .shared) {
        self.healthKitManager = healthKitManager
        self.state = State()
        
        setupActionBindings()
    }
    
    // MARK: - Setup Methods
    
    private func setupActionBindings() {
        actionPublisher.sink { [weak self] action in
            switch action {
            case .viewDidLoad:
                self?.healthKitManager.requestAuthorization()
            case .refresh:
                self?.state.isFetchEnabled.send(true)
            case .healthDataButtonDidTap:
                self?.fetchAllHealthData()
            }
        }
        .store(in: &cancellables)
    }
    
    private func fetchAllHealthData() {
        var delay: Double = 0.0
        HealthDataType.allCases.forEach { [weak self] dataType in
            guard let self = self else { return }
            dispatchGroup.enter()
            delay += 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.healthKitManager.getHealthDataCount(for: dataType)
                    .sink { [weak self] completion in
                        guard let self = self else { return }
                        defer { dispatchGroup.leave() } // 항상 leave 보장
                        
                        if case .failure(let error) = completion {
                            print(dataType, "패치 에러: ", error.localizedDescription)
                        }
                    } receiveValue: { [weak self] count in
                        guard let self = self else { return }
                        
                        switch dataType {
                        case .stepCount:        state.stepDataCount.send(count)
                        case .distance:         state.distanceDataCount.send(count)
                        case .sleepAnalysis:    state.sleepDataCount.send(count)
                        case .heartRate:        state.heartRateDataCount.send(count)
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
        
        // main queue에서 실행한다는 뜻
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.state.isFetchEnabled.send(false)
        }
    }
    
    func send(_ action: Action) {
        actionPublisher.send(action)
    }
}
