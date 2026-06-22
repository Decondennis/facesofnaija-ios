
import Foundation
import CoreLocation
class AppInstance{
    static let instance  = AppInstance()
    var profile:FetchUserModel.FetchUserSuccessModel?
//    var siteSettings:Get_Site_SettingModel.Site_Setting_SuccessModel?
    var siteSettings = [String:Any]()
    var isBackGroundSelected:Bool = false
    var  musicSelected:Bool = false
    var isAlbumVisible:Bool = false
    var locationManager: CLLocationManager!
    var addCount:Int? = 0
    var longitude:Double? = 0.0
    var latitude:Double? = 0.0
    var is_SharePost: String? = nil
    var index: Int? = nil
    var connectivity_setting = "1"
    var appColor =  "#82b53f"
    var showPayment = true
//        "#03fc0b"
//    #984243
    
    var commingBackFromAddPost = false
    var vc: String? = nil
    
    var newsFeed_data = [[String:Any]]()
    var suggested_users = [[String:Any]]()
    var suggested_groups = [[String:Any]]()
    var myGroups = [[String:Any]]()
    var suggested_communities = [[String:Any]]()
    var myCommunities = [[String:Any]]()
    var myPages = [[String:Any]]()
    
     func getProfile(){
               DispatchQueue.main.async {
                   FetchUserManager.instance.fetchProfile { (success, authError, error) in
                       if success != nil {
                        AppInstance.instance.profile = success
                        UserData.setUSER_NAME(AppInstance.instance.profile?.userData?.name)
                        UserData.setWallet(AppInstance.instance.profile?.userData?.wallet)
                        if let avatar = AppInstance.instance.profile?.userData?.avatar {
                            let fullAvatar = avatar.hasPrefix("http") ? avatar : "\(APIClient.baseURl)/\(avatar)"
                            UserData.SetImage(fullAvatar)
                        }
                        UserData.SetisPro(AppInstance.instance.profile?.userData?.isPro)
                           }
                       else if authError != nil {
                       }
                       else if error != nil {
                           print(error?.localizedDescription)
                       }
                   }
               }
       }
    
    
    
    
    func utcToLocal(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
//            "dd MMM yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
//                "dd MMM yyyy"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
