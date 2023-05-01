//
//  RecoveryCalc.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 1/5/23.
//

import Foundation
import HealthKit

public class RecoveryCalc{
    
    let healthStore = HKHealthStore()
    let objectTypes: Set<HKObjectType> = [HKObjectType.activitySummaryType()]
    let calendar = Calendar.autoupdatingCurrent
    
    static var bedTime = Date()
    static var wakeTime = Date()
    static var hoursSlept = 0.0
    static var intHoursSlept = 0
    static var minutesSlept = 0
    
    //Function that gets sleep and wake time
    //Help from Anushk Mittal https://www.appcoda.com/sleep-analysis-healthkit/
    func getsleep(){
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            RecoveryCalc.bedTime = sample.startDate
                            RecoveryCalc.wakeTime = sample.endDate
                            print("Bed Time: \(RecoveryCalc.bedTime)")
                            print("Wake Time: \(RecoveryCalc.wakeTime)")
                            RecoveryCalc.findSleepHours(asleep: RecoveryCalc.bedTime, awake: RecoveryCalc.wakeTime)
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
    }
    
   static func findSleepHours(asleep: Date, awake: Date){
        let diff = Double(awake.timeIntervalSince1970 - asleep.timeIntervalSince1970)
       var hours = (((diff/60.0)/60.0)*100).rounded() / 100
       let intHours = Int(hours)
       let minutes = Int(((hours - Double(intHours)) * 60.0))
       RecoveryCalc.hoursSlept = hours
       RecoveryCalc.intHoursSlept = intHours
       RecoveryCalc.minutesSlept = minutes
       print("Time Slept: \(RecoveryCalc.hoursSlept) hours and  \(RecoveryCalc.minutesSlept) minutes")
    }

}

