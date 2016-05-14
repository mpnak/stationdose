//
//  EnergyChartViewController.swift
//  Stationdose
//
//  Created by Hoof on 4/29/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit
import Charts

class EnergyChartViewController: UIViewController {

    weak var station: Station?
    var plottedChartView: LineChartView?
    var chartView: UIImageView?
    var chartName: String? {
        didSet {
            chartView?.image = UIImage(named: chartName!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()
//        chartView = LineChartView(frame: self.view.frame)
        chartView = UIImageView(frame: self.view.frame)
        chartView?.backgroundColor = UIColor.clearColor()
        self.view.addSubview(chartView!)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupChart () {
        
        if plottedChartView != nil {
            var energyValues: [Double] = []
            if station != nil && station?.tracks?.count > 0 {
                for track in station!.tracks! {
                    if track.energy != nil {
                        energyValues.append(Double(track.energy!)!)
                    }
                }
            }
            
            var dataEntries: [ChartDataEntry] = []
            
            var xIndices: [Int] = []
            for i in 0..<energyValues.count {
                let dataEntry = ChartDataEntry(value: energyValues[i], xIndex: i)
                dataEntries.append(dataEntry)
                xIndices.append(i)
            }
            
            let left = plottedChartView!.getAxis(ChartYAxis.AxisDependency.Left)
            left.axisMaxValue = 1.5
            left.axisMinValue = 0.0
            left.granularity = 0.05
            left.drawLabelsEnabled = false
            left.drawGridLinesEnabled = true
            
            let right = plottedChartView!.xAxis
            right.drawLabelsEnabled = false
            right.drawGridLinesEnabled = false
            
            let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Energy")
            chartDataSet.setColor(UIColor.blackColor())
            chartDataSet.drawValuesEnabled = false
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.fillAlpha = 1.0
            chartDataSet.drawFilledEnabled = true
            
            //        let c1 = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1).CGColor
            //        let c2 = UIColor(red: 0, green: 1.0, blue: 0, alpha: 1).CGColor
            let topColor = UIColor.yellowColor().CGColor
            let botColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1).CGColor
            
            let gradientColors = [botColor, topColor]
            let colorLocations:[CGFloat] = [0.0, 0.5]
            if let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), gradientColors, colorLocations) {
                chartDataSet.fill = ChartFill(linearGradient: gradient, angle: 90.0)
            }
            
            let chartData = LineChartData(xVals: xIndices, dataSet: chartDataSet)
            plottedChartView!.scaleXEnabled = false
            plottedChartView!.scaleYEnabled = false
            plottedChartView!.dragEnabled = false
            plottedChartView!.descriptionText = ""
            plottedChartView!.legend.enabled = false
            plottedChartView!.userInteractionEnabled = false
            plottedChartView!.data = chartData
            
            let handler = plottedChartView!.viewPortHandler
            handler.fitScreen()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
