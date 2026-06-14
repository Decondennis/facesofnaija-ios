
import Foundation
import Alamofire



class AddMembertoCommunityManager{
    
    func addMembertoCommunity(communityId : String,userId : String,completionBlock : @escaping (_ Success: AddMembertoCommunityModel.AddMembertoCommunity_SuccessModel?, _ AuthError : AddMembertoCommunityModel.AddMembertoCommunity_ErrorModel? , Error?)->()){
        let params = [APIClient.Params.serverKey : APIClient.SERVER_KEY.Server_Key,APIClientCustom.Params.communityId : communityId,APIClient.Params.userId:userId]
        let access_token = "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)"
        
        AF.request(APIClientCustom.AddMembertoCommunity.addMmembertoCommunityApi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
            guard let res = response.value as? [String:Any] else {return}
            guard let apiStatusCode = res["api_status"]  as? Any else {return}
            let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
        guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
        guard let result = try? JSONDecoder().decode(AddMembertoCommunityModel.AddMembertoCommunity_SuccessModel.self, from: data) else {return}
                completionBlock(result,nil,nil)
               }
                else {
            guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
            guard let result = try? JSONDecoder().decode(AddMembertoCommunityModel.AddMembertoCommunity_ErrorModel.self, from: data) else {return}
            completionBlock(nil,result,nil)
                }
              }
            
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }
    }
    
    static let sharedInstance = AddMembertoCommunityManager()
    private init() {}
    
}
