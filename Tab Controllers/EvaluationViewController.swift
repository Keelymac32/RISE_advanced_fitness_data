//
//  EvaluationViewController.swift
//
//  Created by Keelyn McNamara on 10/6/22.
//

import UIKit
import SQLite3
import SwiftUI
import Charts

class EvaluationViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var RecoveryLabel: UILabel!
    @IBOutlet weak var IntensityLabel: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    var WeeklyRecovery: [Double] = []
    var WeeklyIntensities: [Double] = []
    var WeeklyStrains: [Double] = []
    var WeeklyDays: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshButton = UIButton()
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.titleLabel?.font = UIFont(name: "Apparat Heavy", size: 12)!
        refreshButton.frame = CGRect(x: 325, y: 95, width: 75, height: 25)
        refreshButton.layer.cornerRadius = 10
        view.addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        let dbclass = DB()
        dbclass.query()
        WeeklyDays = dbclass.setXAxis()
        WeeklyRecovery =  dbclass.weekQueryRecovery()
        WeeklyIntensities = dbclass.weekQueryIntensities()
        WeeklyStrains = dbclass.setStrainGraphs()
                
        print(WeeklyDays)
        print("Weekly Recovery:  \(WeeklyRecovery)")
        print("Weekly Strain: \(WeeklyStrains)")
        print("Weekly Intensities: \(WeeklyIntensities)")
        
        
    }
    
    @objc func buttonTapped(){
        self.viewDidLoad()
        self.viewDidLayoutSubviews()
        
     }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let scrollView = UIScrollView(frame: CGRect(x: 10, y: 150, width: Int(view.frame.size.width)-20, height: Int(view.frame.size.height)-100))
        
        
        scrollView.backgroundColor = .white
        view.addSubview(scrollView)
        
        
        scrollView.addSubview(createRecoveryChart())
        scrollView.addSubview(createStrainChart())
        scrollView.addSubview(CreateIntensityChart())
        
        scrollView.contentSize = CGSize(width: Int(view.frame.size.width)-20, height: 1450)
        
        let StrainLabel = UILabel(frame: CGRect(x: 0, y: 950, width: 300, height: 21))
        StrainLabel.textAlignment = .center
        StrainLabel.center = CGPoint(x: 180, y: 950)
        StrainLabel.text = ("Weekly Strain")
        StrainLabel.font = UIFont(name: "Apparat Heavy", size: 18)
        
        

        RecoveryLabel.text = "Weekly Recovery"
        IntensityLabel.frame(forAlignmentRect: CGRect(x: 160, y: 500, width: 100, height: 50))
        IntensityLabel.text = "Weekly Intensities"
        
        
        scrollView.addSubview(RecoveryLabel)
        scrollView.addSubview(IntensityLabel)
        scrollView.addSubview(StrainLabel)
        
        
    }
    
    
    func refreshPage(){
        viewDidLoad()
    }
        
    func createRecoveryChart() -> BarChartView{
        //create bar chart
        let barChart = BarChartView(frame: CGRect(x: 0, y: 50, width: (view.frame.size.width - 25), height: view.frame.size.width))
        
        //zoom view configs
        barChart.pinchZoomEnabled = false
        barChart.setScaleEnabled(false)
        barChart.doubleTapToZoomEnabled = false
        
        //config x
        print(WeeklyDays)
        let xAxis = barChart.xAxis
        xAxis.setLabelCount(WeeklyDays.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: WeeklyDays)
        xAxis.labelPosition = .bottom
        
        
        //config y axis
        let yAxis = barChart.leftAxis
        yAxis.axisMinimum = 0.0
        yAxis.axisMaximum = 105.0
        let rightAxis = barChart.rightAxis
        rightAxis.enabled = false
        
        //average Recovery
        var sum = 0.0
        for recovery in WeeklyRecovery {
            sum = sum + recovery}
        let average = round(sum/Double(WeeklyRecovery.count))
        //average line
        let AverageRecoveryLine = ChartLimitLine()
        AverageRecoveryLine.limit = average
        AverageRecoveryLine.label = "Average Recovery: \(average)%"
        AverageRecoveryLine.labelPosition = .leftBottom
        AverageRecoveryLine.lineColor = .blue
        yAxis.addLimitLine(AverageRecoveryLine)
        
        
        
        //supply data
        var entries = [BarChartDataEntry]()
        var xcount = 0.0
        for vals in WeeklyRecovery{
            entries.append(BarChartDataEntry(x:xcount, y: vals))
            xcount = xcount + 1
        }
        let set = BarChartDataSet(entries: entries, label: "Recovery")
        let data = BarChartData(dataSet: set)
        barChart.data = data
        return barChart
        
    }

    func createStrainChart() -> BarChartView{
        //create bar chart
        let barChart = BarChartView(frame: CGRect(x: 0, y: 960, width: (view.frame.size.width - 25), height: view.frame.size.width))
        
        //zoom view configs
        barChart.pinchZoomEnabled = false
        barChart.setScaleEnabled(false)
        barChart.doubleTapToZoomEnabled = false
        
        //config x
        let xAxis = barChart.xAxis
        xAxis.setLabelCount(WeeklyDays.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: WeeklyDays)
        xAxis.labelPosition = .bottom
        
        
        //config y axis
        let yAxis = barChart.leftAxis
        yAxis.axisMinimum = 0.0
        yAxis.axisMaximum = 10.0
        let rightAxis = barChart.rightAxis
        rightAxis.enabled = false
        
        //average Recovery
        var sum = 0.0
        for strain in WeeklyStrains {
            sum = sum + strain}
        let average = round(sum/Double(WeeklyStrains.count))
        
        //average line
        let AverageRecoveryLine = ChartLimitLine()
        AverageRecoveryLine.limit = average
        AverageRecoveryLine.label = "Average Recovery: \(average)%"
        AverageRecoveryLine.labelPosition = .leftBottom
        AverageRecoveryLine.lineColor = .cyan
        yAxis.addLimitLine(AverageRecoveryLine)
        
        
        
        //supply data
        var entries = [BarChartDataEntry]()
        var xcount = 0.0
        for vals in WeeklyStrains{
            entries.append(BarChartDataEntry(x:xcount, y: vals))
            xcount = xcount + 1
        }
        let set = BarChartDataSet(entries: entries, label: "Max Strain")
        let bluecolor = NSUIColor(red: (18.0/255.0), green: (106.0/255.0), blue: (210.0/255.0), alpha: 1)
        set.setColor(bluecolor)
        let data = BarChartData(dataSet: set)
        barChart.data = data
            
        return barChart
        
        //colordata
    }
    
    func CreateIntensityChart() -> LineChartView{
       
        //creating chart
        let chart = LineChartView(frame: CGRect(x: 0, y: 510, width: (view.frame.size.width-25), height: view.frame.size.width))
        
        
        var entries = [ChartDataEntry]()
        var xcount = 0.0
        xcount = 0
        for vals in WeeklyIntensities{
            entries.append(ChartDataEntry(x: xcount, y: vals))
            xcount = xcount + 1
        }
        
        let yAxis = chart.leftAxis
        yAxis.axisMinimum = 0.0
        yAxis.axisMaximum = 10.0
        
        let set = LineChartDataSet(entries: entries, label: "Workout Intensities")
        set.setColor(.blue)
        let data = LineChartData(dataSet: set)
        chart.data = data
        
        return chart
    }

    
    
}
