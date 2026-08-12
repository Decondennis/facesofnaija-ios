//
//  RegisterVC.swift
//  WoWonderiOS
//
//  Created by Muhammad Haris Butt on 5/25/21.
//  Copyright © 2021 clines329. All rights reserved.
//

import UIKit
import ZKProgressHUD

class RegisterVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    var error = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.11, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.11, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = .white
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.title = NSLocalizedString("Register", comment: "Register")
        print("OneSignal device id = \(self.oneSignalID ?? "")")
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpController.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
    }
    
    @objc private func backAction(){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupUI(){
        self.tableView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.11, alpha: 1.0)
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "RegisterTableItem", bundle: nil), forCellReuseIdentifier: "RegisterTableItem")
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let status = userInfo["Status"] as! String
            print(status)
        }
    }
    
    func showErrorPopup(error:String){
        let vc = R.storyboard.authentication.securityController()
        vc?.error = error
        self.present(vc!, animated: true, completion: nil)
    }
    
    func Register() {
        
        guard let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? RegisterTableItem else { return }
        if cell.usernameTextField.text?.isEmpty == true {
            self.error = NSLocalizedString("Error, Required Username", comment: "Error, Required Username")
            self.showErrorPopup(error: self.error)
        }
        
        else if cell.firstnameTextField.text?.isEmpty == true{
            self.error = NSLocalizedString("Error, Required FirstName", comment: "Error, Required FirstName")
            self.showErrorPopup(error: self.error)
        }
        else if cell.lastnameTextField.text?.isEmpty == true{
            self.error = NSLocalizedString("Error, Required LastName", comment: "Error, Required LastName")
            self.showErrorPopup(error: self.error)
        }
        else if cell.emailTextField.text?.isEmpty == true{
            self.error = NSLocalizedString("Error, Required Email", comment: "Error, Required Email")
            self.showErrorPopup(error: self.error)
        }
        else if cell.passwordTextField.text?.isEmpty == true{
            self.error = NSLocalizedString("Error, Required Password", comment: "Error, Required Password")
            self.showErrorPopup(error: self.error)
        }
        else if cell.confrimPassTextField.text?.isEmpty == true{
            self.error = NSLocalizedString("Error, Required ConfirmPassword", comment: "Error, Required ConfirmPassword")
            self.showErrorPopup(error: self.error)
        }
        else {
            ZKProgressHUD.show(NSLocalizedString("Loading", comment: "Loading"))
            let gender = cell.genderTextField.text ?? ""
            self.signUPAuthentication(userName: cell.usernameTextField.text!, email: cell.emailTextField.text!, password: cell.passwordTextField.text!, confirmPassword: cell.confrimPassTextField.text!, deviceID: self.oneSignalID ?? "", gender: gender)
        }
        
    }
    
    private func updateUserData(){
        guard let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? RegisterTableItem else { return }
        let birthday = cell.birthdayTextField.text ?? ""
        UpdateUserDataManager.sharedInstance.updateUserData(firstName: cell.firstnameTextField.text!, lastName: cell.lastnameTextField.text!, phoneNumber: "", website: "", address: "", workPlace: "", school: "", gender: cell.genderTextField.text ?? "male", birthday: birthday) { (success,authError , error) in
            if success != nil{
                print(success?.message)
            }
            else if authError != nil {
                print(authError?.errors.errorText)
            }
            else if error != nil{
                print(error?.localizedDescription)
            }
        }
       
    }

    private func signUPAuthentication(userName : String,email : String, password : String,confirmPassword : String,deviceID:String,gender:String) {
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            ZKProgressHUD.dismiss()
            self.error = NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed")
            self.showErrorPopup(error: self.error)
        case .online(.wwan), .online(.wiFi):
            
            AuthenticationManager.sharedInstance.signUPAuthentication(userName: userName, password: password, email: email, confirmPassword: confirmPassword,deviceId:deviceID, gender:gender) { (success, authError, error) in
                if success != nil {
                    ZKProgressHUD.dismiss()
                    if success?.apiStatus == 220 || (success?.accessToken ?? "").isEmpty {
                        self.error = NSLocalizedString("Registration successful! Please check your email to verify your account.", comment: "")
                        self.showErrorPopup(error: self.error)
                        return
                    }
                    UserData.setUSER_ID(success?.userID)
                    UserData.setaccess_token(success?.accessToken)
                    self.updateUserData()
                    AppInstance.instance.getProfile()
                    let vc = R.storyboard.authentication.introController()
                    vc?.modalPresentationStyle = .fullScreen
                    self.present(vc!, animated: true, completion: nil)
                    print("SignUp Succesfull")
                }
                else if authError != nil {
                    ZKProgressHUD.dismiss()
                    self.error = authError?.errors.errorText ?? ""
                    self.showErrorPopup(error: self.error)
                    print(authError?.errors.errorText)
                    
                }
        
                else if error != nil {
                    ZKProgressHUD.dismiss()
                    print("error")
                }
            }
        }
    }
    
    
    
    
}

extension RegisterVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterTableItem" ) as? RegisterTableItem
        cell!.vc = self
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 980.0
        
    }
    
}
