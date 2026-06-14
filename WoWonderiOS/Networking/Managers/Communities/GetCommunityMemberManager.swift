
import Foundation
import Alamofire



class GetCommunityMemberManager{
    
    func getCommunityMember(communityId : String,offset:String,completionBlock : @escaping (_ Success:GetCommunityMembersModel.GetCommunityMembers_SuccessModel?, _ AuthError :GetCommunityMembersModel.GetCommuityMembers_ErrorModel? , Error?)->()){
        let params = [APIClient.Params.serverKey : APIClient.SERVER_KEY.Server_Key,APIClient.Params.limit : 10,APIClient.Params.offset : offset,APIClientCustom.Params.communityId :communityId] as [String : Any]
    let access_token = "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)"
        AF.request(APIClientCustom.GetCommunityMember.getCommunityMemberApi + access_token, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.value != nil {
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatusCode = res["api_status"]  as? Any else {return}
                let apiCode = apiStatusCode as? Int
                if apiCode == 200 {
                    
                    let result = GetCommunityMembersModel.GetCommunityMembers_SuccessModel.init(json: res)
                    completionBlock(result,nil,nil)
                }
                else {
                    guard let data = try? JSONSerialization.data(withJSONObject: response.value, options: []) else {return}
                    guard let result = try? JSONDecoder().decode(GetCommunityMembersModel.GetCommuityMembers_ErrorModel.self, from: data) else {return}
                    completionBlock(nil,result,nil)
                }
                
            }
            else {
                print(response.error?.localizedDescription)
                completionBlock(nil,nil,response.error)
            }
        }

 
    }
    
    static let sharedInstance = GetCommunityMemberManager()
    private init () {}
    
}
