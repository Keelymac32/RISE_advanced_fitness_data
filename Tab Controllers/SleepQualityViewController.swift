//
//  SleepQualityViewController.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 12/8/22.
//

import UIKit

class SleepQualityViewController: UIViewController {
    
    @IBOutlet var sleepPicker: UIPickerView!
    
    @IBOutlet weak var setButton: UIButton!
    
    let data = ["10","9","8","7","6","5","4","3","2","1"]
    var savedPercentage = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sleepPicker.dataSource = self
        sleepPicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func saveValue(percentage: Int) {
        savedPercentage = (percentage)
    }

    func getValue() -> Int{
        return savedPercentage
    }
    
    @IBAction func close(_ sender: Any) {
        NotificationCenter.default.post(name: .saveSleepQuality, object: self)
        dismiss(animated: true)
    }
    
    
    
}
extension SleepQualityViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
}
extension SleepQualityViewController: UIPickerViewDelegate{
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->
    String? {
        return data[row]
    }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let selected = data[row]
         print(selected)
        let x = Int(selected)! * 10
       saveValue(percentage: x)
        print(x)
     }
}

extension Notification.Name{
    static let saveSleepQuality = Notification.Name(rawValue: "Sleep Quality")
}
