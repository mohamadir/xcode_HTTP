//
//  ScrollViewController.swift
//  ISHPullUpSample
//
//  Created by Felix Lamouroux on 25.06.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

import UIKit
import ISHPullUp
import MapKit
import SwiftEventBus

class BottomVC: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var countArray : Int = 0
    var filterDaysArray : [Bool] = []
    var planDyas : PlanDays?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var filterView: ISHPullUpRoundedVisualEffectView!
    @IBOutlet private weak var handleView: ISHPullUpHandleView!
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var buttonLock: UIButton?
    @IBOutlet weak var contsrateFilter: NSLayoutConstraint!
    @IBOutlet weak var filterHeight: UIView!
    
    private var firstAppearanceCompleted = false
    weak var pullUpController: ISHPullUpViewController!
    
    // we allow the pullUp to snap to the half way point
    private var halfWayPoint = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("im in botom")
        //insertFilter removeFilter
        tableView.delegate = self
        tableView.dataSource = self
        SwiftEventBus.onMainThread(self, name: "removeFilter") { result in
            print("ime here in remove")
            self.contsrateFilter.constant = 0
            self.filterView.isHidden = true
        }
        SwiftEventBus.onMainThread(self, name: "insertFilter") { result in
            self.planDyas = result?.object as! PlanDays
            if  self.planDyas != nil {
                self.countArray =  (self.planDyas?.days!.count)!
                self.filterDaysArray =  [Bool](repeating: true, count: self.countArray)
                self.tableView.reloadData()
            }
            //print("ime here in insert \( self.planDyas)")
            self.contsrateFilter.constant = 35
            self.filterView.isHidden = false
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        topView.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true;
    }

    @objc private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {
        if pullUpController.isLocked {
            return
        }

        pullUpController.toggleState(animated: true)
    }

    @IBAction private func buttonTappedLearnMore(_ sender: AnyObject) {
        // for demo purposes we replace the bottomViewController with a web view controller
        // there is no way back in the sample app though
        // This also highlights the behaviour of the pullup view controller without a sizing and state delegate
        let webVC = WebViewController()
        webVC.loadURL(URL(string: "https://iosphere.de")!)
        pullUpController.bottomViewController = webVC
    }

    @IBAction private func buttonTappedLock(_ sender: AnyObject) {
        pullUpController.isLocked  = !pullUpController.isLocked
        buttonLock?.setTitle(pullUpController.isLocked ? "Unlock" : "Lock", for: .normal)
    }

    // MARK: ISHPullUpSizingDelegate

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        let totalHeight = rootView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here 
        // and perform the snapping in ..targetHeightForBottomViewController..
        halfWayPoint = totalHeight / 2.0
        return totalHeight
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        return topView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height;
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        // if around 30pt of the half way point -> snap to it
        if abs(height - halfWayPoint) < 30 {
            
            return halfWayPoint
        }
        
        // default behaviour
        return height
    }

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        // we update the scroll view's content inset 
        // to properly support scrolling in the intermediate states
        scrollView.contentInset = edgeInsets;
    }

    // MARK: ISHPullUpStateDelegate

    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        topLabel.text = textForState(state);
        handleView.setState(ISHPullUpHandleView.handleState(for: state), animated: firstAppearanceCompleted)

        // Hide the scrollview in the collapsed state to avoid collision
        // with the soft home button on iPhone X
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.scrollView.alpha = (state == .collapsed) ? 0 : 1;
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countArray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.selectionStyle = .none
        if self.planDyas != nil {
            var dayNumber : Int = indexPath.row + 1
            cell.dayNumber.text = "Day \(dayNumber)"
            cell.daySwitch.isOn = self.filterDaysArray[indexPath.row]
            cell.daySwitch.tag = indexPath.row // for detect which row switch Changed
            cell.daySwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.daySwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        return cell
    }
    @objc func switchChanged(_ sender : UISwitch!){
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        self.filterDaysArray[sender.tag] = !self.filterDaysArray[sender.tag]
        
    }

    @IBAction func filterClick(_ sender: Any) {
        SwiftEventBus.post("daysFilter", sender : self.filterDaysArray)
        pullUpController.toggleState(animated: true)
    }
    private func textForState(_ state: ISHPullUpState) -> String {
        switch state {
        case .collapsed:
            return "Drag up or tap"
        case .intermediate:
            return "Intermediate"
        case .dragging:
            return "Hold on"
        case .expanded:
            return "Drag down or tap"
        }
    }
}

class ModalViewController: UIViewController {

    @IBAction func buttonTappedDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
