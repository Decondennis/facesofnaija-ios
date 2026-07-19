
import UIKit


class CommunityListController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exploreLabel: UILabel!
    @IBOutlet weak var suggestedBtn: UIButton!

    @IBOutlet var navView: UIView!
    
    @IBOutlet var addBtn: RoundButton!
    
    var communityList = [[String:Any]]()
    var myCommunities  = [[String:Any]]()
    var joinedCommunities: [[String:Any]] = []
    var allCommunities: [[String:Any]] = []
    var suggestedCommunities: [[String:Any]] = []
    let status = Reach().connectionStatus()
    
    var offset = "0"
    var isJoined = true
    var isAdmin = false
    var selctedIndex = 0
    var isCommunityExist = 1
    
    let sectionTitles = ["My Community", "Joined Communities", "All Communities", "Suggested Communities"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.activityIndicator.color = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.addBtn.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        self.suggestedBtn.setTitle(NSLocalizedString("Suggested", comment: "Suggested"), for: .normal)
        self.suggestedBtn.isEnabled = false
        self.exploreLabel.text = NSLocalizedString("Communities", comment: "Communities")
        self.tableView.tableFooterView = UIView()
        self.activityIndicator.startAnimating()
        //        self.getGroups()
        if (AppInstance.instance.myCommunities.count != 0){
            self.myCommunities = AppInstance.instance.myCommunities
            self.tableView.reloadData()
        }
        self.getJoinedCommunities(user_id: UserData.getUSER_ID() ?? "")
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    /// Network Connectivity
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let status = userInfo["Status"] as! String
            print("Status",status)

        }
    }
    
    private func getmyGroups() {
        switch status {
        case .unknown, .offline:
            showAlert(title: "", message: "Internet Connection Failed")
        case .online(.wwan),.online(.wiFi):
            performUIUpdatesOnMain {
                GetMyGroupsManager.sharedInstance.getMyGroups(userId: UserData.getUSER_ID()!, offset: self.offset) { (success, authError, error) in
                    if success != nil {
                        print(success!.data)
                        for i in success!.data{
                            self.myCommunities.append(i)
                        }
                        //        self.myGroups = self.communityList.filter({$0["user_id"] as? String == UserData.getUSER_ID()!})
                        //            print(self.myGroups.count)
                        //        self.communityList = self.communityList.filter({$0["user_id"] as? String != UserData.getUSER_ID()!})
                        //                     print(self.communityList.count)
                        
                        self.tableView.reloadData()
                    }
                    else if authError != nil {
                        self.showAlert(title: "", message: (authError?.errors.errorText)!)
                    }
                    else if error != nil {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    private func getJoinedCommunities(user_id: String){
        self.activityIndicator.startAnimating()
        let group = DispatchGroup()
        
        group.enter()
        CommunityManager.sharedInstance.getCommunities(fetch: "joined_communities", limit: 50, offset: 0) { data, _ in
            if let d = data { self.joinedCommunities = d }
            group.leave()
        }
        
        group.enter()
        CommunityManager.sharedInstance.getCommunities(fetch: "random_communities", limit: 50, offset: 0) { data, _ in
            if let d = data { 
                self.allCommunities = d
                self.suggestedCommunities = d
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            // My communities = joined where user_id matches current user
            self.myCommunities = self.joinedCommunities.filter { ($0["user_id"] as? String) == UserData.getUSER_ID() ?? "" }
            // Community list (section 1-3 combined view)
            self.communityList = self.joinedCommunities + self.allCommunities
            self.isCommunityExist = self.communityList.isEmpty ? 0 : 1
            self.tableView.reloadData()
        }
    }
    
    private func sendJoinRequest (communityId : String) {
        performUIUpdatesOnMain {
            JoinCommunityManager.sharedInstance.joinCommunity(communityId: Int(communityId)!) { (success, authError, error) in
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
    @IBAction func SuggestedGroups(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupsDiscoverVC") as! GroupsDiscoverController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Create(_ sender: Any) {
        let vc = CommunityRequestController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    }
    
    @IBAction func Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func gotoSearch(sender: UIButton){
        let Storyboard = UIStoryboard(name: "Search", bundle: nil)
        let vc = Storyboard.instantiateViewController(withIdentifier: "SearchVC") as! UINavigationController
        let currentVc = vc.topViewController as? SearchController
        currentVc?.isFromGroup = 0
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
}
extension CommunityListController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return max(joinedCommunities.count, 1)
        case 2: return max(allCommunities.count, 1)
        case 3: return max(suggestedCommunities.count, 1)
        case 4: return 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sectionTitles.count ? sectionTitles[section] : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommunity") as! GetUserCommunity
            cell.groupArray = self.myCommunities
            cell.didSelectItemAction = {[weak self] indexPath in
                self?.gotoCommunityController(indexPath: indexPath)
            }
            cell.groupCollectionView.reloadData()
            return cell
        }
        
        if indexPath.section == 4 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "View Requested Communities"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        let data: [[String:Any]]
        switch indexPath.section {
        case 1: data = joinedCommunities
        case 2: data = allCommunities
        case 3: data = suggestedCommunities
        default: data = []
        }
        
        if data.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JoinCommunity") as! JoinedCommunityCell
            cell.noCommunityview.isHidden = false
            cell.communityView.isHidden = true
            cell.searchBtn.addTarget(self, action: #selector(self.gotoSearch(sender:)), for: .touchUpInside)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinCommunity") as! JoinedCommunityCell
        cell.noCommunityview.isHidden = true
        cell.communityView.isHidden = false
        let index = data[indexPath.row]
        if let image = index["avatar"] as? String {
            let url = URL(string: image.trimmingCharacters(in: .whitespaces))
            cell.communityIcon.kf.setImage(with: url)
        }
        if let communityName = index["community_title"] as? String {
            cell.communityName.text = communityName
        } else if let name = index["name"] as? String {
            cell.communityName.text = name
        }
        cell.joinedBtn.tag = indexPath.row
        cell.joinedBtn.addTarget(self, action: #selector(self.JoinCommunity(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.myCommunities.isEmpty ? 0 : 130
        }
        if indexPath.section == 4 {
            return 60
        }
        let data: [[String:Any]]
        switch indexPath.section {
        case 1: data = joinedCommunities
        case 2: data = allCommunities
        case 3: data = suggestedCommunities
        default: data = []
        }
        return data.isEmpty ? 350 : 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            let vc = RequestedCommunitiesController()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        guard indexPath.section > 0 else { return }
        let data: [[String:Any]]
        switch indexPath.section {
        case 1: data = joinedCommunities
        case 2: data = allCommunities
        case 3: data = suggestedCommunities
        default: data = []
        }
        guard !data.isEmpty else { return }
        let index = data[indexPath.row]
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommunityVC") as! CommunityController
        self.selctedIndex = indexPath.row
            if let communityId = index["community_id"] as? String{
                vc.communityId = communityId
            }
            if let communityName = index["community_name"] as? String{
                vc.communityName = communityName
            }
            if let communityTitle = index["community_title"] as? String{
                vc.communityTitle = communityTitle
            }
            if let communityIcon = index["avatar"] as? String{
                vc.communityIcon = communityIcon
            }
            if let communityCover = index["cover"] as? String{
                vc.communityCover = communityCover
            }
            if let communitycategory = index["category"] as? String{
                vc.category = communitycategory
            }
            if let privacy = index["privacy"] as? String{
                vc.privacy = privacy
            }
            if let categoryId = index["category_id"] as? String{
                print(categoryId)
                vc.categoryId = categoryId
            }
            
            if let about  = index["about"] as? String{
                print(about)
                vc.aboutCommunity = about
            }
            vc.isJoined = self.isJoined
            //vc.delegte1 = self
            //vc.delegate = self
            vc.communityData = index
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        if section < sectionTitles.count {
            label.text = "  \(NSLocalizedString(sectionTitles[section], comment: sectionTitles[section]))"
        } else {
            label.text = "  Requested Communities"
        }
        label.textColor = .black
        label.backgroundColor = UIColor.hexStringToUIColor(hex: "#E4E6E8")
        headerView.addSubview(label)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return self.myCommunities.isEmpty ? 0 : 50
        }
        let sectionData: [[String:Any]]
        switch section {
        case 1: sectionData = joinedCommunities
        case 2: sectionData = allCommunities
        case 3: sectionData = suggestedCommunities
        default: sectionData = []
        }
        return sectionData.isEmpty ? 0 : 50
    }
    
    func sendCommunityData(communityData: [String : Any]) {
        print("delegate")
        self.myCommunities.insert(communityData, at: 0)
        self.tableView.reloadData()
    }
    func joinCommunity(isJoin: Bool) {
        
        let indexPath = IndexPath(row: self.selctedIndex, section: 1)
        let cell = tableView.cellForRow(at: indexPath) as! JoinedCommunityCell
        if isJoin == true{
            cell.joinedBtn.setTitle(NSLocalizedString("JOINED", comment: "JOINED"), for: .normal)
            cell.joinedBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
            self.communityList[self.selctedIndex]["is_joined"] = true
            self.isJoined = true
        }
        else {
            cell.joinedBtn.setTitle(NSLocalizedString("JOIN COMMUNITY", comment: "JOIN COMMUNITY"), for: .normal)
            cell.joinedBtn.setTitleColor(UIColor.hexStringToUIColor(hex: "#000000"), for: .normal)
            self.communityList[self.selctedIndex]["is_joined"] = false
            self.isJoined = false
        }
    }
    
    
    func gotoCommunityController(indexPath:IndexPath){
        let storyboard = UIStoryboard(name: "Communities", bundle: nil)
        let vc = CommunityRequestController()
        let index = self.myCommunities[indexPath.row]
        vc.setCommunityName(index["community_name"] as? String ?? index["name"] as? String ?? "")
        vc.setDescription(index["about"] as? String ?? "")
        vc.privacy = Int(index["privacy"] as? String ?? "0") ?? 0
        /*if let groupId = index["group_id"] as? String{
            vc.groupId = groupId
        }
        if let groupName = index["group_name"] as? String{
            vc.groupName = groupName
        }
        if let groupTitle = index["group_title"] as? String{
            vc.groupTitle = groupTitle
        }
        if let groupIcon = index["avatar"] as? String{
            vc.groupIcon = groupIcon
        }
        if let groupCover = index["cover"] as? String{
            vc.groupCover = groupCover
        }
        if let groupcategory = index["category"] as? String{
            vc.category = groupcategory
        }
        if let about = index["about"] as? String{
            vc.aboutGroup = about
        }
        if let categoryId = index["category_id"] as? String{
            vc.categoryId = categoryId
        }
        vc.isAdmin = true
        vc.delegate = self
        vc.isFromList = true
        vc.groupData = index*/
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func JoinCommunity(sender : UIButton){
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section:1)) as! JoinedCommunityCell
        let index = self.communityList[sender.tag]
        var community_id: String? = nil
        if let communityId = index["community_id"] as? String{
            community_id = communityId
        }
        if let is_Joined = index["is_joined"] as? Bool{
            if is_Joined == true{
                cell.joinedBtn.setTitle(NSLocalizedString("JOIN COMMUNITY", comment: "JOIN COMMUNITY"), for: .normal)
                cell.joinedBtn.setTitleColor(UIColor.hexStringToUIColor(hex: "#000000"), for: .normal)
                self.isJoined = false
                self.sendJoinRequest(communityId: community_id ?? "")
                self.communityList[sender.tag]["is_joined"] = false
            }
            else{
                cell.joinedBtn.setTitle(NSLocalizedString("JOINED", comment: "JOINED"), for: .normal)
                cell.joinedBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
                self.isJoined = true
                self.sendJoinRequest(communityId: community_id ?? "")
                self.communityList[sender.tag]["is_joined"] = true
            }
        }
    }

}


class RequestedCommunitiesController: UITableViewController {
    
    var items: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Requested Communities"
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: " Back", style: .plain, target: self, action: #selector(goBack))
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        CommunityManager.sharedInstance.getCommunities(fetch: "requested_communities", limit: 50, offset: 0) { data, _ in
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            if let d = data { self.items = d }
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(items.count, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "No requested communities."
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            return cell
        }
        let item = items[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let name = (item["community_title"] as? String) ?? (item["community_name"] as? String ?? "Community")
        cell.textLabel?.text = name
        if let status = item["request_status"] as? String {
            cell.detailTextLabel?.text = "Status: " + status.capitalized
            cell.detailTextLabel?.textColor = status == "approved" ? .systemGreen : (status == "pending" ? .systemOrange : .systemRed)
        }
        cell.selectionStyle = .none
        return cell
    }
}
