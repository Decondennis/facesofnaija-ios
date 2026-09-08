

import Foundation
import UIKit
import Alamofire
import ZKProgressHUD
import Toast_Swift

class SharePostOnTimelineManager{
    
    func sharePostOnTimeline(userId :String, postId :String, completionBlock :@escaping (_ Success: SharePostOnTimlineModal.SharePostOnTimeline_SuccessModal?, _ AuthError: SharePostOnTimlineModal.SharePostOnTimeline_ErrorModal?, Error?)->()){
        
        let params = [
            APIClient.Params.serverKey :APIClient.SERVER_KEY.Server_Key,
            APIClient.Params.type :"share_post_on_timeline",
            APIClient.Params.userId :userId,
            APIClient.Params.id :postId
        ]
        let access_token = "&access_token=\(UserData.getAccess_Token() ?? "")"
        
        AF.request(APIClient.Share.sharePosts + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let res = response.value as? [String:Any] {
                let statusRaw = res["api_status"]
                let statusInt = (statusRaw as? Int) ?? Int((statusRaw as? String) ?? "") ?? 0
                
                if statusInt == 200 {
                    let result = SharePostOnTimlineModal.SharePostOnTimeline_SuccessModal.init(json: res)
                    completionBlock(result, nil, nil)
                } else {
                    var errorObj: SharePostOnTimlineModal.SharePostOnTimeline_ErrorModal? = nil
                    if let data = try? JSONSerialization.data(withJSONObject: res, options: []) {
                        errorObj = try? JSONDecoder().decode(SharePostOnTimlineModal.SharePostOnTimeline_ErrorModal.self, from: data)
                    }
                    if errorObj == nil {
                        let errorsDict = res["errors"] as? [String: Any]
                        let errText = (errorsDict?["error_text"] as? String) ?? (res["message"] as? String) ?? "Failed to share post"
                        let errId = (errorsDict?["error_id"] as? Int) ?? Int((errorsDict?["error_id"] as? String) ?? "0") ?? 0
                        errorObj = SharePostOnTimlineModal.SharePostOnTimeline_ErrorModal(
                            apiStatus: "\(statusInt)",
                            errors: SharePostOnTimlineModal.Errors(errorID: errId, errorText: errText)
                        )
                    }
                    completionBlock(nil, errorObj, nil)
                }
            } else {
                print("SharePostOnTimeline error: \(response.error?.localizedDescription ?? "unknown")")
                completionBlock(nil, nil, response.error)
            }
        }
    }
    
    func sharePost(post: [String: Any]?, presenter: UIViewController?) {
        guard let post = post else { return }
        let postId = (post["post_id"] as? String) ?? "\(post["post_id"] ?? "")"
        
        var topVC = presenter
        if topVC == nil {
            topVC = UIApplication.shared.keyWindow?.rootViewController
        }
        while let presented = topVC?.presentedViewController {
            topVC = presented
        }
        
        guard !postId.isEmpty && postId != "0" else {
            topVC?.view.makeToast(NSLocalizedString("Unable to find post to share", comment: ""))
            return
        }
        
        ZKProgressHUD.show()
        self.sharePostOnTimeline(userId: UserData.getUSER_ID() ?? "", postId: postId) { [weak topVC] (success, authError, error) in
            ZKProgressHUD.dismiss()
            if let success = success {
                topVC?.view.makeToast(NSLocalizedString("Post shared successfully", comment: ""))
                var userInfo: [String: Any] = ["data": success.data]
                if var dataDict = success.data as? [String: Any] {
                    if dataDict["post_id"] == nil {
                        dataDict["post_id"] = postId
                    }
                    userInfo["data"] = dataDict
                } else {
                    userInfo["data"] = ["post_id": postId]
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil, userInfo: userInfo)
            } else if let authError = authError {
                topVC?.view.makeToast(authError.errors.errorText)
            } else if let error = error {
                topVC?.view.makeToast(error.localizedDescription)
            } else {
                topVC?.view.makeToast(NSLocalizedString("Failed to share post", comment: ""))
            }
        }
    }
    
    static let sharedInstance = SharePostOnTimelineManager()
    private init() {}
}
