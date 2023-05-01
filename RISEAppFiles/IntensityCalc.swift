//
//  IntensityCalc.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 11/17/22.
//

import Foundation
import HealthKit



public class IntensityCalc{
    
    //health store database object created
    let healthStore = HKHealthStore()
    
    //constant variables
    let Zone1Points = 0.0
    let Zone2Points = 1.0
    let Zone3Points = 3.0
    let Zone4Points = 6.0
    let Zone5Points = 8.0
    
    //local variables that must be initialized
    var workoutList: [HKSample]
    let RestingHeartRate: Double
    let Zone1: Double
    let Zone2: Double
    let Zone3: Double
    let Zone4: Double
    let MaxHeartRate: Double
    
    
    
    //local variable up set
    let emptyList: [HKSample] = []
    var intensityList: [Double] = []
    var nameList: [String] = []
    var StartTimes: [Date] = []
    
    static var TotalPoints: [Double] = []
    
    
    var MinutesRecovery: Double = 0.0
    var MinutesLight: Double = 0.0
    var MinutesModerate: Double = 0.0
    var MinutesVigorous: Double = 0.0
    var MinutesExtreme: Double = 0.0
    
    var TempWorkoutIntensity = 0.0
    
    var globalHRList: [HKSample] = []
    
    
    init(workoutList: [HKSample], Resting: Double, Max: Double) {
        self.workoutList = workoutList
        self.RestingHeartRate = Resting
        self.MaxHeartRate = Max
        self.Zone1 = Max * 0.45
        self.Zone2 = Max * 0.59
        self.Zone3 = Max * 0.79
        self.Zone4 = Max * 0.9
        
    }
    
    
    func calculate() {
        //For each out in the list provided by Intensity Tab Controller
        for workoutList: HKSample in workoutList {
            let workout: HKWorkout = (workoutList as! HKWorkout) //workout is each workout query object
            
            let TravelingWorkoutName = self.setWorkoutName(type: workout.workoutActivityType)
            //method calls to update empty local variables
            self.getTodaysHeartRates(start: workout.startDate, end: workout.endDate, Activityname: TravelingWorkoutName) //getting heart rate data and workout intensity
            
        }
        self.calculateZones()
    }
    
    
    
    
    func getWorkoutIntensities() -> [Double]{
        return intensityList
    }
    
    func setWorkoutName(type: HKWorkoutActivityType) -> String {
        let value = Int(type.rawValue)
        print(type.rawValue)
        let NameFind = WorkoutTypes(rawValue: value)
        let name = NameFind.getname()
        return(name.description) }
    
    func getWorkoutName() -> [String]{
        return nameList
    }
    
    func getWorkoutDuration(start: Date, end: Date) -> Double{
        let sec = findTimeDifference(startTime: end, endTime: start)
        let minutes = sec / 60
        return minutes
    }
    
    var heartRateQuery:HKSampleQuery?
    
    /*Method to get todays heart rate - this only reads data from health kit. */
    func getTodaysHeartRates(start: Date, end: Date, Activityname: String)
    {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options:[])
        
        //descriptor
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
            guard error == nil else{
                return}
            
