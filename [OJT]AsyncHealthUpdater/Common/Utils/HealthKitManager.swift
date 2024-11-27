//
//  HealthKitManager.swift
//  [OJT]AsyncHealthUpdater
//
//  Created by 구지연 on 11/26/24.
//

import Combine
import Foundation
import HealthKit

enum HealthKitError: Error {
    case noData
    case unknown
}

final class HealthKitManager {
    private let healthStore = HKHealthStore()
    static let shared = HealthKitManager()
    
    private init() {}
    
    func requestAuthorization() {
        let readTypes = Set(HealthDataType.allCases.map { $0.hkObjectType })
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if success {
                    print("건강 데이터 권한 요청 완료")
                } else {
                    if let error = error {
                        print("건강 데이터 권한 요청 실패: \(error.localizedDescription)")
                    } else {
                        print("건강 데이터 권한 요청 실패: 알 수 없음")
                    }
                }
            }
        } else {
            print("HealthKit 사용할 수 없음")
        }
    }
    
    func getHealthDataCount(for dataType: HealthDataType) -> AnyPublisher<Int, HealthKitError> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // 날짜 범위 설정
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return Future<Int, HealthKitError> { [weak self] promise in
            let query = HKSampleQuery(
                sampleType: dataType.hkObjectType as! HKSampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil) { _, samples, error in
                    if error != nil {
                        promise(.failure(.unknown))
                    }
                    
                    guard let samples = samples else {
                        promise(.failure(.noData))
                        return
                    }
                    promise(.success(samples.count))
                }
            self?.healthStore.execute(query)
        }
        .eraseToAnyPublisher()
    }
}
