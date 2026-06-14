//
//  CommunityRequestController.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 19/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import UIKit
import Toast_Swift
import ZKProgressHUD


class CommunityRequestController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var communityNameField: RoundTextField!
    @IBOutlet weak var countryField: RoundTextField!
    @IBOutlet weak var stateField: RoundTextField!
    @IBOutlet weak var lgaField: RoundTextField!
    @IBOutlet weak var aboutField: RoundTextField!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var publicView: DesignView!
    @IBOutlet weak var privateView: DesignView!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    //@IBOutlet weak var describeLbl: UILabel!
    //@IBOutlet weak var communityDescLbl: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet var navView: UIView!
    @IBOutlet weak var designView1: DesignView!
    @IBOutlet weak var designView2: DesignView!
    
    let status = Reach().connectionStatus()
    var delegate : RequestCommunityDelegate!
    var privacy = 0
    var isHome = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        self.publicView.backgroundColor = .white
        self.privateView.backgroundColor = .white
        //self.categoryField.inputView = UIView()
        self.requestLabel.text = NSLocalizedString("Request Community", comment: "Request Community")
        self.sendBtn.setTitle(NSLocalizedString("Send", comment: "Send"), for: .normal)
        //self.describeLbl.text = NSLocalizedString("Describe Your Community", comment: "Describe Your Community")
        //self.communityDescLbl.text = NSLocalizedString("Tell pontentials members what your communities about to help them know whether its relevant to them", comment: "Tell pontentials members what your communities about to help them know whether its relevant to them")
        self.privacyLabel.text = NSLocalizedString("Privacy", comment: "Privacy")
        self.communityNameField.placeholder = NSLocalizedString("Community Name", comment: "Community Name")
        self.countryField.placeholder = NSLocalizedString("Country", comment: "Country")
        self.aboutField.placeholder = NSLocalizedString("Description", comment: "Description")
        self.stateField.placeholder = NSLocalizedString("State", comment: "State")
        self.lgaField.placeholder = NSLocalizedString("LGA", comment: "LGA")
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.designView1.borderColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.designView2.borderColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
 
    }
    override func viewWillAppear(_ animated: Bool) {
//        self.categoryField.inputView = UIView()
    }
    
    
    /// Network Connectivity
      @objc func networkStatusChanged(_ notification: Notification) {
          if let userInfo = notification.userInfo {
              let status = userInfo["Status"] as! String
              print("Status",status)
          }
      }
    
    private func sendRequest() {
        switch status {
        case .unknown, .offline:
            showAlert(title: "", message: "Internet Connection Failed")
        case .online(.wwan),.online(.wiFi):
            ZKProgressHUD.show()
       performUIUpdatesOnMain {
                
           CommunityManager.sharedInstance.requestCommunity(name: self.communityNameField.text!, country: self.countryField.text!, state: self.stateField.text!, lga: self.lgaField.text!, about: self.aboutField.text!, privacy: self.privacy) { (success, authError, error) in
        if success != nil {
            print(success!.community_data)
            let communityData = (success!.community_data)
            print(communityData)
            ZKProgressHUD.dismiss()
            //if self.isHome == 0{
                //self.delegate.sendCommunityData(communityData: communityData)
            //}
            self.view.makeToast("Community Request Submitted")
            self.communityNameField.text = NSLocalizedString("", comment: "")
            self.countryField.text = NSLocalizedString("", comment: "")
            self.aboutField.text = NSLocalizedString("", comment: "")
            self.stateField.text = NSLocalizedString("", comment: "")
            self.lgaField.text = NSLocalizedString("", comment: "")
            self.privacy = 0
            //self.dismiss(animated: true, completion: nil)
        }
        else if authError != nil {
            ZKProgressHUD.dismiss()
            self.view.makeToast(authError?.errors.errorText)
//            if authError?.errors.errorText == "Invalid group name characters"{
//                self.view.makeToast("Invalid group URL")
//            }
//            else{
//                self.view.makeToast(authError?.errors.errorText)
//            }
                }
            else {
                ZKProgressHUD.dismiss()
                print(error?.localizedDescription)
                }
            }
        }
    }
        
        
    }
    
    @IBAction func Public(_ sender: Any) {
        self.publicView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.privateView.backgroundColor = .white
        self.privacy = 1
        
    }
    
    @IBAction func Private(_ sender: Any) {
        self.publicView.backgroundColor = .white
        self.privateView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.privacy = 2
    }
    
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Send(_ sender: Any) {
        if (self.communityNameField.text?.isEmpty == true) {
            self.view.makeToast(NSLocalizedString("Enter Commmunity Name", comment: "Enter Community Name"))
        }
        else if (self.countryField.text?.isEmpty == true) {
            self.view.makeToast(NSLocalizedString("Enter Community Country", comment: "Enter Community Country"))
        }
        else if (self.countryField.text?.isEmpty == true) {
            self.view.makeToast(NSLocalizedString("Enter Community State", comment: "Enter State Country"))
        }
        else if (self.countryField.text?.isEmpty == true) {
            self.view.makeToast(NSLocalizedString("Enter Community LGA", comment: "Enter Community LGA"))
        }
        else if (self.aboutField.text?.isEmpty == true) {
            self.view.makeToast(NSLocalizedString("Enter Community Description", comment: "Enter Community Description"))
        }
        else if (self.privacy == 0) {
            self.view.makeToast(NSLocalizedString("Select Community Privacy", comment: "Select Community Privacy"))
        }
        else {
            self.sendRequest()
        }
        
    }
    
}
