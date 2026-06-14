

import UIKit



class CommunitySettingController: UIViewController {
  
    
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBOutlet weak var generalBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var membersBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet var navView: UIView!
    var community_Id = ""
    var communityTitle = ""
    var communityName = ""
    var categoryId = ""
    var categoryName = ""
    var privacy = "0"
    var about = ""
    
    var pageData : ForwardPageData!
    var delegate : DeleteGroupDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
        self.navView.backgroundColor = UIColor.hexStringToUIColor(hex: ControlSettings.appMainColor)
       print(self.community_Id)
        print (self.categoryName)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.settingLabel.text = NSLocalizedString("Settings", comment: "Settings")
        self.privacyBtn.setTitle("\("   ")\(NSLocalizedString("Privacy", comment: "Privacy"))", for: .normal)
        self.generalBtn.setTitle("\("   ")\(NSLocalizedString("General", comment: "General"))", for: .normal)
        self.membersBtn.setTitle("\("   ")\(NSLocalizedString("Memebers", comment: "Memebers"))", for: .normal)
        self.deleteBtn.setTitle("\("   ")\(NSLocalizedString("Delete Group", comment: "Delete Group"))", for: .normal)
        
        self.generalBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
        self.privacyBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
        self.membersBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
        self.deleteBtn.setTitleColor(UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor), for: .normal)
        
        self.generalBtn.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.privacyBtn.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.membersBtn.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        self.deleteBtn.tintColor = UIColor.hexStringToUIColor(hex: ControlSettings.buttonColor)
        
       
    }
    
    let Storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)

    
    @IBAction func Settings(_ sender: UIButton) {
        
        switch sender.tag{
        case 0:
            let vc = Storyboard.instantiateViewController(withIdentifier: "GeneralVC") as! GeneralController
            vc.group_Name = self.communityName
            vc.group_Title = self.communityTitle
            vc.categoryId = self.categoryId
            vc.categoryName = self.categoryName
            vc.about = self.about
            vc.group_Id = self.community_Id
            //vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            
            self.present(vc, animated: true, completion: nil)
        case 1:
            let vc = Storyboard.instantiateViewController(withIdentifier: "PrivacyVC") as! GroupPrivacyController
            vc.groupId = self.community_Id
            vc.privacy = self.privacy
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            self.present(vc, animated: true, completion: nil)
        case 2:
            let storyboard = UIStoryboard(name: "GroupsAndPages", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GroupMemberVC") as! GroupMembersController
            vc.groupId = self.community_Id
            self.navigationController?.pushViewController(vc, animated: true)
        
        
        case 3:
            let vc = Storyboard.instantiateViewController(withIdentifier: "DeleteVC") as! DeleteGroupController
            vc.groupId = self.community_Id
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
            //vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        default:
            print("Nothing")
        }
        
    }
    
    func deleteCommunity(groupId: String) {
        self.delegate.deleteGroup(groupId: groupId)
        self.navigationController?.popViewController(animated: true)
    
       }
    
    func editCommunity(communityName: String, communityTitle: String, about: String, Category: String, CategoryId: String) {
        self.communityName = communityName
        self.communityTitle = communityTitle
        self.categoryName = Category
        self.categoryId = CategoryId
        self.about = about
     }
     
    
    @IBAction func Back(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }


}
