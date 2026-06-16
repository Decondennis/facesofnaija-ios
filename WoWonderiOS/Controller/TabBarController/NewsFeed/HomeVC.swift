//
//  HomeVC.swift
//  WoWonderiOS
//
//  Created by Abdul Moid on 09/06/2021.
//  Copyright © 2021 clines329. All rights reserved.
//

import UIKit
import AlamofireImage
import Kingfisher
import SDWebImage
import PaginatedTableView
import Toast_Swift
import ZKProgressHUD
import NVActivityIndicatorView

import GoogleMobileAds
import AVFoundation


class HomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var newsFeedArray = [[String:Any]]()
    var TotalFeedArray = [[String:Any]]()
    var suggestedGroupArray = [[String:Any]]()
    var suggestedUserArray = [[String: Any]]()
    var isVideo:Bool? = false
    var flag = true
    var postCount: Int?
    var communityNames:String? = "This is the community"
    var announcement:String? = ""
    
    var greeted = false
    
    let spinner = UIActivityIndicatorView(style: .gray)
    let pulltoRefresh = UIRefreshControl()
    var storiesArray = [GetStoriesModel.UserDataElement]()
    let status = Reach().connectionStatus()
    var selectedIndex = 0
    var filter = 1
    let playRing = URL(fileURLWithPath: Bundle.main.path(forResource: "click_sound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    
    var upperSetctions = 5
    
    var off_set = "0"
    var flagTemp = true
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.loadStories()
        self.greeted = false
        self.navigationController?.navigationBar.isHidden = true
      //  self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.hexStringToUIColor(hex: "#984243")
      //  self.navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#984243")
        print(APIClient.SEARCH_FOR_POST.search_for_post)
        print(APIClient.Events.editEvent)
        print(APIClient.MY_ACTIVITIES.My_Activities)
        print(APIClient.Get_Latest_Blog_POST.BlogPost)
        setupTableView()
        checkFetchDataType()
        setupNotifications()
        
        self.getNewsFeed2(access_token: "access_token=\(UserData.getAccess_Token()!)", limit:15, offset: "0")
    }

    func greet(greeting: String){
        // Configure audio session for TTS
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: greeting)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.samantha.premium")
        utterance.rate = 0.4
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        print("TTS: Speaking greeting - \(greeting)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppInstance.instance.vc = "newsFeedVC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.Segue(notification:)), name: NSNotification.Name(rawValue: "performSegue"), object: nil)
        if AppInstance.instance.commingBackFromAddPost{
            newsFeedArray.removeLast()
            self.storiesArray.removeAll()
            
            self.getNewsFeed2(access_token: "access_token=\(UserData.getAccess_Token()!)", limit: 20, offset: "0")
            AppInstance.instance.commingBackFromAddPost = false
        }
        else{
            
        }
    }
    
    func checkFetchDataType(){
        
        if (AppInstance.instance.newsFeed_data.count == 0){
        self.getNewsFeed2(access_token: "access_token=\(UserData.getAccess_Token()!)", limit:15, offset: "0")
        }
        else{
            self.newsFeedArray = AppInstance.instance.newsFeed_data
            self.off_set = self.newsFeedArray.last?["post_id"] as? String ?? "0"
            self.tableView.reloadData()
        }
        
        if (AppInstance.instance.suggested_groups.count == 0) {
            self.getSuggestedGroup(type: "groups", limit: 8)
        }
        else {
            //            self.activityIndicator.stopAnimating()
            self.suggestedGroupArray = AppInstance.instance.suggested_groups
            self.tableView.reloadData()
        }
        
        if(AppInstance.instance.suggested_users.count == 0) {
            self.getSuggestedUser(type: "users", limit: 8)
            self.tableView.reloadData()
        }
        else {
            //            self.activityIndicator.stopAnimating()
            self.suggestedUserArray = AppInstance.instance.suggested_users
            self.tableView.reloadData()
        }
    }
    
    func setupNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.Segue(notification:)), name: NSNotification.Name(rawValue: "performSegue"), object: nil)
    }
    
    ///Network Connectivity.
    @objc func networkStatusChanged(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let status = userInfo["Status"] as! String
            print(status)
        }
    }
    
    @objc func loadList(notification: NSNotification){
        
        var post_id = ""
        if let data = notification.userInfo?["data"] as? [String:Any] {
            if let id = data["post_id"] as? String{
                post_id = id
            }
            switch status {
            case .unknown, .offline:
                ZKProgressHUD.dismiss()
                self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
            case .online(.wwan), .online(.wiFi):
                performUIUpdatesOnMain {
                    GetNewsFeedManagers.sharedInstance.get_News_Feed(filter: self.filter, access_token: "access_token=\(UserData.getAccess_Token()!)", limit: 10, off_set: "") {[weak self] (success, authError, error) in
                        if success != nil {
                            for i in success!.data{
                                if i["post_id"] as? String == post_id{
                                    self?.newsFeedArray.insert(i, at: 0)
                                }
                            }
                            self?.audioPlayer.play()
                            self?.spinner.stopAnimating()
                            self?.pulltoRefresh.endRefreshing()
                            self?.tableView.reloadData()
                            ZKProgressHUD.dismiss()
                        }
                        else if authError != nil {
                            ZKProgressHUD.dismiss()
                            self?.view.makeToast(authError?.errors.errorText)
                            self?.showAlert(title: "", message: (authError?.errors.errorText)!)
                        }
                        else if error  != nil {
                            ZKProgressHUD.dismiss()
                            print(error?.localizedDescription)
                            
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func Segue(notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String{
            if type == "profile"{
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
                var groupId: String? = nil
                var pageId: String? = nil
                var user_data: [String:Any]? = nil
                if let data = notification.userInfo?["userData"] as? Int{
                    print(data)
                    if let groupid = self.newsFeedArray[data]["group_id"] as? String{
                        groupId = groupid
                    }
                    if let page_Id = self.newsFeedArray[data]["page_id"] as? String{
                        pageId = page_Id
                    }
                    if let userData = self.newsFeedArray[data]["publisher"] as? [String:Any]{
                        user_data = userData
                    }
                }
                if pageId != "0"{
                    let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PageVC") as! PageController
                    
                    vc.page_id = pageId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if groupId != "0"{
                    let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "GroupVC") as! GroupController
                    vc.id = groupId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    if let id = user_data?["user_id"] as? String{
                        if id == UserData.getUSER_ID(){
                            let storyboard = UIStoryboard(name: "MoreSection", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else{
                            vc.userData = user_data
                            //                            if let previousVC = self.navigationController?.previousViewController {
                            //                                if let _ = previousVC as? UserProfileVC {
                            //                                    //..
                            //                                }else {
                            
                            guard let navVC = self.navigationController else { return }
                            if let _ = navVC.topViewController as? HomeVC {
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                            //                                }
                            //                            }
                            
                        }
                    }
                }
            }
            
            else if (type == "share"){
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "UserProfile") as! GetUserDataController
                var groupId: String? = nil
                var pageId: String? = nil
                var user_data: [String:Any]? = nil
                if let data = notification.userInfo?["userData"] as? Int{
                    if let shared_info = self.newsFeedArray[data]["shared_info"] as? [String:Any]{
                        if shared_info != nil{
                            if let groupid = self.newsFeedArray[data]["group_id"] as? String{
                                groupId = groupid
                            }
                            if let page_Id = self.newsFeedArray[data]["page_id"] as? String{
                                pageId = page_Id
                            }
                            if let publisher = shared_info["publisher"] as? [String:Any]{
                                user_data = publisher
                            }
                            if pageId != "0"{
                                let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "PageVC") as! PageController
                                
                                vc.page_id = pageId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else if groupId != "0"{
                                let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "GroupVC") as! GroupController
                                vc.id = groupId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else{
                                if let id = user_data?["user_id"] as? String{
                                    if id == UserData.getUSER_ID(){
                                        let storyboard = UIStoryboard(name: "MoreSection", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileController
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                    else{
                                        vc.userData = user_data
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                        else{
                            if let tag = notification.userInfo?["tag"] as? Int{
                                if let groupid = self.newsFeedArray[tag]["group_id"] as? String{
                                    groupId = groupid
                                }
                                if let page_Id = self.newsFeedArray[tag]["page_id"] as? String{
                                    pageId = page_Id
                                }
                                if let userData = self.newsFeedArray[tag]["publisher"] as? [String:Any]{
                                    user_data = userData
                                }
                            }
                            if pageId != "0"{
                                let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "PageVC") as! PageController
                                
                                vc.page_id = pageId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else if groupId != "0"{
                                let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "GroupVC") as! GroupController
                                vc.id = groupId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else{
                                if let id = user_data?["user_id"] as? String{
                                    if id == UserData.getUSER_ID(){
                                        let storyboard = UIStoryboard(name: "MoreSection", bundle: nil)
                                        let vc = storyboard.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileController
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                    else{
                                        vc.userData = user_data
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else if type == "product"{
                let Storyboard = UIStoryboard(name: "MarketPlaces-PopularPost-Events", bundle: nil)
                let vc = Storyboard.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailController
                if let data = notification.userInfo?["userData"] as? Int{
                    let index =  self.newsFeedArray[data]
                    var seller = [String:Any]()
                    if let publisher = index["publisher"] as? [String:Any]{
                        seller = publisher
                    }
                    if var product = index["product"] as? [String:Any]{
                        product.updateValue(seller, forKey: "seller")
                        vc.productDetails = product
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if type == "edit"{
                let storyboard = UIStoryboard(name: "AddPost", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
                if let index = notification.userInfo?["userData"] as? Int{
                    self.selectedIndex = index
                    print(index)
                }
                if let postId = notification.userInfo?["postId"] as? String{
                    vc.post_id = postId
                }
                if let texts = notification.userInfo?["text"] as? String{
                    if texts != ""{
                        vc.postText = texts
                    }
                }
                if let priva = notification.userInfo?["privacy"] as? String{
                    vc.postPrivacy = Int(priva)
                }
                vc.delegate = self
                vc.isFrom_Edit = "1"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if type == "delete"{
                if let data = notification.userInfo?["userData"] as? Int{
                    print(data)
                    self.newsFeedArray.remove(at: data)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    
    private func getSuggestedUser(type: String, limit: Int) {
        GetSuggestedGroupManager.sharedInstance.getGroups(type: type, limit: 8) {
            (success, authError, error) in
            if success != nil {
                for i in success!.data {
                    self.suggestedUserArray.append(i)
                }
                print("----------------")
                print("suggested users")
                print(self.suggestedUserArray.count)
                print("----------------")
                self.tableView.reloadData()
            }
            else if authError != nil {
                self.view.isUserInteractionEnabled = true
                self.view.makeToast(authError?.errors?.errorText)
            }
            else if error  != nil {
                self.view.isUserInteractionEnabled = true
                print(error?.localizedDescription)
            }
        }
    }
    
    
    private func getSuggestedGroup(type: String, limit: Int) {
        GetSuggestedGroupManager.sharedInstance.getGroups(type: type, limit: 8) {
            (success, authError, error) in
            if success != nil {
                guard let succ = success else { return }
                self.suggestedGroupArray = succ.data
                self.tableView.reloadData()
            }
            else if authError != nil {
                self.view.isUserInteractionEnabled = true
                self.view.makeToast(authError?.errors?.errorText)
            }
            else if error  != nil {
                self.view.isUserInteractionEnabled = true
                print(error?.localizedDescription)
            }
        }
    }
    
    private func getNewsFeed (access_token : String, limit : Int, offset : String) {
        
        switch status {
        case .unknown, .offline:
            ZKProgressHUD.dismiss()
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
            self.view.isUserInteractionEnabled = true
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                GetNewsFeedManagers.sharedInstance.get_News_Feed(filter: self.filter, access_token: access_token, limit: limit, off_set: offset) {[weak self] (success, authError, error) in
                    if success != nil {
                        for i in success!.data{
                            self?.newsFeedArray.append(i)
                        }
                        self?.off_set = self?.newsFeedArray.last?["post_id"] as? String ?? "0"
                        // Sort boosted posts to top
                        self?.newsFeedArray.sort { (post1, post2) -> Bool in
                            let boosted1 = post1["is_post_boosted"] as? Int ?? 0
                            let boosted2 = post2["is_post_boosted"] as? Int ?? 0
                            return boosted1 > boosted2
                        }
                        self?.spinner.stopAnimating()
                        self?.pulltoRefresh.endRefreshing()
                        self?.tableView.reloadData()
                        self?.view.isUserInteractionEnabled = true
                   //     self?.loadStories()
                        //                        self?.activityIndicator.stopAnimating()
                        ZKProgressHUD.dismiss()
                    }
                    else if authError != nil {
                        ZKProgressHUD.dismiss()
                        self?.view.isUserInteractionEnabled = true
                        self?.view.makeToast(authError?.errors.errorText)
                    }
                    else if error  != nil {
                        ZKProgressHUD.dismiss()
                        self?.view.isUserInteractionEnabled = true
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func getNewsFeed2 (access_token : String, limit : Int, offset : String) {
        switch status {
        case .unknown, .offline:
            ZKProgressHUD.dismiss()
            self.view.makeToast("Internet Connection Failed")
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                GetNewsFeedManagers.sharedInstance.get_News_Feed(filter: self.filter, access_token: access_token, limit: limit, off_set: offset) {[weak self] (success, authError, error) in
                    if success != nil {
                        
                        
                        //self?.newsFeedArray.removeAll()
                        for i in success!.data{
                            self?.newsFeedArray.append(i)
                        }
                        self?.off_set = self?.newsFeedArray.last?["post_id"] as? String ?? "0"
                        // Sort boosted posts to top
                        self?.newsFeedArray.sort { (post1, post2) -> Bool in
                            let boosted1 = post1["is_post_boosted"] as? Int ?? 0
                            let boosted2 = post2["is_post_boosted"] as? Int ?? 0
                            return boosted1 > boosted2
                        }
                        self?.pulltoRefresh.endRefreshing()
                        print("Feed loaded: \(self?.newsFeedArray.count ?? 0) posts")
                        ZKProgressHUD.dismiss()
                        self?.tableView.reloadData()
                        self?.loadStories()
                        // Save user avatar from feed if not already set
                        self?.saveUserAvatarFromFeed()
                    }
                    else if authError != nil {
                        ZKProgressHUD.dismiss()
                        self?.pulltoRefresh.endRefreshing()
                        self?.view.makeToast(authError?.errors.errorText)
                        self?.tableView.reloadData()
                    }
                    else if error  != nil {
                        ZKProgressHUD.dismiss()
                        self?.pulltoRefresh.endRefreshing()
                        print("Feed error: \(error?.localizedDescription ?? "Unknown error")")
                        self?.view.makeToast("Failed to load feed. Please try again.")
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    private func getCommunityNames () {
        switch status {
        case .unknown, .offline:
            ZKProgressHUD.dismiss()
            self.view.makeToast("Internet Connection Failed")
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                print("This is the begin to get community names")
                GetCommunityNamesManagers.sharedInstance.get_Community_Names() {[weak self] (success, authError, error) in
                    if success != nil {
                        print(success)
                        self!.communityNames = success?.data ?? ""
                    }
                    else if authError != nil {
                        ZKProgressHUD.dismiss()
                        self?.view.makeToast(authError?.errors.errorText)
                    }
                    else if error  != nil {
                        ZKProgressHUD.dismiss()
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func getGeneralAnnouncementData(){
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetGeneralDataManager.sharedInstance.getGeneralDataManager(fetch: "announcement", offset: "") { (success, authError, Error) in
                    if success != nil {
                        //print(success?.announcement)
                        //print("The announcement is here")
                        //print(success?.announcement!.text_decode)
                        self.announcement = success?.announcement["text_decode"] as? String ?? ""
                        
                        self.announcement = self.announcement?.replacingOccurrences(of: "\n", with: " ")
                    }
                    else if authError != nil{
                        self.view.makeToast(authError?.errors.errorText)
                    }
                    else if Error != nil{
                        self.view.makeToast(Error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    private func loadStories(){
        switch status {
        case .unknown, .offline:
            ZKProgressHUD.dismiss()
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                StoriesManager.sharedInstance.getUserStories(offset: 0, limit: 10) {[weak self] (success, authError, error) in
                    if success != nil {
                     //  let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! HomeStroyCells
                       // let cell = tableView.deq as! HomeStroyCells
                      //  cell.stories = success?.stories ?? []
                        self?.storiesArray = success?.stories ?? []
                        self?.getSuggestedGroup(type: "groups", limit: 8)
                        self?.tableView.reloadData()
                    }
                    else if authError != nil {
                        ZKProgressHUD.dismiss()
                        self?.view.makeToast(authError?.errors?.errorText ?? "Authentication error")
                        self?.showAlert(title: "", message: (authError?.errors?.errorText) ?? "Authentication error")
                    }
                    else if error  != nil {
                        ZKProgressHUD.dismiss()
                        print(error?.localizedDescription ?? "Unknown error")
                        
                    }
                }
            }
        }
    }
    
    func setupTableView(){
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        // Add pull-to-refresh control
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = self.pulltoRefresh
        } else {
            self.tableView.addSubview(self.pulltoRefresh)
        }
        self.pulltoRefresh.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        self.pulltoRefresh.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        
        self.tableView.register(UINib(nibName: "HomeAddPostCell", bundle: nil), forCellReuseIdentifier: "HomeAddPostCell")
        self.tableView.register(UINib(nibName: "HomeStroyCells", bundle: nil), forCellReuseIdentifier: "HomeStroyCells")
        self.tableView.register(UINib(nibName: "SuggestedGroupsCell", bundle: nil), forCellReuseIdentifier: "SuggestedGroupsCell")
        SetUpcells.setupCells(tableView: self.tableView)
        self.tableView.register(UINib(nibName: "HomeCommunities", bundle: nil), forCellReuseIdentifier: "HomeCommunities")
        self.tableView.register(UINib(nibName: "HomeNews", bundle: nil), forCellReuseIdentifier: "HomeNews")
        self.tableView.register(UINib(nibName: "HomeGreetings", bundle: nil), forCellReuseIdentifier: "HomeGreetings")
        
    }
    
    @objc func refreshFeed() {
        self.newsFeedArray.removeAll()
        self.off_set = "0"
        self.tableView.reloadData()
        self.getNewsFeed2(access_token: "access_token=\(UserData.getAccess_Token() ?? "")", limit: 15, offset: "0")
        self.loadStories()
        self.getSuggestedGroup(type: "groups", limit: 8)
        self.getSuggestedUser(type: "users", limit: 8)
    }
    
    private func saveUserAvatarFromFeed() {
        // Only save if avatar is not already set
        guard UserData.getImage() == nil || UserData.getImage()?.isEmpty == true else { return }
        
        for post in newsFeedArray {
            if let publisher = post["publisher"] as? [String:Any],
               let userId = publisher["user_id"] as? String,
               userId == UserData.getUSER_ID(),
               let avatar = publisher["avatar"] as? String,
               !avatar.isEmpty {
                UserData.SetImage(avatar)
                tableView.reloadData()
                break
            }
        }
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        let Storyboard = UIStoryboard(name: "Search", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "SearchVC") as! UINavigationController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    func gotoPost(){
        let storyboard = UIStoryboard(name: "AddPost", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
        vc.isOpenSheet = 1
        self.present(vc, animated: true)
    }
    
    @IBAction func messengerClicked(_ sender: Any) {
        self.openMessenger()
    }
    
    func showStoriesLog(){
        
        let alert = UIAlertController(title: NSLocalizedString("source", comment: "source"), message: NSLocalizedString("Add new Story", comment: "Add new Story"), preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                self.isVideo = false
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                imagePickerController.allowsEditing = false
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
                
            }else{
                let alert  = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: NSLocalizedString("You don't have camera", comment: "You don't have camera"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        let videos = UIAlertAction(title: NSLocalizedString("Videos", comment: "Videos"), style: .default) { (UIAlertAction) in
            self.isVideo = true
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.movie"]
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let image = UIAlertAction(title: NSLocalizedString("Image", comment: "Image"), style: .default) { (action) in
            self.isVideo = false
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePickerController.mediaTypes = ["public.image"]
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
            print("cancel")
        }
        alert.addAction(image)
        alert.addAction(videos)
        alert.addAction(camera)
        alert.addAction(cancel)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func openMessenger(){
        let appURLScheme = "AppToOpen://"
        guard let appURL = URL(string: appURLScheme) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(appURL) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
        else {
            self.view.makeToast("Please install Facesofnaija Messenger App")
        }
    }
    @IBAction func filterClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Filter", comment: "Filter"), preferredStyle: .actionSheet)
        
        alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: NSLocalizedString("All", comment: "All"), style: .default, handler: { (_) in
//            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! SortFilterCell
//            cell.followLbl.text = NSLocalizedString("All", comment: "All")
            self.filter = 1
            self.off_set = ""
            self.spinner.startAnimating()
            self.newsFeedArray.removeAll()
            self.tableView.reloadData()
            self.getNewsFeed(access_token: "access_token=\(UserData.getAccess_Token()!)", limit:15, offset: "0")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("People i Follow", comment: "People i Follow"), style: .default, handler: { (_) in
//            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! SortFilterCell
//            cell.followLbl.text = NSLocalizedString("People i Follow", comment: "People i Follow")
            self.filter = 0
            self.off_set = ""
            self.spinner.startAnimating()
            self.newsFeedArray.removeAll()
            self.tableView.reloadData()
            self.getNewsFeed(access_token: "access_token=\(UserData.getAccess_Token()!)", limit:10, offset: "0")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5 + self.newsFeedArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = self.newsFeedArray.count - 1
        if self.newsFeedArray.count >= count {
            let count = self.newsFeedArray.count
            let lastElement = count - 1
            if indexPath.section == lastElement {
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                self.getNewsFeed2(access_token: "access_token=\(UserData.getAccess_Token()!)", limit: 20, offset: off_set)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeAddPostCell", for: indexPath) as! HomeAddPostCell
            cell.vc = self
            if let imageUrl = UserData.getImage(), !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                cell.userprofileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "no-avatar"), options: [.refreshCached], completed: nil)
            } else {
                cell.userprofileImage.image = UIImage(named: "no-avatar")
            }
            
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStroyCells", for: indexPath) as! HomeStroyCells
            cell.vc = self
            cell.stories = self.storiesArray
            cell.collectionView.reloadData()
            return cell
        }else if indexPath.section == 2 {
            self.getCommunityNames()
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCommunities", for: indexPath) as! HomeCommunities
            cell.vc = self
            cell.backgroundColor = .clear
            
            // Style the cell content
            cell.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.clipsToBounds = true
            cell.selectionStyle = .none
            
            cell.communityLabel.text = "Communities"
            cell.communityDetailLabel.text = self.communityNames
            cell.communityDetailLabel.type = .continuous
            cell.communityDetailLabel.speed = .rate(30)
            cell.communityDetailLabel.fadeLength = 10
            
            // Community globe icon with rounded corners
            cell.userprofileImageView.image = UIImage(named: "globe")
            cell.userprofileImageView.layer.cornerRadius = 10
            cell.userprofileImageView.clipsToBounds = true
            cell.userprofileImageView.contentMode = .scaleAspectFill
            
            // Make entire cell tappable
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCommunities))
            cell.contentView.addGestureRecognizer(tapGesture)
            cell.contentView.isUserInteractionEnabled = true
            
            return cell
        }else if indexPath.section == 3 {
            self.getGeneralAnnouncementData()
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeNews", for: indexPath) as! HomeNews
            cell.vc = self
            cell.backgroundColor = .clear
            
            // Style the cell content
            cell.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.clipsToBounds = true
            cell.selectionStyle = .none
            
            // Title with bold styling
            let title = NSMutableAttributedString(string: "Breaking News")
            title.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 0, length: title.length))
            title.addAttribute(.foregroundColor, value: UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0), range: NSRange(location: 0, length: title.length))
            cell.label.attributedText = title
            
            // Animated GIF icon for news
            if let gifImage = UIImage.gif(name: "ic_news") {
                cell.userprofileImageView.image = gifImage
            } else {
                cell.userprofileImageView.image = UIImage(named: "ic_post_park")
            }
            cell.userprofileImageView.layer.cornerRadius = 8
            cell.userprofileImageView.clipsToBounds = true
            cell.userprofileImageView.contentMode = .scaleAspectFit
            
            cell.detailLabel.text = self.announcement
            cell.detailLabel.type = .continuous
            cell.detailLabel.speed = .rate(40)
            cell.detailLabel.fadeLength = 10
            
            // Make entire cell tappable for navigation
            cell.contentView.tag = 1
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openAnnouncements))
            cell.contentView.addGestureRecognizer(tapGesture)
            cell.contentView.isUserInteractionEnabled = true
            
            return cell
        }else if indexPath.section == 4 {
            var greeting = ""
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeGreetings", for: indexPath) as! HomeGreetings
            cell.vc = self
            cell.backgroundColor = .clear
            
            // Style the cell content
            cell.contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.clipsToBounds = true
            cell.selectionStyle = .none
//            if flag {
                let date = Date()
                let calendar = Calendar.current
                var timeText = ""
                let hour = calendar.component(.hour, from: date)
            
                if !greeted {
                    if hour < 8 && hour > 0 {
                        greeting = RandomMorningGreeting()
                        timeText = "Good Morning, "
                        cell.greetingLabel.text = timeText+" \(AppInstance.instance.profile?.userData?.name ?? "")!"
                        cell.greetingDetailLabel.text = greeting
                    }
                    else if hour < 17 {
                        greeting = RandomAfternoonGreeting()
                        timeText = "Good Afternoon, "
                        cell.greetingLabel.text = timeText+" \(AppInstance.instance.profile?.userData?.name ?? "")!"
                        cell.greetingDetailLabel.text = greeting
                    }
                    else {
                        greeting = RandomEveningGreeting()
                        timeText = "Good Evening, "
                        cell.greetingLabel.text = timeText+" \(AppInstance.instance.profile?.userData?.name ?? "")!"
                        cell.greetingDetailLabel.text = greeting
                    }
                    
                    // Load user avatar for greeting card
                    if let avatarUrl = UserData.getImage(), !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
                        cell.userprofileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "no-avatar"), options: [.refreshCached], completed: nil)
                    } else {
                        cell.userprofileImageView.image = UIImage(named: "no-avatar")
                    }
                    cell.userprofileImageView.layer.cornerRadius = 35
                    cell.userprofileImageView.clipsToBounds = true
                    cell.userprofileImageView.contentMode = .scaleAspectFill
            
                    var name = (AppInstance.instance.profile?.userData?.name ?? "")
                    if !name.isEmpty {
                        name += ", "
                    }
                    greet(greeting: name + greeting)
                    
                    greeted = true
                }
//            }
            return cell
        }
        else{
            let indexValue = indexPath.section - upperSetctions
            
            if indexValue == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedGroupsCell", for: indexPath) as! SuggestedGroupsCell
                cell.vc = self
                cell.isUser = false
                cell.groupArray = self.suggestedGroupArray
                cell.suggestedLabel.text = "Suggested Groups"
                return cell
            }else if indexValue == 7{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedGroupsCell", for: indexPath) as! SuggestedGroupsCell
                cell.vc = self
                cell.groupArray = self.suggestedUserArray
                cell.suggestedLabel.text = "Suggested User"
                cell.isUser = true
                return cell
            }else {
                let indxPath = IndexPath(row: indexPath.section - upperSetctions, section: 0)
                
                let index = self.newsFeedArray[indexPath.section - upperSetctions ]
                var tableViewCells = UITableViewCell()
                var shared_info : [String:Any]? = nil
                var fundDonation: [String:Any]? = nil
                var live = ""
                let postfile = index["postFile"] as? String ?? ""
                let postLink = index["postLink"] as? String ?? ""
                let postYoutube = index["postYoutube"] as? String ?? ""
                let blog = index["blog_id"] as? String ?? "0"
                let group = index["group_recipient_exists"] as? Bool ??  false
                let product = index["product_id"] as? String ?? "0"
                let event = index["page_event_id"] as? String ?? "0"
                let postSticker = index["postSticker"] as? String ?? ""
                let colorId = index["color_id"] as? String ?? "0"
                let multi_image = index["multi_image"] as? String ?? "0"
                let photoAlbum = index["album_name"] as? String ?? ""
                let postOptions = index["poll_id"] as? String ?? "0"
                let postRecord = index["postRecord"] as? String ?? "0"
                if let postType = index["postType"] as? String{
                    live = postType
                }
                if let sharedInfo = index["shared_info"] as? [String:Any] {
                    shared_info = sharedInfo
                }
                if let fund = index["fund_data"] as? [String:Any]{
                    fundDonation = fund
                }
                
                if (shared_info != nil){
                    tableViewCells = GetPostShare.sharedInstance.getsharePost(targetController: self, tableView: self.tableView, indexpath: indxPath, postFile: postfile, array: self.newsFeedArray)
                }
//                else if (live != ""){
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "LiveCell") as! PostLiveCell
//                    self.tableView.rowHeight = UITableView.automaticDimension
//                    self.tableView.estimatedRowHeight = 350.0
//                    cell.bind(index: index, indexPath: indexPath.section - 3)
//                    cell.vc = self
//                    tableViewCells = cell
//                }
                else if (postfile != "")  {
                    let url = URL(string: postfile)
                    let urlExtension: String? = url?.pathExtension
                    if (urlExtension == "jpg" || urlExtension == "png" || urlExtension == "jpeg" || urlExtension == "JPG" || urlExtension == "PNG"){
                        print("NewsFeed",indexPath.row)
                        tableViewCells = GetPostWithImage.sharedInstance.getPostImage(targetController: self, tableView: tableView, indexpath: indxPath, postFile: postfile, array: self.newsFeedArray, url: url!, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    }
                    
                    else if(urlExtension == "wav" ||  urlExtension == "mp3" || urlExtension == "MP3"){
                        tableViewCells = GetPostMp3.sharedInstance.getMP3(targetController: self, tableView: tableView, indexpath: indxPath, postFile: postfile, array: self.newsFeedArray,stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    }
                    else if (urlExtension == "pdf") {
                        tableViewCells = GetPostPDF.sharedInstance.getPostPDF(targetControler: self, tableView: self.tableView, indexpath: indxPath, postfile: postfile, array: self.newsFeedArray,stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                        
                    }
                    
                    else {
                        tableViewCells = GetPostVideo.sharedInstance.getVideo(targetController: self, tableView: tableView, indexpath: indxPath, postFile: postfile, array: self.newsFeedArray, url: url!, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    }
                }
                
                else if (postLink != "") {
                    tableViewCells = GetPostWithLink.sharedInstance.getPostLink(targetController: self, tableView: tableView, indexpath: indxPath, postLink: postLink, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if (postYoutube != "") {
                    tableViewCells = GetPostYoutube.sharedInstance.getPostYoutub(targetController: self, tableView: tableView, indexpath: indxPath, postLink: postYoutube, array: self.newsFeedArray,stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                else if (blog != "0") {
                    tableViewCells = GetPostBlog.sharedInstance.GetBlog(targetController: self, tableView: tableView, indexpath: indxPath, postFile: "", array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if (group != false){
                    tableViewCells = GetPostGroup.sharedInstance.GetGroupRecipient(targetController: self, tableView: tableView, indexpath: indxPath, postFile: "", array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if (product != "0") {
                    tableViewCells = GetPostProduct.sharedInstance.GetProduct(targetController: self, tableView: tableView, indexpath: indxPath, postFile: "", array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                else if (event != "0") {
                    tableViewCells = GetPostEvent.sharedInstance.getEvent(targetController: self, tableView: tableView, indexpath: indxPath, postFile: "", array:  self.newsFeedArray,stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                else if (postSticker != "") {
                    tableViewCells = GetPostSticker.sharedInstance.getPostSticker(targetController: self, tableView: tableView, indexpath: indxPath, postFile: postfile, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if (colorId != "0"){
                    tableViewCells = GetPostWithBg_Image.sharedInstance.postWithBg_Image(targetController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if (multi_image != "0") {
                    tableViewCells = GetPostMultiImage.sharedInstance.getMultiImage(targetController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                
                else if photoAlbum != "" {
                    tableViewCells = getPhotoAlbum.sharedInstance.getPhoto_Album(targetController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if postOptions != "0" {
                    tableViewCells = GetPostOptions.sharedInstance.getPostOptions(targertController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                }
                
                else if postRecord != ""{
                    tableViewCells = GetPostRecord.sharedInstance.getPostRecord(targetController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                else if fundDonation != nil{
                    tableViewCells = GetDonationPost.sharedInstance.getDonationpost(targetController: self, tableView: tableView, indexpath: indxPath, array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                
                else {
                    tableViewCells = GetNormalPost.sharedInstance.getPostText(targetController: self, tableView: self.tableView, indexpath: indxPath, postFile: "", array: self.newsFeedArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                    
                }
                return tableViewCells
            }
        }
    }
    
    @objc func click(sender:UITapGestureRecognizer) {
        print("This is clickable now")
        
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyCommunitiesVC") as! CommunityListController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openCommunities() {
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MyCommunitiesVC") as? CommunityListController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func openAnnouncements() {
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        // Try to find announcements controller, fallback to communities
        if let vc = storyboard.instantiateViewController(withIdentifier: "MyCommunitiesVC") as? CommunityListController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createLive(){
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = Storyboard.instantiateViewController(identifier: "CreateLiveVC") as! CreateLiveController
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.goToAddPost()
        }
    }
    
    func goToAddPost(){
        let storyboard = UIStoryboard(name: "AddPost", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 2
        }else if section >= 2 && section <= 4 {
            // Space between feature cards
            return 8
        }else {
            let indexValue = section - upperSetctions
            if indexValue == 5 {
                //suggested groups
                if suggestedGroupArray.isEmpty {
                    return CGFloat.leastNonzeroMagnitude
                }else {
                    return 5
                }
            }else if indexValue == 7 {
                //suggested users
                if suggestedUserArray.isEmpty {
                    return CGFloat.leastNonzeroMagnitude
                }else {
                    return 5
                }
            }
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi = UIView()
        vi.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9607843137, alpha: 1)
        return vi
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 130
        }else if indexPath.section == 1 {
            return 185
        }else if indexPath.section == 2 {
            return 120
        }else if indexPath.section == 3 {
            return 120
        }else if indexPath.section == 4 {
            return 130
        }else{
            //post cells
            let indexValue = indexPath.section - upperSetctions
            if indexValue == 5 {
                //suggested groups
                if suggestedGroupArray.isEmpty {
                    return CGFloat.leastNonzeroMagnitude
                }else {
                    return 400
                }
            }else if indexValue == 7 {
                //suggested users
                if suggestedUserArray.isEmpty {
                    return CGFloat.leastNonzeroMagnitude
                }else {
                    return 400
                }
            }
            return UITableView.automaticDimension
        }
    }
}

extension HomeVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            if self.isVideo! {
                
                if let vidURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    var CreateVideoStoryVC = UIStoryboard(name: "Stories", bundle: nil).instantiateViewController(withIdentifier: "CreateVideoStoryVC") as! CreateVideoStoryVC
                    let videoData = try? Data(contentsOf: vidURL)
                    CreateVideoStoryVC.videoData1 = videoData
                    CreateVideoStoryVC.videoLinkString  = vidURL.absoluteString
                    self.navigationController?.pushViewController(CreateVideoStoryVC, animated: true)
                }
                
            }else{
                if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    var CreateImageStoryVC = UIStoryboard(name: "Stories", bundle: nil).instantiateViewController(withIdentifier: "CreateImageStoryVC") as! CreateImageStoryVC
                    CreateImageStoryVC.imageLInkString  = FileManager().savePostImage(image: img)
                    CreateImageStoryVC.iamge = img
                    CreateImageStoryVC.isVideo = self.isVideo
                    self.navigationController?.pushViewController(CreateImageStoryVC, animated: true)
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension HomeVC: createLiveDelegate {
    
    func createLive(name: String) {
        let Storyboards = UIStoryboard(name: "Main", bundle: nil)
        let vc = Storyboards.instantiateViewController(withIdentifier: "LiveVC") as! LiveStreamController
        vc.streamName = name
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension HomeVC: editPostDelegate{
    func editPost(newtext: String, postPrivacy: String) {
        self.newsFeedArray[self.selectedIndex]["postText"] = newtext
        self.newsFeedArray[self.selectedIndex]["postPrivacy"] = postPrivacy
        self.tableView.reloadData()
    }
}

extension UINavigationController {
    var previousViewController: UIViewController? {
        guard viewControllers.count > 1 else { return nil }
        return viewControllers[viewControllers.count - 2]
    }
}
