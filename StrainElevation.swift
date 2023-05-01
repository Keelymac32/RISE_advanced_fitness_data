//
//  StrainElevation.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 2/15/23.
//

import Foundation
import HealthKit

public class StrainElevation{
    
    let healthStore = HKHealthStore()
    let max = IntensityViewController.MaxHeartRateGlobal
    
    let Zone1 = IntensityViewController.MaxHeartRateGlobal * 0.45
    let Zone2 = IntensityViewController.MaxHeartRateGlobal * 0.59
    let Zone3 = IntensityViewController.MaxHeartRateGlobal * 0.79
    let Zone4 = IntensityViewController.MaxHeartRateGlobal * 0.9
    
    
    var MinutesLight = 0.0
    var MinutesModerate = 0.0
    var MinutesVigorous = 0.0
    var MinutesExtreme = 0.0
    
    
    func getElevated(){
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
        let date = Date() // current date or replace with a specific date
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        let predicate = HKSampleQuery.predicateForSamples(withStart: startTime, end: endTime)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) { [self] query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else{
                print("**** Error***")
                return
            }
            var currentZone = "Start"
            var newZone = ""
            var zoneStartTime = samples[samples.startIndex].startDate
            for sample in samples{
                let unit = HKUnit(from: "count/min")
                let HR = sample.quantity.doubleValue(for: unit)
                let time = sample.startDate
                    if HR  < self.Zone1 {
                        newZone = "Recovery"
                    }
                    else if HR >= self.Zone1 && HR < self.Zone2{
                        newZone = "Light"
                    }
                    else if HR >= self.Zone2 && HR < self.Zone3{
                        newZone = "Moderate"
                    }
                    else if HR >= self.Zone3 && HR < self.Zone4{
                        newZone = "Vigorous"
                    }
                    else if HR >= self.Zone4{
                        newZone = "Extreme"
                    }
                    else{
                        newZone = "undefined"
                    }
                    
                    if newZone != currentZone{
                        let seconds = self.findTimeDifference(startTime: zoneStartTime, endTime: time)
                        self.incrementMinutes(seconds: seconds, zone: currentZone)
                        zoneStartTime = time
                    }
                    currentZone = newZone
               }
            self.showMinutes()
            self.calculateStressScore(Light: MinutesLight, Moderate: MinutesModerate,
                                      Vigorous: MinutesModerate, Extreme: MinutesExtreme)
            }
        healthStore.execute(query)
    }
    
    
    
    
    
    func findTimeDifference(startTime: Date, endTime: Date) -> Double {
        let diff = Double(startTime.timeIntervalSince1970 - endTime.timeIntervalSince1970)
        return diff
    }
    
    
    
    func incrementMinutes(seconds: Double, zone: String ){
        let minutes = (seconds / 60.0 )
       
        
        if zone == "Light" {
            MinutesLight = MinutesLight + minutes
            StrainViewController.ElevatedMinutes += minutes
        }
        else if zone == "Moderate"{
            MinutesModerate = MinutesModerate + minutes
            StrainViewController.ElevatedMinutes += minutes
        }
        else if zone == "Vigorous"{
            MinutesVigorous = MinutesVigorous + minutes
            StrainViewController.ElevatedMinutes += minutes
        }
        else if zone == "Extreme" {
            MinutesExtreme = MinutesExtreme + minutes
            StrainViewController.ElevatedMinutes += minutes
        }
        else{
        }
        
    }
    
    func calculateStressScore(Light: Double, Moderate: Double,
                              Vigorous: Double, Extreme: Double){
        
        let LightStressPoints = MinutesLight * 1
        let ModerateStressPoints = MinutesModerate * 3
        let VigorousStressPoints = MinutesVigorous * 6
        let ExtremeStressPoints = MinutesExtreme * 8
        var totalStressPoints = (LightStressPoints + ModerateStressPoints + VigorousStressPoints + ExtremeStressPoints)
        print("**Total Non-Workout Stress Points Before Subtraction***: \(totalStressPoints)")
        if IntensityCalc.TotalPoints.isEmpty == false{

            print( IntensityCalc.TotalPoints)
            
    /* double adding*/
            for totals in IntensityCalc.TotalPoints{
                print("Total: \(totals)")
                totalStressPoints = totalStressPoints - totals
            }
            
        }
        else{
            print("Workout list Is Empty")
        }
        if totalStressPoints < 0 {
            totalStressPoints = 0.0
        }
        
        print("Total Non-Workout Stress Points: \(totalStressPoints)")
        StrainViewController.OtherIntensity = IntensityCalc.getWorkoutIntensity(totalScore: totalStressPoints)
        
        
    }
        
    
    
    func showMinutes(){
        print("Light Zone: \(MinutesLight)")
        print("Moderate Zone: \(MinutesModerate)")
        print("Vigorous Zone: \(MinutesVigorous)")
        print("Extreme Zone: \(MinutesExtreme)")
        
    }
    
}
