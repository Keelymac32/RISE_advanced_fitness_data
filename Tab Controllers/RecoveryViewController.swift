//
//  IntensityViewController.swift
//
//  Created by Keelyn McNamara on 10/6/22.
//

import UIKit
import HealthKit
import SwiftUI
import Foundation

class RecoveryViewController: UIViewController {
    
    let healthStore = HKHealthStore()
    
    @IBOutlet weak var recoveryLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var sleepLabel: UILabel!
    var percentage = 100
    var decimal = 0.1
    static var recoveryFinal = 100.0
    
    var timer = Timer()
    
    let database = DB()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkHealthDataAvailable()
       
        NotificationCenter.default.addObserver(self, selector: #selector(handleSleepQualityClosing), name: .saveSleepQuality, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSleepHourClosing), name: .saveSleepHours, object: nil)
        startRecoveryCalc()
    
        if database.exists() == false{
          print("Creating a new record")
          database.insert(date: Date(), recovery: 0.0, intensities: [], strain: 0.0)
        }
        
        let refreshButton = UIButton()
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        view.addSubview(refreshButton)
        refreshButton.titleLabel?.font = UIFont(name: "Apparat Heavy", size: 12)!
        refreshButton.frame = CGRect(x: 300, y: 75, width: 75, height: 25)
        refreshButton.layer.cornerRadius = 10
        refreshButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        self.viewDidLoad()
     }
    
    func startRecoveryCalc(){
        let rCalc = RecoveryCalc()
        rCalc.getsleep()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            
            hoursLabel.text = ("\(RecoveryCalc.intHoursSlept) hrs \(RecoveryCalc.minutesSlept) mins")
            self.view.addSubview(hoursLabel)
            
            recoveryLabel.text = ("\(calculateFinalRecovery(percent: Double(percentage), Hours: RecoveryCalc.hoursSlept).description)%")
                       
            decimal = calculateFinalRecovery(percent: Double(percentage), Hours: RecoveryCalc.hoursSlept) / 100.00
            
            var currentRecovery = (decimal * 100.00)
            
            if currentRecovery != RecoveryViewController.recoveryFinal{
                print("Updating Recovery... with \(currentRecovery)")
                updateDataBase(new: currentRecovery)
                RecoveryViewController.recoveryFinal = currentRecovery
            }
                      
            buildRect(percentage: decimal)
        })
        
        
    }
    
    func updateDataBase(new: Double){
        
        database.updateRecovery(newRec: new)
    }
    
    
    @objc func handleSleepQualityClosing(notificiation: Notification){
        let sleepQualVC = notificiation.object as! SleepQualityViewController
        sleepLabel.text = (String(sleepQualVC.getValue()) + "%")
        percentage = sleepQualVC.getValue()
    }
    
    @objc func handleSleepHourClosing(notificiation: Notification){
        let sleepHourVC = notificiation.object as! SleepHoursViewController
        
        
    }
    
    func checkHealthDataAvailable() {
        print("Checking if Health Data is Available....")
        
        if HKHealthStore.isHealthDataAvailable() {
            print("YES HEALTH DATA IS AVAILABLE")
            authorizeHealthKit()} //Requesting to authorize specific types of data being used
        
        else {print("NO HEALTH DATA NOT AVAILABLE")
            //Pop up message to notify user their app isn't supported
            let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Alert") as! AlertViewController
            self.addChild(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParent: self)}
    }
    
    
    //function that authorizes use of workouts and heart rate data
    func authorizeHealthKit(){
        print("Authorizing Health Kit.....")
        let read = Set(
            [HKObjectType.quantityType(forIdentifier: .heartRate)!,
             HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
             HKSeriesType.activitySummaryType(),
             HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
             HKCategoryType(.sleepAnalysis),
             HKSeriesType.workoutType(),
            ])
        //let share: Set<HKSampleType> = []
        
        self.healthStore.requestAuthorization(toShare: nil, read: read) { (success, error) in
            if !success {
                print("ERROR With Authorizing Health Kit")
                return
            }
            else{
                print("Health Kit is Authorized.")}
        }
    }
    
    func calculateFinalRecovery(percent: Double, Hours: Double) -> Double{
        let percentMultiplier = (percent / 100)
        let doubleFinal = ((Hours * percentMultiplier)/8.0)
        var final = doubleFinal * 100.00
        final = (final * 100).rounded() / 100
        if final > 100{
            final = 100
        }
        else if final < 0 {
            final = 0
        }
        return final
    }
    
    
    
    
    func buildRect(percentage: Double){
        
        let height = -(400 * percentage)
        let rectFrame: CGRect = CGRect(x:CGFloat(155), y:CGFloat(765), width:CGFloat(100), height:CGFloat(height))
                // Create a UIView object which use above CGRect object.
                let blueRectView = UIView(frame: rectFrame)
                // Set UIView background color.
                //blueRectView.backgroundColor = UIColor.blue
                blueRectView.layer.addSublayer(gradientLayer)
                gradientLayer.frame = blueRectView.bounds
        
        
                // Add above UIView object as the main view's subview.
                self.view.addSubview(blueRectView)
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



