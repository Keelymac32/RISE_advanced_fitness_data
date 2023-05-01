
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
    
    static let healthStore = HKHealthStore()
    
    
    let database = DB()
    static var HeartRateGlobal = 0.0
    static var MaxHeartRateGlobal = 0.0
    static var RestingHeartRateGlobal = 0.0
    var workoutlist: [HKWorkout] = []
    static var intensitylist: [Double] = []
    var current: [Double] = []
    static var workoutNameList: [String] = []
    
    // Main driver method that set sup screen and calls other methods
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let refreshButton = UIButton()
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        view.addSubview(refreshButton)
        refreshButton.titleLabel?.font = UIFont(name: "Apparat Heavy", size: 12)!
        refreshButton.frame = CGRect(x: 300, y: 75, width: 75, height: 25)
        refreshButton.layer.cornerRadius = 10
        refreshButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
       
        
        
        
        IntensityViewController.calcMaxHeartRate()
        calcRestingHeartRate()
        calcHeartRate()// Updating global Heart Rate
        updateScreen() // Method call to update with health information
    }
    var timer = Timer()
    //updating screen with label of health data

   @objc func buttonTapped(){
       self.viewDidLoad()
    }
    
    
    func updateScreen(){
 
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
        
            
            
            label2.text = ((round(IntensityViewController.HeartRateGlobal * 10)/10.0).description)
            label3.text = (IntensityViewController.MaxHeartRateGlobal.description)
            label.text = (IntensityViewController.RestingHeartRateGlobal.description)
            
            self.view.addSubview(label)
            self.view.addSubview(label2)
            self.view.addSubview(label3)
        
            
            //print(self.intensitylist)
            //print("tick")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 8){ [self] in
            IntensityViewController.getWorkouts()
        }
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //tableView.reloadData()
        cell.backgroundColor = .white
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if IntensityViewController.intensitylist.isEmpty{
                cell.textLabel?.font = UIFont(name: "Apparat Heavy", size: 18)
                cell.textLabel?.text = ""
            }
            else if indexPath.row < IntensityViewController.intensitylist.endIndex{
                if IntensityViewController.intensitylist[indexPath.row] < 1 {
                    cell.backgroundColor = UIColor.init(red: 30/255, green: 144/255, blue: 1, alpha: 1)
                }
                else if IntensityViewController.intensitylist[indexPath.row] >= 1 && IntensityViewController.intensitylist[indexPath.row] < 3 {
                    cell.backgroundColor = UIColor.init(red: 24/255, green: 125/255, blue: 233/255, alpha: 1)
                    
                }
                else if IntensityViewController.intensitylist[indexPath.row] >= 3 && IntensityViewController.intensitylist[indexPath.row] < 5 {
                    cell.backgroundColor = UIColor.init(red: 18/255, green: 106/255, blue: 210/255, alpha: 1)
                    
                }
                else if IntensityViewController.intensitylist[indexPath.row] >= 5 && IntensityViewController.intensitylist[indexPath.row] < 7 {
                    cell.backgroundColor = UIColor.init(red: 12/255, green: 86/255, blue: 188/255, alpha: 1)
                    
                }
                else if IntensityViewController.intensitylist[indexPath.row] >= 7 && IntensityViewController.intensitylist[indexPath.row] < 9 {
                    cell.backgroundColor = UIColor.init(red: 6/255, green: 67/255, blue: 165/255, alpha: 1)}
                
                else{
                    cell.backgroundColor = UIColor.init(red: 0/255, green: 48/255, blue: 143/255, alpha: 1)}
                
                cell.textLabel?.font = UIFont(name: "Apparat Heavy", size: 20)
                cell.textLabel?.textColor = UIColor.white
                cell.textLabel?.text = ("\(IntensityViewController.workoutNameList[indexPath.row]): \(IntensityViewController.intensitylist[indexPath.row])")
                
            }
            
            else{
                cell.textLabel?.font = UIFont(name: "Apparat Heavy", size: 18)
                cell.textLabel?.text = ""}
            
            if IntensityViewController.intensitylist.elementsEqual(current) == false {
                print("Updating")
                updateDatebase(new: IntensityViewController.intensitylist)
                current = IntensityViewController.intensitylist}
        })
        return cell
    }


    func updateDatebase(new: [Double]){
        print("Updating Intensity List.....")
        database.updateIntensities(newInten: new)
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
        IntensityViewController.healthStore.execute(query)
    }
    
   static func calcMaxHeartRate()  {
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
        IntensityViewController.healthStore.execute(query)
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
                    IntensityViewController.RestingHeartRateGlobal = tempREST
                }
            }
            print("Resting Heart Rate \(tempREST) BPM")
        }
        IntensityViewController.healthStore.execute(queryResting)
    }
    
    static func getWorkouts(){
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
            let WICalc = IntensityCalc(workoutList: result!, Resting: RestingHeartRateGlobal, Max: self.MaxHeartRateGlobal)
            //Calculates Workout Intensity
            WICalc.calculate()
            //Waits for Workout Intensity List to Be Updated
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                IntensityViewController.intensitylist = WICalc.getWorkoutIntensities() //updating local intensity list with list from intensity calculation class
                IntensityViewController.workoutNameList = WICalc.getWorkoutName()
                
            }
        }
        healthStore.execute(workoutQuery)
    }
    
    //updates Global Variable for HR with Current Heart Rate
        func getHeartRate(HeartRate: Double){
            IntensityViewController.HeartRateGlobal = HeartRate
        }
       static func getMAXHeartRate(HeartRate: Double){
            IntensityViewController.MaxHeartRateGlobal = HeartRate
        }
        func getRestingHeartRate(HeartRate: Double){
            IntensityViewController.RestingHeartRateGlobal = HeartRate
        }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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
