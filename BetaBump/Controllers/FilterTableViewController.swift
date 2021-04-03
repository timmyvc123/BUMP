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
        streamCountSlider.snapStepSize = 1
        streamCountSlider.valueLabelPosition = .top
        streamCountSlider.isValueLabelRelative = false
//        streamCountSlider.valueLabelFormatter.positiveSuffix = " k"
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

}
