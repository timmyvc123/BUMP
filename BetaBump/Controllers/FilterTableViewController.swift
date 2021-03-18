//
//  FilterTableViewController.swift
//  BetaBump
//
//  Created by Timmy Van Cauwenberge on 3/18/21.
//

import UIKit
import MultiSlider

class FilterTableViewController: UITableViewController {

    @IBOutlet weak var streamCountSlider: MultiSlider!
    @IBOutlet weak var releaseDateSlider: MultiSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.layer.cornerRadius = 35
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        sliderConfiguration()

    }
    
    func sliderConfiguration() {
        
        // setting up sliders
        streamCountSlider.distanceBetweenThumbs = 0
        
        streamCountSlider.trackWidth = 6
        streamCountSlider.thumbCount = 2
        streamCountSlider.snapStepSize = 0.5
        streamCountSlider.valueLabelPosition = .top
        streamCountSlider.isValueLabelRelative = false
        streamCountSlider.valueLabelFormatter.positiveSuffix = " k"
        streamCountSlider.tintColor = UIColor(named: "backgroundColor")
        streamCountSlider.valueLabelFont = UIFont.boldSystemFont(ofSize: 16)
        
        releaseDateSlider.trackWidth = 6
        releaseDateSlider.thumbCount = 2
        releaseDateSlider.snapStepSize = 1
        releaseDateSlider.valueLabelPosition = .top
        releaseDateSlider.isValueLabelRelative = false
        releaseDateSlider.valueLabelFormatter.positiveSuffix = " Days"
        releaseDateSlider.tintColor = UIColor(named: "backgroundColor")
        releaseDateSlider.valueLabelFont = UIFont.boldSystemFont(ofSize: 16)
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//
//         Configure the cell...
//
//        return cell
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
