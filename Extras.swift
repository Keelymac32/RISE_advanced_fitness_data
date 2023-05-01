/*
 
 //
 //  RecoveryViewController.swift
 //  A class that controls the first recovery screen as well as does health data calculations
 //
 //  Created by Keelyn McNamara on 10/6/22.
 //
 import UIKit
 import HealthKit
 import SwiftUI
 import Foundation

 class IntensityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     
     let healthStore = HKHealthStore()
     
     
     
     var HeartRateGlobal = 0.0
     var MaxHeartRateGlobal = 0.0
     var RestingHeartRateGlobal = 0.0
     var workoutlist: [HKWorkout] = []
     var intensitylist: [Double] = []
     var workoutNameList: [String] = []
     var workoutnumber: [Double] = []
     
     // Main driver method that set sup screen and calls other methods
     
     
     @IBOutlet weak var tableView: UITableView!


     
     
     override func viewDidLoad(){
         super.viewDidLoad()
         setNumberOfWorkouts()
         calcMaxHeartRate()
         calcRestingHeartRate()
         calcHeartRate()// Updating global Heart Rate
         updateScreen() // Method call to update with health information
     }
     var timer = Timer()
     //updating screen with label of health data

     func updateScreen(){
         
         let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
         label.center = CGPoint(x: 230, y: 240)
         label.textAlignment = .center
         
         let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
         label2.center = CGPoint(x: 230, y: 210)
         label2.textAlignment = .center
         
         let label3 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
         label3.center = CGPoint(x: 230, y: 172)
         label3.textAlignment = .center
         
     
         self.tableView.delegate = self
         self.tableView.dataSource = self
         
         timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
         
             
             
             label.text = ((round(self.HeartRateGlobal * 10)/10.0).description)
             label2.text = (self.MaxHeartRateGlobal.description)
             label3.text = (self.RestingHeartRateGlobal.description)
             
             self.view.addSubview(label)
             self.view.addSubview(label2)
             self.view.addSubview(label3)
         
             
             //print(self.intensitylist)
             //print("tick")
         })
         DispatchQueue.main.asyncAfter(deadline: .now() + 8){ [self] in
             self.getWorkouts()
         }
     }

     
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      print("Being Called Now")
         return 10
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
             if self.intensitylist.isEmpty{
                 var content = cell.defaultContentConfiguration()
                 content.text = ""
                 cell.contentConfiguration = content
             }
             else if indexPath.row < self.intensitylist.endIndex{
                 var content = cell.defaultContentConfiguration()
                 content.text = ("\(self.workoutNameList[indexPath.row]): \(self.intensitylist[indexPath.row])")
                 cell.contentConfiguration = content}
             
             else{
                 var content = cell.defaultContentConfiguration()
                 content.text = ""
                 cell.contentConfiguration = content}
         })
         
         
         return cell
     }

     
     func setTable(){
         print("setting table....")
         self.tableView.delegate = self
         self.tableView.dataSource = self
     }
     //Checking to see if health data is available on the device (ex. yes to iPhone and no to iPad)

     func setNumberOfWorkouts(){
         let workoutType = HKObjectType.workoutType()
         let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
         let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
         let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
         
         let workoutNumQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
             guard error == nil else{
                 return}
             for workouts in result!{
                 self.workoutnumber.append(0)
             }
         }
         healthStore.execute(workoutNumQuery)
     }
     
     //Getting Resting Heartrate from Healthkit using Query
     func calcHeartRate()  {
         print("Getting Heart Rate.....")
         
         //variables for query pass
         guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
         let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
         let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
         let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
         
         //query pass that will pull latest HeartRate
         let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
             guard error == nil else{
                 return}
             //formatting query results
             let HRdata = result?[0] as! HKQuantitySample
             let unit = HKUnit(from: "count/min")
             let latestHR = HRdata.quantity.doubleValue(for: unit)
             self.getHeartRate(HeartRate: latestHR)
             print("Latest Heart Rate \(latestHR) BPM")}
         healthStore.execute(query)
     }
     
     func calcMaxHeartRate()  {
         print("Getting Max Heart Rate.....")
         //variables for query pass
         guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return }
         let startDate = Calendar.current.date(byAdding: .month, value: -6, to: Date())
         let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
         let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
         
         //query pass that will pull latest HeartRate
         let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
             guard error == nil else{
                 return}
             //formatting query results
             var tempMAX = 0.0
             for HR in result!{
                 let HRQuantitySample = HR as! HKQuantitySample
                 let unit = HKUnit(from: "count/min")
                 let doubleHR = HRQuantitySample.quantity.doubleValue(for: unit)
                 if (doubleHR > tempMAX){
                     tempMAX = doubleHR
                     self.getMAXHeartRate(HeartRate: tempMAX)
                 }
             }
             print("Max Heart Rate: \(tempMAX)")
             
         }
         healthStore.execute(query)
     }
     
     
     func calcRestingHeartRate(){
         print("Getting Resting Heart Rate....")
         //Resting Heart Rate Query
         guard let sampleResting = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else { return}
         let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())
         let predicateResting = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
         let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
         
         let queryResting = HKSampleQuery(sampleType:sampleResting, predicate: predicateResting, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sampleResting, resultResting, error) in
             guard error == nil else{
                 return}
             var tempREST = 100.0
             for HR in resultResting!{
                 let HRQuantitySample = HR as! HKQuantitySample
                 let unit = HKUnit(from: "count/min")
                 let doubleHR = HRQuantitySample.quantity.doubleValue(for: unit)
                 if (doubleHR < tempREST){
                     tempREST = doubleHR
                     self.RestingHeartRateGlobal = tempREST
                 }
             }
             print("Resting Heart Rate \(tempREST) BPM")
         }
         healthStore.execute(queryResting)
     }
     
     func getWorkouts(){
         print("Getting Workout data....")
         //variables for query pass
         let workoutType = HKObjectType.workoutType()
        // let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        // let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
         let date = Date() // current date or replace with a specific date
         let calendar = Calendar.current
         let startTime = calendar.startOfDay(for: date)
         let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
         
         let predicate = HKSampleQuery.predicateForSamples(withStart: startTime, end: endTime)
         
         let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
         
         //query pass that will pull last month of workouts
         
         
         let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescription]) {(sample, result, error) in
             guard error == nil else{
                 return}
             
             //Passes list of workouts in last 24 hours to class that will calculate Workout Intensity
             let WICalc = IntensityCalc(workoutList: result!, Resting: self.RestingHeartRateGlobal, Max: self.MaxHeartRateGlobal)
             //Calculates Workout Intensity
             WICalc.calculate()
             //Waits for Workout Intensity List to Be Updated
             DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                 self.intensitylist = WICalc.getWorkoutIntensities() //updating local intensity list with list from intensity calculation class
                 self.workoutNameList = WICalc.getWorkoutName()
                 
             }
         }
         healthStore.execute(workoutQuery)
     }
     
     //updates Global Variable for HR with Current Heart Rate
         func getHeartRate(HeartRate: Double){
             HeartRateGlobal = HeartRate
         }
         func getMAXHeartRate(HeartRate: Double){
             MaxHeartRateGlobal = HeartRate
         }
         func getRestingHeartRate(HeartRate: Double){
         RestingHeartRateGlobal = HeartRate
         }
     
     
 }

 extension ViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("you tapped me")
     }
 }
 extension ViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         return cell
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 3
     }
     
 }

 
 */

/*guard let sampleType = HKObjectType.quantityType(forIdentifier: .appleStandTime) else {return }
let date = Date() // current date or replace with a specific date
let calendar = Calendar.current
let startDate = calendar.startOfDay(for: date)
let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)

let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
//let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)


let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
    guard let result = result, let sum = result.sumQuantity() else {
        // Handle the error
        return
    }
    print("Inactive Hours: \(sum)")
}

healthStore.execute(query)*/

/* let objectTypes: Set<HKObjectType> = [
 HKObjectType.activitySummaryType()
]
let calendar = Calendar.autoupdatingCurrent

var dateComponents = calendar.dateComponents(
 [ .year, .month, .day ],
 from: Date()
)
dateComponents.calendar = calendar

let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
 
 guard let summaries = summaries, summaries.count > 0
 else {
     return
 }
 for summary in summaries{
     print(summary.appleStandHours)
 }
}*/
