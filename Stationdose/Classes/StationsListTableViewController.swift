//
//  StationsListTableViewController.swift
//  Stationdose
//
//  Created by Hoof on 5/3/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit

let IDENTIFIER = "StationsListCell"

protocol StationCellDelegate {
    func savePressed(sender: StationsListTableViewCell?)
    func removePressed(sender: StationsListTableViewCell?)
}

class StationsListTableViewController: UITableViewController, StationCellDelegate {

    weak var parentController: HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.separatorStyle = .None
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 104.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        if parentController?.stationsList != nil {
//            return parentController!.stationsList.count
//        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if parentController?.stationsList != nil {
            return parentController!.stationsList.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:StationsListTableViewCell = tableView.dequeueReusableCellWithIdentifier(IDENTIFIER) as! StationsListTableViewCell
        
        if let station = parentController?.stationsList[indexPath.row] {
            cell.station = station
            cell.titleLabel.text = station.name
            cell.shortDescriptionLabel.text = station.shortDescription
            if let sponsoredUrl = station.art {
                let URL = NSURL(string: sponsoredUrl)!
                cell.coverImageView.af_setImageWithURL(URL, placeholderImage: UIImage(named: "stations-list-placeholder"))
            } else {
                cell.coverImageView.image = UIImage(named: "stations-list-placeholder")
            }
            cell.savedImageView.alpha = 0
            cell.saveButton.alpha = 1
            cell.removeButton.alpha = 0
            for savedStation in parentController!.myStations {
                if savedStation.id == station.id {
                    cell.savedImageView.alpha = 1
                    cell.saveButton.alpha = 0
                    cell.removeButton.alpha = 1
                    break
                }
            }
            
            cell.backgroundColor = UIColor.clearColor()
            cell.removedMessageView?.alpha = 0
            cell.addedMessageView?.alpha = 0
            
            cell.touchUpInsideAction = {
                if self.parentController != nil {
                    self.parentController!.selectedStation = self.parentController!.stationsList[indexPath.row]
                    self.parentController!.showStationAtIndexPath(indexPath)
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    cell.setSelected(false, animated: true)
                }
            }
            cell.buttonDelegate = self
        }
        
        return cell
    }
    
    func savePressed(sender: StationsListTableViewCell?) {
        if let cell = sender {
            
            ModelManager.sharedInstance.saveStation(cell.station, onCompletion: { (success, savedStation) -> Void in
                if success {
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        cell.addedMessageView?.alpha = 1
                        }, completion: { (_) -> Void in
                            UIView.animateWithDuration(0.1, delay: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                                cell.addedMessageView?.alpha = 0
                                }, completion:{ (finished) in
                                    if self.parentController != nil {
                                        self.parentController!.reloadPlaylists(false)
                                    }
                            })
                    })
                    
                    cell.saveButton.alpha = 0
                    cell.removeButton.alpha = 1
                    cell.savedImageView.alpha = 1
                }
            })
        }
    }
    
    func removePressed(sender: StationsListTableViewCell?) {
        if let cell = sender {
            if self.parentController != nil {
                let myStations = parentController?.myStations
                let savedStationsToRemove = myStations!.filter { $0.id == cell.station.id}
                
                if let first = savedStationsToRemove.first {
                    ModelManager.sharedInstance.removeSavedStation(first) { (removed) -> Void in
                        if removed {
                            cell.saveButton.alpha = 1
                            cell.removeButton.alpha = 0
                            cell.savedImageView.alpha = 0
                            
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                cell.removedMessageView?.alpha = 1
                            }, completion: { (_) -> Void in
                                UIView.animateWithDuration(0.1, delay: 1.0, options: .CurveEaseInOut, animations: { () -> Void in
                                    cell.removedMessageView?.alpha = 0
                                }, completion: { (finished) in
                                    if self.parentController != nil {
                                        self.parentController!.reloadPlaylists(false)
                                    }
                                })
                            })
                            
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if parentController != nil {
            parentController!.selectedStation = parentController!.stationsList[indexPath.row]
            parentController!.showStationAtIndexPath(indexPath)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