            let HRdata = result!
            //self.printHeartRateInfo(results: HRdata)
            let workoutIntensity = self.calculateHeartRateZones(list: HRdata)
            self.setWorkOutIntensity(intensity: workoutIntensity, name: Activityname, startTime: start )
        }//eo-query
        healthStore.execute(heartRateQuery!)
    }//eom
    
    
    
    
    func setWorkOutIntensity(intensity: Double, name: String, startTime: Date){
        let intensityNum = (round(intensity * 10)/10.0)
        if StartTimes.isEmpty{
            intensityList.append(intensityNum)
            nameList.append(name)
            StartTimes.append(startTime)
        }
        else{
            for index in StartTimes.indices {
                if StartTimes[index] < startTime{
                    StartTimes.insert(startTime, at: index)
                    nameList.insert(name, at: index)
                    intensityList.insert(intensityNum, at: index)
                }
                else if StartTimes[index] == StartTimes.last {
                intensityList.append(intensityNum)
                nameList.append(name)
                StartTimes.append(startTime)
                }
            }
            
            //intensityList.append(intensityNum)
           // nameList.append(name)
        }
        print(intensityList)
        print(nameList)
    }
    
    
    
    
    func calculateZones(){
        print("Zone 1 = \(RestingHeartRate) to \(Zone1)")
        print("Zone 2 = \(Zone1) to \(Zone2)")
        print("Zone 3 = \(Zone2) to \(Zone3)")
        print("Zone 4 = \(Zone3) to \(Zone4)")
        print("Zone 5 = \(Zone4) to \(MaxHeartRate)")
    }
    
    
    func calculateHeartRateZones(list: [HKSample]) -> Double{
        var currentZone = "Start"
        var newZone = ""
        var zoneStartTime = list[0].startDate
        for sample in list{
            let HRQuantitySample = sample as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let heartRate = HRQuantitySample.quantity.doubleValue(for: unit)
            let time = sample.startDate
            
            if heartRate  < Zone1 {
                newZone = "Recovery"
            }
            else if heartRate >= Zone1 && heartRate < Zone2{
                newZone = "Light"
            }
            else if heartRate >= Zone2 && heartRate < Zone3{
                newZone = "Moderate"
            }
            else if heartRate >= Zone3 && heartRate < Zone4{
                newZone = "Vigorous"
            }
            else if heartRate >= Zone4{
                newZone = "Extreme"
            }
            else{
                newZone = "undefined"
            }
            
            
            if newZone != currentZone{
                let seconds = findTimeDifference(startTime: zoneStartTime, endTime: time)
                incrementMinutes(seconds: seconds, zone: currentZone)
                zoneStartTime = time
            }
            currentZone = newZone
        }
        showMinutes()
        let totalStresScore = calculateStressScore(Recovery: MinutesRecovery, Light: MinutesLight, Moderate: MinutesModerate, Vigorous: MinutesVigorous, Extreme: MinutesExtreme)
        let workoutIntensity = IntensityCalc.getWorkoutIntensity(totalScore: totalStresScore)
        clearMinutes()
        return workoutIntensity
        
        
    }
    
    func findTimeDifference(startTime: Date, endTime: Date) -> Double {
        let diff = Double(startTime.timeIntervalSince1970 - endTime.timeIntervalSince1970)
        return diff
    }
    
    func incrementMinutes(seconds: Double, zone: String ){
        let minutes = (seconds / 60.0 )
        
        if zone == "Recovery"{
            MinutesRecovery = MinutesRecovery + minutes
        }
        else if zone == "Light" {
            MinutesLight = MinutesLight + minutes
        }
        else if zone == "Moderate"{
            MinutesModerate = MinutesModerate + minutes
        }
        else if zone == "Vigorous"{
            MinutesVigorous = MinutesVigorous + minutes
        }
        else{
            MinutesExtreme = MinutesExtreme + minutes
        }
        
        
    }
    
    func calculateStressScore(Recovery: Double, Light: Double, Moderate: Double,
                              Vigorous: Double, Extreme: Double) -> Double{
        
        let RecoveryStressPoints = Recovery * Zone1Points
        let LightStressPoints = Light * Zone2Points
        let ModerateStressPoints = Moderate * Zone3Points
        let VigorousStressPoints = Vigorous * Zone4Points
        let ExtremeStressPoints = Extreme * Zone5Points
        let totalStressPoints = (RecoveryStressPoints + LightStressPoints + ModerateStressPoints +                               VigorousStressPoints + ExtremeStressPoints)
        IntensityCalc.TotalPoints = []
        IntensityCalc.TotalPoints.append(totalStressPoints)
        print("Total Stress Points: \(totalStressPoints)")
        return totalStressPoints
    }
    
    static func getWorkoutIntensity(totalScore: Double) -> Double{
        var workoutIntensity = (4.3144 * log(totalScore)) - 13.911
        if (workoutIntensity < 0){
           workoutIntensity = 0.0
        }
        if (workoutIntensity > 10){
            workoutIntensity = 10.0
        }
        print("Workout Intensity: \(workoutIntensity)")
        print("<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>.")
        print("")
        return workoutIntensity
    }
    
    func showMinutes(){
        print("Recovery Zone: \(MinutesRecovery)")
        print("Light Zone: \(MinutesLight)")
        print("Moderate Zone: \(MinutesModerate)")
        print("Vigorous Zone: \(MinutesVigorous)")
        print("Extreme Zone: \(MinutesExtreme)")
    }
    
    func clearMinutes(){
        MinutesRecovery = 0.0
        MinutesLight = 0.0
        MinutesModerate =  0.0
        MinutesVigorous = 0.0
        MinutesExtreme = 0.0
    }
    

    
    
    
}




 
