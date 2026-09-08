

import UIKit
import Toast_Swift

struct ReactionTab {
    let type: String
    let title: String
    var count: Int
    var users: [[String:Any]]
}

class PostReactionController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reactionBtn1: UIButton!
    @IBOutlet weak var reactionBtn2: UIButton!
    @IBOutlet weak var reactionBtn3: UIButton!
    @IBOutlet weak var reactionBtn4: UIButton!
    @IBOutlet weak var reactionBtn5: UIButton!
    @IBOutlet weak var reactionBtn6: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    let status = Reach().connectionStatus()
    
    var reaction = [String:Any]()
    var Likes = [[String:Any]]()
    var Angry = [[String:Any]]()
    var HaHa = [[String:Any]]()
    var Sad = [[String:Any]]()
    var Wow = [[String:Any]]()
    var Love = [[String:Any]]()
    
    var totalCount = 0
    var likeCount = 0
    var angryCount = 0
    var hahaCount = 0
    var sadCount = 0
    var wowCount = 0
    var loveCount = 0
    var postId = ""
    var is_Comment = 0
    var reaction_Type = ""
    
    var activeTabs: [ReactionTab] = []
    var currentTag = 0
    
    private var reactionButtons: [UIButton?] {
        return [self.reactionBtn1, self.reactionBtn2, self.reactionBtn3, self.reactionBtn4, self.reactionBtn5, self.reactionBtn6]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.activityIndicator.color = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.btnView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        if self.is_Comment == 1 {
            self.reaction_Type = "comment"
        } else {
            self.reaction_Type = "post"
        }
        activityIndicator.startAnimating()
        
        self.loadReaction()
        self.getPostReaction()
    }
    
    /// Network Connectivity
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo, let status = userInfo["Status"] as? String {
            print("Status", status)
        }
    }
    
    private func parseCount(_ value: Any?) -> Int {
        if let count = value as? Int { return count }
        if let str = value as? String, let count = Int(str) { return count }
        return 0
    }
    
    private func getPostReaction() {
        switch status {
        case .unknown, .offline:
            self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan),.online(.wiFi):
            GetPostReactionManager.sharedInstance.getReactions(type: self.reaction_Type, postID: self.postId) { [weak self] (success, authError, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                if let success = success {
                    if let like = success.data["1"] as? [[String:Any]] {
                        self.Likes = like
                    }
                    if let love = success.data["2"] as? [[String:Any]] {
                        self.Love = love
                    }
                    if let haha = success.data["3"] as? [[String:Any]] {
                        self.HaHa = haha
                    }
                    if let wow = success.data["4"] as? [[String:Any]] {
                        self.Wow = wow
                    }
                    if let sad = success.data["5"] as? [[String:Any]] {
                        self.Sad = sad
                    }
                    if let angry = success.data["6"] as? [[String:Any]] {
                        self.Angry = angry
                    }
                    self.updateTabs()
                } else if let authError = authError {
                    self.view.makeToast(authError.errors.errorText)
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadReaction() {
        self.likeCount = self.parseCount(self.reaction["1"])
        self.loveCount = self.parseCount(self.reaction["2"])
        self.hahaCount = self.parseCount(self.reaction["3"])
        self.wowCount = self.parseCount(self.reaction["4"])
        self.sadCount = self.parseCount(self.reaction["5"])
        self.angryCount = self.parseCount(self.reaction["6"])
        self.totalCount = self.likeCount + self.loveCount + self.hahaCount + self.wowCount + self.sadCount + self.angryCount
        self.updateTabs()
    }
    
    private func updateTabs() {
        var tabs: [ReactionTab] = []
        let configs: [(type: String, title: String, count: Int, users: [[String:Any]])] = [
            ("1", "LIKE", self.likeCount, self.Likes),
            ("2", "LOVE", self.loveCount, self.Love),
            ("3", "HAHA", self.hahaCount, self.HaHa),
            ("4", "WOW", self.wowCount, self.Wow),
            ("5", "SAD", self.sadCount, self.Sad),
            ("6", "ANGRY", self.angryCount, self.Angry)
        ]
        
        for config in configs {
            if config.count > 0 || !config.users.isEmpty {
                tabs.append(ReactionTab(type: config.type, title: config.title, count: max(config.count, config.users.count), users: config.users))
            }
        }
        
        if tabs.isEmpty {
            tabs.append(ReactionTab(type: "1", title: "LIKE", count: 0, users: self.Likes))
        }
        
        self.activeTabs = tabs
        
        let buttons = self.reactionButtons
        for (i, btn) in buttons.enumerated() {
            guard let btn = btn else { continue }
            if i < self.activeTabs.count {
                btn.isHidden = false
                btn.isEnabled = true
                btn.setTitle(self.activeTabs[i].title, for: .normal)
                if i == self.currentTag {
                    btn.setTitleColor(.white, for: .normal)
                } else {
                    btn.setTitleColor(UIColor.hexStringToUIColor(hex: "DAC2C0"), for: .normal)
                }
            } else {
                btn.isHidden = true
                btn.isEnabled = false
                btn.setTitle("", for: .normal)
            }
        }
        
        self.collectionView.reloadData()
    }
    
    @IBAction func ReactionBtn(_ sender: UIButton) {
        let tag = sender.tag
        guard tag < self.activeTabs.count, tag < self.collectionView.numberOfItems(inSection: 0) else { return }
        let scrollDirection: UICollectionView.ScrollPosition = (tag >= self.currentTag) ? .right : .left
        self.currentTag = tag
        self.collectionView.scrollToItem(at: IndexPath(item: tag, section: 0), at: scrollDirection, animated: true)
        
        let buttons = self.reactionButtons
        for (i, btn) in buttons.enumerated() {
            if i == tag {
                btn?.setTitleColor(.white, for: .normal)
            } else {
                btn?.setTitleColor(UIColor.hexStringToUIColor(hex: "DAC2C0"), for: .normal)
            }
        }
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PostReactionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activeTabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostReactioncell", for: indexPath) as? ReactionCells else {
            return UICollectionViewCell()
        }
        if indexPath.item < self.activeTabs.count {
            cell.reactions = self.activeTabs[indexPath.item].users
        } else {
            cell.reactions = []
        }
        cell.tableView.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let pageWidth = scrollView.frame.width
            guard pageWidth > 0 else { return }
            let currentPage = Int((scrollView.contentOffset.x + (0.5 * pageWidth)) / pageWidth)
            if currentPage < self.activeTabs.count && currentPage != self.currentTag {
                self.currentTag = currentPage
                let buttons = self.reactionButtons
                for (i, btn) in buttons.enumerated() {
                    if i == currentPage {
                        btn?.setTitleColor(.white, for: .normal)
                    } else {
                        btn?.setTitleColor(UIColor.hexStringToUIColor(hex: "DAC2C0"), for: .normal)
                    }
                }
            }
        }
    }
}
