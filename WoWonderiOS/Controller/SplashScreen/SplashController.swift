//
//  SplashController.swift
//  WoWonderiOS
//
//  Created by Ubaid Javaid on 2/18/21.
//  Copyright © 2021 clines329. All rights reserved.
//

import UIKit

class SplashController: UIViewController {
    
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let status = Reach().connectionStatus()
    private var hasNavigated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startAnimating()
        
        // Add timeout - navigate after 5 seconds regardless of API responses
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.navigateToMainScreen()
        }
        
        self.getNewsFeed()
        self.getSuggestedUsers()
        self.getSuggestedGroups()
        self.getMyPages()
        self.getmyGroups()
    }
    
    private func navigateToMainScreen() {
        guard !hasNavigated else { return }
        hasNavigated = true
        
        self.activityIndicator.stopAnimating()
        let StoryBoards = UIStoryboard(name: "Main", bundle: nil)
        let vc = StoryBoards.instantiateViewController(withIdentifier: "TabbarVC")
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    

    
    private func getNewsFeed () {
        switch status {
        case .unknown, .offline:
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
            self.view.isUserInteractionEnabled = true
            navigateToMainScreen()
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                GetNewsFeedManagers.sharedInstance.get_News_Feed(filter: 1, access_token: "\("?")\("access_token")\("=")\(UserData.getAccess_Token() ?? "")", limit: 15, off_set: "") {[weak self] (success, authError, error) in
                    if success != nil {
                        for i in success!.data{
                            AppInstance.instance.newsFeed_data.append(i)
                        }
                        self?.navigateToMainScreen()
                    }
                    else if authError != nil {
                        self?.view.makeToast(authError?.errors.errorText)
                        self?.navigateToMainScreen()
                    }
                    else if error  != nil {
                        print(error?.localizedDescription)
                        self?.navigateToMainScreen()
                    }
                }
            }
        }
    }
    
    private func getSuggestedUsers(){
        switch status {
        case .unknown, .offline:
            self.view.makeToast("Internet Connection Failed")
            navigateToMainScreen()
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetSuggestedGroupManager.sharedInstance.getGroups(type: "users", limit: 8) { (success, authError, error) in
                    if (success != nil){
                        for i in success!.data{
                            AppInstance.instance.suggested_users.append(i)
                        }
                    }
                    else if (authError != nil){
                        print(authError?.errors?.errorText ?? "")
                    }
                    else if (error != nil){
                        print(error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
    
    private func getSuggestedGroups(){
        switch status {
        case .unknown, .offline:
            self.view.makeToast("Internet Connection Failed")
            navigateToMainScreen()
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetSuggestedGroupManager.sharedInstance.getGroups(type: "groups", limit: 8) { (success, authError, error) in
                    if (success != nil){
                        for i in success!.data{
                            AppInstance.instance.suggested_groups.append(i)
                        }
                    }
                    else if (authError != nil){
                        print(authError?.errors?.errorText ?? "")
                    }
                    else if (error != nil){
                        print(error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
    
    private func getmyGroups() {
        switch status {
        case .unknown, .offline:
            showAlert(title: "", message: "Internet Connection Failed")
            navigateToMainScreen()
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetMyGroupsManager.sharedInstance.getMyGroups(userId: UserData.getUSER_ID()!, offset: "") { (success, authError, error) in
                    if success != nil {
                        print(success!.data)
                        for i in success!.data{
                            AppInstance.instance.myGroups.append(i)
                        }
                    }
                    else if authError != nil {
                        print(authError?.errors.errorText ?? "")
                    }
                    else if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    private func getMyPages() {
        switch status {
        case .unknown, .offline:
            print("Internet Connection Failed")
            navigateToMainScreen()
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetMyPagesManager.sharedInstance.getLikedPages(userId: UserData.getUSER_ID()!, offset: "0") { (success, authError, error) in
                    if success != nil {
                        for i in success!.data{
                            AppInstance.instance.myPages.append(i)
                        }
                    }
                    else if authError != nil {
                        print(authError?.errors.errorText ?? "")
                    }
                    else if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }


}
