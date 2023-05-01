//
//  SleepHoursViewController.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 1/6/23.
//

import UIKit

class SleepHoursViewController: UIViewController {

    @IBOutlet weak var close: UIButton!
    
    @IBOutlet weak var bedTimePicker: UIDatePicker!
    
    @IBOutlet weak var wakeTimePicker: UIDatePicker!
    
    var timer = Timer()
    
    var tempBedTime = Date()
    var tempAwakeTime = Date()
    var tally = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if RecoveryCalc.wakeTime == Date(){
            setTimers()
        }
        else{
            update()
        }
        }
    
    var formattedBedTime: String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: bedTimePicker.date)
    }
    var formattedWakeTime: String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: wakeTimePicker.date)
    }
    
    
    func setTimers(){
        let rCalc = RecoveryCalc()
        rCalc.getsleep()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            self.tempAwakeTime = RecoveryCalc.wakeTime
            self.tempBedTime = RecoveryCalc.bedTime
            bedTimePicker.date = tempBedTime
            wakeTimePicker.date =  tempAwakeTime
        }
    }
    
    func update(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
            self.tempAwakeTime = RecoveryCalc.wakeTime
            self.tempBedTime = RecoveryCalc.bedTime
            bedTimePicker.date = tempBedTime
            wakeTimePicker.date =  tempAwakeTime
        }
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        NotificationCenter.default.post(name: .saveSleepHours, object: self)
        RecoveryCalc.bedTime =  bedTimePicker.date
        RecoveryCalc.wakeTime = wakeTimePicker.date
        print(RecoveryCalc.bedTime)
        print(RecoveryCalc.wakeTime)
        RecoveryCalc.findSleepHours(asleep: bedTimePicker.date , awake: wakeTimePicker.date)
        dismiss(animated: true)
    }
    
}

extension Notification.Name{
    static let saveSleepHours = Notification.Name(rawValue: "Sleep Hours")
}
