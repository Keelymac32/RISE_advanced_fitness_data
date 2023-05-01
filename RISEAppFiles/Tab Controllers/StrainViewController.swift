//
//  StrainViewController.swift

//
//  Created by Keelyn McNamara on 10/6/22.
//

import UIKit
import HealthKit
import SwiftUI
import Foundation

class StrainViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    let database = DB()
    
    static var inactiveHours = 0.0
    static var currentRestingHeartRate = 0.0
    static var walkingHeartRate = 0.0
    static var OtherTotalStressPoints = 0.0
    static var OtherIntensity = 0.0
    static var ElevatedMinutes = 0.0
    static var Strain = 0.0
    var current = 0.0
    
    @IBOutlet weak var InactiveHours: UILabel!
    @IBOutlet weak var ElevatedHR: UILabel!
    @IBOutlet weak var StrainLabel: UILabel!
    @IBOutlet weak var RectView: UIView!
   
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //code creating the button
        let refreshButton = UIButton()
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.titleLabel?.font = UIFont(name: "Apparat Heavy", size: 12)!
        refreshButton.frame = CGRect(x: 300, y: 75, width: 75, height: 25)
        refreshButton.layer.cornerRadius = 10
        view.addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        StrainViewController.inactiveHours = 0.0
        StrainViewController.ElevatedMinutes = 0.0
        getRestingHeartRate()
        getMaxHeartRate(completionHandler: block)
        main()
    }
    
    @objc func buttonTapped(){
        self.viewDidLoad()
     }
    
    
    let block: (Double) -> Void = { tempMAX in
        print("Max Heart Rate: \(tempMAX)")
        IntensityViewController.MaxHeartRateGlobal = tempMAX
        IntensityViewController.getWorkouts()
    }
    
    
    
    func main() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 9){ [self] in
            let StrainCalc = StrainElevation()
            StrainCalc.getElevated()
            calculateTime()
            setStrain()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
                if (StrainViewController.Strain.isNaN){
                    StrainViewController.Strain = 0.0
                }
                
                let hours = floor(StrainViewController.inactiveHours)
                let minutes = (StrainViewController.inactiveHours - hours) * 60
                InactiveHours.text = ("\(Int(hours).description) hrs \((Int(minutes)).description) mins")
                ElevatedHR.text = ("\(Int(ceil(StrainViewController.ElevatedMinutes)))  minutes")
                StrainLabel.text = (round(StrainViewController.Strain * 10)/10.0).description
                buildRect(StrainDouble: StrainViewController.Strain )
                
                if current < StrainViewController.Strain {
                    updateDatabase(new: StrainViewController.Strain)
                    current = StrainViewController.Strain
                }
            })
        }
        
        func updateDatabase(new: Double){
            database.updateStrain(newStrain: new)
        }
        
        func setStrain() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){ [self] in
                StrainViewController.Strain = strainCalculation(inactivehours: StrainViewController.inactiveHours, WorkoutIntensities: IntensityViewController.intensitylist, OtherIntensities: StrainViewController.OtherIntensity)}
        }
    }
        
    func getMaxHeartRate(completionHandler: @escaping (Double) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
        let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //query pass that will pull latest HeartRate
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) { query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else{
                print("**** Error***")
                return
            }
            var tempMAX = 0.0
            for sample in samples{
                let unit = HKUnit(from: "count/min")
                let doubleHR = sample.quantity.doubleValue(for: unit)
                if (doubleHR > tempMAX){
                    tempMAX = doubleHR
                }
            }
            completionHandler(tempMAX)
        }
        healthStore.execute(query)
    }
    
    func getRestingHeartRate(){
        guard let sampleResting = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {return }
        let date = Date() // current date or replace with a specific date
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        let predicate = HKSampleQuery.predicateForSamples(withStart: startTime, end: endTime)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let queryResting = HKSampleQuery(sampleType:sampleResting, predicate: predicate, limit: Int(HKObjectQueryNoLimit),sortDescriptors: [sortDescription]) {(sampleResting, resultResting, error) in
            guard let samples = resultResting as? [HKQuantitySample] else{
                print("**** Error***")
                return
            }
            for sample in samples {
                let unit = HKUnit(from: "count/min")
                let HR = sample.quantity.doubleValue(for: unit)
                StrainViewController.currentRestingHeartRate = HR
            }
            
        }
        self.healthStore.execute(queryResting)
    }
    
    
    func calculateTime(){
        print("Calculating Inactive Time")
        guard let sampleResting = HKObjectType.quantityType(forIdentifier: .heartRate) else { return}
        let date = Date() // current date or replace with a specific date
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        let predicate = HKSampleQuery.predicateForSamples(withStart: startTime, end: endTime)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let queryResting = HKSampleQuery(sampleType:sampleResting, predicate: predicate, limit: Int(HKObjectQueryNoLimit),sortDescriptors: [sortDescription]) {(sampleResting, resultResting, error) in
            guard let samples = resultResting as? [HKQuantitySample] else{
                print("**** Error***")
                return
            }
            let resting = StrainViewController.currentRestingHeartRate + 10
            print("Resting Heart Rate: \(resting)")
            var currentZone = "Start"
            var newZone = ""
            var zoneStartTime = samples[samples.startIndex].startDate
            for sample in samples{
                print("Zone Start Time: \(zoneStartTime)")
                let unit = HKUnit(from: "count/min")
                let HR = sample.quantity.doubleValue(for: unit)
                let time = sample.startDate
                if HR <= resting{
                    newZone = "inactive"
                }
                else{
                    newZone = "active"
                }
                if newZone != currentZone{
                    let seconds = self.findTimeDifference(startTime: zoneStartTime, endTime: time)
                    self.incrementMinutes(seconds: seconds, zone: currentZone)
                    zoneStartTime = time
                }
                currentZone = newZone
            }
            print("Inactive Hours: \(StrainViewController.inactiveHours)")
        }
        self.healthStore.execute(queryResting)
    }
    
    
        
        func findTimeDifference(startTime: Date, endTime: Date) -> Double {
            let diff = Double(startTime.timeIntervalSince1970 - endTime.timeIntervalSince1970)
            return diff
        }
        
        func incrementMinutes(seconds: Double, zone: String ){
            let minutes = (seconds / 60.0 )
            let hours = minutes / 60.0
            
            if zone == "inactive"{
                StrainViewController.inactiveHours += hours
            }
        }
    
    func strainCalculation(inactivehours: Double, WorkoutIntensities: [Double], OtherIntensities: Double) -> Double {
        
        var totalIntensity = 0.0
        if WorkoutIntensities.isEmpty{
            totalIntensity = OtherIntensities
        }
        else{
            for workouts in WorkoutIntensities{
                totalIntensity += workouts
            }
            totalIntensity += (OtherIntensities)
        }
        
        var Strain = (totalIntensity/2) - (inactivehours/4)
        if Strain <= 0{
            Strain = 0}
        else if Strain > 10 {
            Strain = 10
        }
        
        print("Daily Strain: \(Strain)")
        return Strain
    }
    
    func buildRect(StrainDouble: Double){
        var percentage = 1.0
        if StrainDouble == 0.0{
            percentage = 0.01}
        else{
            percentage = StrainDouble / 10.0}
        
        let height = -(400 * percentage)
        let rectFrame: CGRect = CGRect(x:CGFloat(100), y:CGFloat(420), width:CGFloat(100), height:CGFloat(height))
                // Create a UIView object which use above CGRect object.
                let blueRectView = UIView(frame: rectFrame)
                // Set UIView background color.
                //blueRectView.backgroundColor = UIColor.blue
                blueRectView.layer.addSublayer(gradientLayer)
                gradientLayer.frame = blueRectView.bounds
        
        
                // Add above UIView object as the main view's subview.
                RectView.addSubview(blueRectView)
    }
    
   
    var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]//Colors you want to add
        gradientLayer.startPoint = CGPoint(x: 4, y: 1)
        gradientLayer.endPoint = CGPoint(x: 2, y: 3)
        gradientLayer.frame = CGRect.zero
       return gradientLayer
    }()
    
    
    
    }

