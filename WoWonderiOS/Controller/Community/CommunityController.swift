//
//  CommunityController.swift
//  FacesofnaijaiOS
//
//  Created by MacBook Pro on 19/07/2022.
//  Copyright © 2022 clines329. All rights reserved.
//

import UIKit
import Kingfisher

import GoogleMobileAds
import AVFoundation

class CommunityController: UIViewController,CommunityMoreDelegate,editPostDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let Storyboard = UIStoryboard(name: "Communities", bundle: nil)
    
    var communityPostsArray = [[String:Any]]()
    var communityData = [String:Any]()
    var communityCover = ""
    var communityIcon = ""
    var communityTitle = ""
    var communityName = ""
    var about = ""
    var category = ""
    var afterpostid  = "0"
    var communityId = ""
    var isJoined = false
    var isAdmin = false
    var privacy = "0"
    var categoryId = ""
    var aboutCommunity = ""
    var selectedIndex = 0
    
    var id: String? = nil
    var isFromList = false
    var isData_nil: Bool = false

    var delegte : JoinCommunityDelegate!
    
    let status = Reach().connectionStatus()
    let spinner = UIActivityIndicatorView(style: .gray)

    var interstitial: GADInterstitialAd!
    
    let playRing = URL(fileURLWithPath: Bundle.main.path(forResource: "click_sound", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.register(UINib(nibName: "SearchPostCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        self.tableView.register(UINib(nibName: "CommunityCoverCell", bundle: nil), forCellReuseIdentifier: "CommunityCover")
        self.tableView.tableFooterView = UIView()
        if let community_id = self.communityData["id"] as? String{
            self.id = community_id
        }
        self.audioPlayer = try! AVAudioPlayer(contentsOf: playRing)
        self.getCommunityData(communityId: self.id ?? "")
        self.getCommunityPosts(communityId: self.id ?? "", offset: self.afterpostid)
        SetUpcells.setupCells(tableView: self.tableView)
        self.tableView.register(UINib(nibName: "PostLiveCell", bundle: nil), forCellReuseIdentifier: "LiveCell")
        print(self.isJoined)
        print(self.category,self.categoryId)
        if ControlSettings.shouldShowAddMobBanner{
//            interstitial = GADInterstitialAd(adUnitID:  ControlSettings.interestialAddUnitId)
//            let request = GADRequest()
//            interstitial.load(request)
            GADInterstitialAd.load()
        }

    }
    func CreateAd() -> GADInterstitialAd {
             let interstitial = GADInterstitialAd()
//             interstitial.load(GADRequest())
             return interstitial
         }
     
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = true
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        AppInstance.instance.vc = "communityVC"
        NotificationCenter.default.addObserver(self, selector: #selector(self.Notifire(notification:)), name: NSNotification.Name(rawValue: "Notifire"), object: nil)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Notifire"), object: nil)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    /// Network Connectivity
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let status = userInfo["Status"] as! String
            print("Status",status)
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
                self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
            case .online(.wwan), .online(.wiFi):
                performUIUpdatesOnMain {
                    GetCommunityPostManager.sharedInstance.getCommunityPost(communityId: self.id ?? "", afterPostId: "") {[weak self] (success, authError, error) in
                        if success != nil {
                            for i in success!.data{
                                if i["post_id"] as? String == post_id{
                                    self?.communityPostsArray.insert(i, at: 0)
                                }
                            }
                            if success?.data.count == 0 {
                                self?.isData_nil = true
                            }
                            else{
                                self?.isData_nil = false
                            }
                            self?.audioPlayer.play()
                             self?.spinner.stopAnimating()
                              self?.tableView.reloadData()
                          }
                          else if authError != nil {
                              self?.showAlert(title: "", message: (authError?.errors.errorText)!)
                          }
                          else if error != nil {
                              print(error?.localizedDescription)
                          }
                      }
                }
            }
        }
    }
    
    func editPost(newtext: String, postPrivacy: String) {
        self.communityPostsArray[self.selectedIndex]["postText"] = newtext
        self.communityPostsArray[self.selectedIndex]["postPrivacy"] = postPrivacy
        self.tableView.reloadData()
    }
    

    
    @objc func Notifire(notification: NSNotification){
        if let type = notification.userInfo?["type"] as? String{
            if type == "delete"{
                if let data = notification.userInfo?["userData"] as? Int{
                    print(data)
                    self.communityPostsArray.remove(at: data)
                    self.tableView.reloadData()
                }
            }
            
            if type == "edit"{
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
                vc.isFrom_Edit = "1"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if type == "profile"{
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "UserProfile") as! GetUserDataController
                var groupId: String? = nil
                var communityId: String? = nil
                var pageId: String? = nil
                var user_data: [String:Any]? = nil
                if let data = notification.userInfo?["userData"] as? Int{
                    print(data)
                    if let groupid = self.communityPostsArray[data]["group_id"] as? String{
                        groupId = groupid
                    }
                    if let communityid = self.communityPostsArray[data]["community_id"] as? String{
                        communityId = communityid
                    }
                    if let page_Id = self.communityPostsArray[data]["page_id"] as? String{
                        pageId = page_Id
                    }
                    if let userData = self.communityPostsArray[data]["publisher"] as? [String:Any]{
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
                else if communityId != "0"{
                    let storyboard = UIStoryboard(name: "Communities", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CommunityVC") as! CommunityController
                    vc.id = communityId
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
                
            else if (type == "share"){
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "UserProfile") as! GetUserDataController
                var groupId: String? = nil
                var communityId: String? = nil
                var pageId: String? = nil
                var user_data: [String:Any]? = nil
                if let data = notification.userInfo?["userData"] as? Int{
                    if let shared_info = self.communityPostsArray[data]["shared_info"] as? [String:Any]{
                        if shared_info != nil{
                            if let groupid = self.communityPostsArray[data]["group_id"] as? String{
                                groupId = groupid
                            }
                            if let communityid = self.communityPostsArray[data]["community_id"] as? String{
                                communityId = communityid
                            }
                            if let page_Id = self.communityPostsArray[data]["page_id"] as? String{
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
                            else if communityId != "0"{
                                let storyboard = UIStoryboard(name: "Communities", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "CommunityVC") as! CommunityController
                                vc.id = communityId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else{
                                if let id = user_data?["user_id"] as? String{
                                    if id == UserData.getUSER_ID(){
                                        
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
                                if let groupid = self.communityPostsArray[tag]["group_id"] as? String{
                                    groupId = groupid
                                }
                                if let communityid = self.communityPostsArray[tag]["community_id"] as? String{
                                    communityId = communityid
                                }
                                if let page_Id = self.communityPostsArray[tag]["page_id"] as? String{
                                    pageId = page_Id
                                }
                                if let userData = self.communityPostsArray[tag]["publisher"] as? [String:Any]{
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
                            else if communityId != "0"{
                                let storyboard = UIStoryboard(name: "Communities", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "CommunityVC") as! CommunityController
                                vc.id = communityId
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            else{
                                if let id = user_data?["user_id"] as? String{
                                    if id == UserData.getUSER_ID(){
                                        
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
        }
    }
    private func getCommunityData(communityId: String){
        switch status {
        case .unknown, .offline:
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetCommunityDataManager.sharedInstance.getData(communityId: communityId) { (success, authError, error) in
                    if success != nil{
                    self.communityData = success!.community_data
                        //self.isAdmin = self.communityData["is_owner"] as? Bool ?? true
                        self.isJoined = self.communityData["is_joined"] as? Bool ?? true
                    self.tableView.reloadData()
                    }
                    else if authError != nil{
                        self.view.makeToast(authError?.errors.errorText)
                    }
                    else if error != nil{
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            }
        }
    }

    private func getCommunityPosts(communityId:String, offset:String){
        switch status {
        case .unknown, .offline:
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetCommunityPostManager.sharedInstance.getCommunityPost(communityId: communityId, afterPostId: offset) {[weak self] (success, authError, error) in
                      if success != nil {
                          for i in success!.data{
                          self?.communityPostsArray.append(i)
                          }
                        self?.afterpostid = self?.communityPostsArray.last?["post_id"] as? String ?? "0"
                        if success?.data.count == 0 {
                            self?.isData_nil = true
                        }
                        else{
                            self?.isData_nil = false
                        }
                         self?.spinner.stopAnimating()
                          self?.tableView.reloadData()
                      }
                      else if authError != nil {
                          self?.showAlert(title: "", message: (authError?.errors.errorText)!)
                      }
                      else if error != nil {
                          print(error?.localizedDescription)
                      }
                  }
            }
        }
    }
    
    private func JoinCommunity(){
        switch status {
         case .unknown, .offline:
             self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
         case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                JoinCommunityManager.sharedInstance.joinCommunity(communityId: Int(self.id ?? "0") ?? 0) { (success, authError, error) in
                    if success != nil {
                        print(success?.join_status)
                    }
                    else if authError != nil {
                        print(authError?.errors.errorText)
                    }
                    else if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
private func uploadImage(imageType:String, data:Data){
    var community_id: String? = nil
    if let communityId = self.communityData["community_id"] as? String{
        community_id = communityId
    }
    UpdateCommunityDataManager.sharedInstance.uploadImage(communityId: community_id ?? "", imageType:
        imageType, data: data) { (success, authError, error) in
            performUIUpdatesOnMain {
                if success != nil {
                    self.view.makeToast(success?.message)
                    print(success!.message)
                }
                else if authError != nil {
                    self.view.makeToast(authError?.errors.errorText)
                }
                else if error != nil {
                    print(error?.localizedDescription)
                }
            }
            
        }
        
    }
    
    func gotoSetting(type: String) {
        var community_url: String? = nil
        if let communityUrl = self.communityData["url"] as? String{
            community_url = communityUrl
        }
        /*if type == "setting"{
        let Storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "CommunitySettingVC") as! CommunitySettingController
        vc.communityName = self.communityName
        vc.communityTitle = self.communityTitle
        vc.privacy = self.privacy
        vc.categoryName = self.category
        vc.categoryId = self.categoryId
        vc.about = self.aboutCommunity
        vc.community_Id = self.communityId
        vc.categoryName = self.category
        self.navigationController?.pushViewController(vc, animated: true)
        }
        else*/ if type == "copy"{
            UIPasteboard.general.string = community_url
            self.view.makeToast(NSLocalizedString("Link copied to clipboard", comment: "Link copied to clipboard"))
        }
        else {
            let text = community_url
            
            // set up activity view controller
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional,)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.message,UIActivity.ActivityType.postToFlickr,UIActivity.ActivityType.postToVimeo,UIActivity.ActivityType.init(rawValue: "net.whatsapp.WhatsApp.ShareExtension"),UIActivity.ActivityType.init(rawValue: "com.google.Gmail.ShareExtension"),UIActivity.ActivityType.init(rawValue: "com.toyopagroup.picaboo.share"),UIActivity.ActivityType.init(rawValue: "com.tinyspeck.chatlyio.share")]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            
        }
    }
    
    @objc func GotoAddPost(sender: UIButton){
        let storyboard = UIStoryboard(name: "AddPost", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CommunityController : UITableViewDataSource,UITableViewDelegate,uploadImageDelegate{
     func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1{
            return 1
        }
        else if (section == 2){
            return 1
        }
        else if (section == 3){
            return 1
        }
        else if (section == 4){
            return 1
        }
        else if (section == 5){
            return 1
        }
        else {
           return self.communityPostsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
        
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCover") as! CommunityCoverCell
     self.tableView.rowHeight = 362.0
        if let avatar = self.communityData["avatar"] as? String{
            let image = avatar.trimmingCharacters(in: .whitespaces)
            let url = URL(string: image)
            cell.profile.kf.setImage(with: url)
        }
        if let cover = self.communityData["cover"] as? String{
            let image = cover.trimmingCharacters(in: .whitespaces)
            let url = URL(string: image)
            cell.cover.kf.setImage(with: url)
        }
        if let title = self.communityData["community_title"] as? String{
            cell.titleLabel.text = title
        }
        if let subTitle = self.communityData["community_name"] as? String{
            cell.subtitleLabel.text = "\("@")\(subTitle)"
        }
        if let category = self.communityData["category"] as? String{
            cell.categoryBtn.setTitle("\("   ")\(category)", for: .normal)
        }
        if let user_id = self.communityData["user_id"] as? String{
            print(user_id)
            /*if user_id == UserData.getUSER_ID(){
                cell.joinCommunityBtn.setTitle(NSLocalizedString("Edit", comment: "Edit"), for: .normal)
                cell.joinCommunityBtn.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
//                    UIColor.hexStringToUIColor(hex: "984243")
                cell.joinCommunityBtn.setTitleColor(.white, for: .normal)
            }
            else{*/
                //cell.editIconBtn.isHidden = true
                //cell.editCoverBtn.isHidden = true
                //cell.editView.isHidden = true
                if let is_Joined = self.communityData["is_joined"] as? Bool{
                    if is_Joined{
                cell.joinCommunityBtn.setTitle(NSLocalizedString("Joined", comment: "Joined"), for: .normal)
                cell.joinCommunityBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "#e5e5e5")
                        cell.joinCommunityBtn.setTitleColor(.black, for: .normal)
                    }
                    else{
                        cell.joinCommunityBtn.setTitle(NSLocalizedString("Join Community", comment: "Join Community"), for: .normal)
                        cell.joinCommunityBtn.backgroundColor =  UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
//                            UIColor.hexStringToUIColor(hex: "984243")
                        cell.joinCommunityBtn.setTitleColor(.white, for: .normal)
                    }
                }
            //}
        }
     cell.backBtn.addTarget(self, action: #selector(self.Back), for: .touchUpInside)
     cell.joinCommunityBtn.addTarget(self, action: #selector(self.CommunityJoin), for: .touchUpInside)
     cell.memberBtn.addTarget(self, action: #selector(self.gotoCommunityMembers), for: .touchUpInside)
     cell.addMembersBtn.addTarget(self, action: #selector(self.inviteFriend), for: .touchUpInside)
     cell.moreBtn.addTarget(self, action: #selector(self.gotoMoreVC), for: .touchUpInside)
     //cell.editCoverBtn.addTarget(self, action: #selector(self.EditGroupCover(sender:)), for: .touchUpInside)
    //cell.editIconBtn.addTarget(self, action: #selector(self.EditGroupIcon(sender:)), for: .touchUpInside)
     return cell
    }
    else if (indexPath.section == 1){
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPostCells") as! AddPostCell
        cell.moreBtn.addTarget(self, action: #selector(self.GotoAddPost(sender:)), for: .touchUpInside)
        cell.photoBtn.addTarget(self, action: #selector(self.GotoAddPost(sender:)), for: .touchUpInside)
        cell.bind(page_data: self.communityData)
        self.tableView.rowHeight = 60.0
        return cell

    }
    else if (indexPath.section == 2){
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchPostCell
        self.tableView.rowHeight = 70.0
        return cell

    }
    else if (indexPath.section == 3){
        let cell = UITableViewCell()
        self.tableView.rowHeight = 0
        return cell
    }
    else if (indexPath.section == 4){
        let cell = UITableViewCell()
        self.tableView.rowHeight = 0
        return cell
    }
    else if (indexPath.section == 5){
        let cell = UITableViewCell()
        self.tableView.rowHeight = 0
        return cell
    }
    else {
        var cell = UITableViewCell()
        let index = self.communityPostsArray[indexPath.row]
        let postfile = index["postFile"] as? String ?? ""
        let postLink = index["postLink"] as? String ?? ""
        var live = ""
        let postYoutube = index["postYoutube"] as? String ?? ""
        let blog = index["blog_id"] as? String ?? "0"
        let community = index["community_recipient_exists"] as? Bool ??  false
        let product = index["product_id"] as? String ?? "0"
        let event = index["page_event_id"] as? String ?? "0"
        let postSticker = index["postSticker"] as? String ?? ""
        let colorId = index["color_id"] as? String ?? "0"
        let multi_image = index["multi_image"] as? String ?? "0"
        let photoAlbum = index["album_name"] as? String ?? ""
        let postOptions = index["poll_id"] as? String ?? "0"
        let postRecord = index["postRecord"] as? String ?? "0"
        if let postType = index["stream_name"] as? String{
            live = postType
        }
        
        if (postfile != "")  {
            let url = URL(string: postfile)
            let urlExtension: String? = url?.pathExtension
            if (urlExtension == "jpg" || urlExtension == "png" || urlExtension == "jpeg" || urlExtension == "JPG" || urlExtension == "PNG"){
                cell = GetPostWithImage.sharedInstance.getPostImage(targetController: self, tableView: tableView, indexpath: indexPath, postFile: postfile, array: self.communityPostsArray, url: url!, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            }
                
            else if(urlExtension == "wav" ||  urlExtension == "mp3" || urlExtension == "MP3"){
                cell = GetPostMp3.sharedInstance.getMP3(targetController: self, tableView: tableView, indexpath: indexPath, postFile: postfile, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            }
            else if (urlExtension == "pdf") {
                cell = GetPostPDF.sharedInstance.getPostPDF(targetControler: self, tableView: tableView, indexpath: indexPath, postfile: postfile, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
                
            }
                
            else {
                cell = GetPostVideo.sharedInstance.getVideo(targetController: self, tableView: tableView, indexpath: indexPath, postFile: postfile, array: self.communityPostsArray, url: url!, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            }
            
            
        }
        
        else if (live != ""){
            let cells = tableView.dequeueReusableCell(withIdentifier: "LiveCell") as! PostLiveCell
//            self.tableView.rowHeight = 350.0
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 350.0
            cells.bind(index: index, indexPath: indexPath.row)
            cells.shareBtn.isUserInteractionEnabled = true
            cells.vc = self
            cell = cells
        }
            
        else if (postLink != "") {
            cell = GetPostWithLink.sharedInstance.getPostLink(targetController: self, tableView: tableView, indexpath: indexPath, postLink: postLink, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if (postYoutube != "") {
            cell = GetPostYoutube.sharedInstance.getPostYoutub(targetController: self, tableView: tableView, indexpath: indexPath, postLink: postYoutube, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            
        }
        else if (blog != "0") {
            cell = GetPostBlog.sharedInstance.GetBlog(targetController: self, tableView: tableView, indexpath: indexPath, postFile: "", array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if (community != false){
            cell = GetPostGroup.sharedInstance.GetGroupRecipient(targetController: self, tableView: tableView, indexpath: indexPath, postFile: "", array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if (product != "0") {
            cell = GetPostProduct.sharedInstance.GetProduct(targetController: self, tableView: tableView, indexpath: indexPath, postFile: "", array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
        else if (event != "0") {
            cell = GetPostEvent.sharedInstance.getEvent(targetController: self, tableView: tableView, indexpath: indexPath, postFile: "", array:  self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            
        }
        else if (postSticker != "") {
            cell = GetPostSticker.sharedInstance.getPostSticker(targetController: self, tableView: tableView, indexpath: indexPath, postFile: postfile, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            
        }
            
        else if (colorId != "0"){
            cell = GetPostWithBg_Image.sharedInstance.postWithBg_Image(targetController: self, tableView: tableView, indexpath: indexPath, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if (multi_image != "0") {
            cell = GetPostMultiImage.sharedInstance.getMultiImage(targetController: self, tableView: tableView, indexpath: indexPath, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            
        }
            
        else if photoAlbum != "" {
            cell = getPhotoAlbum.sharedInstance.getPhoto_Album(targetController: self, tableView: tableView, indexpath: indexPath, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if postOptions != "0" {
            cell = GetPostOptions.sharedInstance.getPostOptions(targertController: self, tableView: tableView, indexpath: indexPath, array: self.communityPostsArray,stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
        }
            
        else if postRecord != ""{
            cell = GetPostRecord.sharedInstance.getPostRecord(targetController: self, tableView: tableView, indexpath: indexPath, array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            
        }
            
        else {
            cell = GetNormalPost.sharedInstance.getPostText(targetController: self, tableView: tableView, indexpath: indexPath, postFile: "", array: self.communityPostsArray, stackViewHeight: 50.0, viewHeight: 22.0, isHidden: false, viewColor: .lightGray)
            }
        return cell
    }
   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
//            if interstitial.isReady {
//                interstitial.present(fromRootViewController: self)
//                interstitial = CreateAd()
//                AppInstance.instance.addCount = 0
//            } else {
//
//                print("Ad wasn't ready")
//            }
//            interstitial.present(fromRootViewController: self)
//            interstitial = CreateAd()
//            AppInstance.instance.addCount = 0
        }
        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "AddPost", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
            vc.postType = "community"
            vc.communityId = self.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if (indexPath.section == 2){
            let storyboard = UIStoryboard(name: "Search", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SearchPostVC") as! SearchPostController
            vc.type = "community"
            vc.id = self.communityId ?? ""
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if self.isData_nil == false{
                if self.communityPostsArray.count >= 10 {
                let count = self.communityPostsArray.count
                let lastElement = count - 1
                
                if indexPath.row == lastElement {
                    spinner.startAnimating()
                    spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                    self.tableView.tableFooterView = spinner
                    self.tableView.tableFooterView?.isHidden = false
                    self.getCommunityPosts(communityId: self.id ?? "", offset: self.afterpostid)
                    self.isData_nil = true
                }
            }
        }
    }
    
    @IBAction func Back(){
       NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "load"), object: nil)
         self.navigationController?.popViewController(animated: true)
     }
     @IBAction func gotoCommunityMembers(){
         
         /*let vc = Storyboard.instantiateViewController(withIdentifier: "CommunityMemberVC") as! CommunityMembersController
         vc.communityId = self.communityId
         self.navigationController?.pushViewController(vc, animated: true)*/
     }
     
     @IBAction func inviteFriend(){
        let sb = UIStoryboard(name: "GroupsAndPages", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "InviteFriendVC") as! InviteFriendsController
        vc.communityId = self.communityId
        self.navigationController?.pushViewController(vc, animated: true)
         
     }
    
     
     @IBAction func gotoMoreVC() {
     let vc = Storyboard.instantiateViewController(withIdentifier: "CommunityMoreVC") as! CommunityMoreController
        if let communityUrl = self.communityData["url"] as? String{
            vc.communityUrl = communityUrl
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func CommunityJoin(sender:UIButton) {
       let position = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: position)!
        let cell = self.tableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as! CommunityCoverCell
        if self.isAdmin == true {
        let Storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "CommunitySettingVC") as! CommunitySettingController
            vc.communityName = self.communityName
            vc.communityTitle = self.communityTitle
            vc.privacy = self.privacy
            vc.categoryName = self.category
            vc.categoryId = self.categoryId
            vc.about = self.aboutCommunity
            vc.community_Id = self.communityId
            vc.categoryName = self.category
           self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
        if self.isJoined == false {
            self.isJoined = true
            cell.joinCommunityBtn.setTitle(NSLocalizedString("Joined", comment: "Joined"), for: .normal)
            cell.joinCommunityBtn.setTitleColor(UIColor.hexStringToUIColor(hex: "#000000"), for:.normal)
            cell.joinCommunityBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "#e5e5e5")
            JoinCommunity()
            //self.delegte.joinCommunity(isJoin: true)
        }
            
       else {
        self.isJoined = false
        cell.joinCommunityBtn.setTitle(NSLocalizedString("Join Community", comment: "Join Community"), for: .normal)
        cell.joinCommunityBtn.setTitleColor(UIColor.hexStringToUIColor(hex: "#f8f8f8"), for:.normal)
        cell.joinCommunityBtn.backgroundColor =  UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
//            UIColor.hexStringToUIColor(hex: "#984243")
        JoinCommunity()
        //self.delegte.joinCommunity(isJoin: false)
        }
    }
}
    
    
    @IBAction func EditEditcon(sender: UIButton) {
    let Storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = Storyboard.instantiateViewController(withIdentifier: "CropImageVC") as! CropImageController
            vc.delegate = self
            vc.imageType = "avatar"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func EditGroupCover (sender: UIButton) {
        let Storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "CropImageVC") as! CropImageController
        vc.delegate = self
        vc.imageType = "cover"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func uploadImage(imageType: String, image: UIImage) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! CommunityCoverCell
        switch status {
        case .unknown, .offline:
            showAlert(title: "", message: "Internet Connection Failed")
        case .online(.wwan),.online(.wiFi):
            let imageData = image.jpegData(compressionQuality: 0.1)
            if imageType == "avatar" {
                self.uploadImage(imageType: "avatar", data: (imageData ?? nil)!)
                cell.profile.image = image
            }
            else{
                self.uploadImage(imageType: "cover", data: (imageData ?? nil)!)
                cell.cover.image = image

            }
        }
    }
    
}
