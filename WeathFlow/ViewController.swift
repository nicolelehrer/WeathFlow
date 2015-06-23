//
//  ViewController.swift
//  WeathFlow
//
//  Created by Nicole Lehrer on 6/18/15.
//  With Ashoka Finley
//  help from here https://github.com/Mav3r1ck/Project-RainMan for JSON serialization call

import UIKit

var tableDataArray:NSMutableArray = NSMutableArray()

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var refresh: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var dataObject:AnyObject?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println(dataObject)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.topItem?.title = dataObject as? String
        
        
        getData() //should this go in view will appear
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        println("refresh")
        getData()
        tableView.reloadData()
    }
    func getData() -> Void {
        
        //our NYC location
        let newLat = 40.72064946516691;
        let newLong = -74.00090719773694;
        let apiKey = "1542cc219421383b659cf3e591de2d31"
        
        let userLocation = "\(newLat),\(newLong)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        
        let forecastType = dataObject as! String
        
        
        let forecastURL:NSURL
        if forecastType == "yesterday"{
            let calendar = NSCalendar.currentCalendar()
            let yesterday:NSDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: NSDate(), options: nil)!
            let aTime = Int(yesterday.timeIntervalSince1970) //need to convert to whole number assuming - didn't work as decimal
            println(aTime)
             forecastURL = NSURL(string: "\(userLocation),\(aTime)", relativeToURL:baseURL)!
        }
        else{
             forecastURL = NSURL(string: "\(userLocation)", relativeToURL:baseURL)!
        }
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                
                let nsDataObject = NSData(contentsOfURL: location)
                
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(nsDataObject!, options: nil, error: nil) as! NSDictionary
                
                
                if  weatherDictionary["hourly"] == nil{
//                    println("weatherDictionar with hourly key is nil")
//                    println("weatherDictionar all keys: %@", weatherDictionary.allKeys)

                    return
                }
                
                
                let hourlyDict:NSDictionary = weatherDictionary["hourly"] as! NSDictionary
                //    println("all keys: %@", hourlyDict.allKeys)
                let dataPerHourArray:AnyObject = hourlyDict["data"]! //gives you temp and other things

                println("dataPerHourArray count is \(dataPerHourArray.count)")
                
                let numHours:Int
                var startHour:Int
                
                if forecastType == "tomorrow"{
                    startHour = 24
                    numHours = 48
                }
                else { //yesterday is only 24 long, today only want first 24
                    startHour = 0
                    numHours = 24
                }
                
                tableDataArray.removeAllObjects()
                println("count for table array after clear is \(tableDataArray.count)")
                
                for(var hour:Int = startHour; hour < numHours; hour++){
                    let hourDataDict:NSDictionary = dataPerHourArray[hour] as! NSDictionary
                    
                    //we are interested in temperature and time
                    let tempKey = "temperature" //can't parse quotes directly inside dictionary key so store in var
                    let tempWholeNum = hourDataDict[tempKey] as! Int
                    let tempWithDegree = "\(tempWholeNum)" + "\u{00B0}"
                    
                    let timeKey = "time"
                    let timeInterval:NSTimeInterval = hourDataDict[timeKey] as! NSTimeInterval
                    let formatter = NSDateFormatter()
                    formatter.timeStyle = .ShortStyle
                    formatter.timeZone = NSTimeZone.localTimeZone()

                    let tableCellTitle = formatter.stringFromDate(NSDate(timeIntervalSince1970:timeInterval)) + " : \(tempWithDegree)"
                    //println(tableCellTitle)
                    tableDataArray.addObject(tableCellTitle)
                    
                }
                
                println("tableArray is length \(tableDataArray.count)")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
            } else {
                println(error) //not tested yet
            }
            
        })
        downloadTask.resume()
  
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        var text:String = tableDataArray[indexPath.row] as! String
        cell.textLabel?.text =  text
        let redShade = 0.05*CGFloat(indexPath.row)
        let greenShade = 1.0-redShade
        cell.backgroundColor = UIColor(red: redShade, green: greenShade, blue: 1.0, alpha: 1.0)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tableDataArray.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
 
}


