import Foundation

public struct APIClientCustom {
    public static let baseURl = "\(APIClient.baseURl)/api"
    public static let baseV2Url = "\(APIClient.baseURl)/api-v2.php"
    
    public struct Get_Community_Names {
        public static let Get_Community_Names = "\(baseURl)/communities-custom"
    }
    
    public struct ReqeustCommunity {
        public static let requestCommunityApi = "\(baseV2Url)?type=request-community"
    }
    
    public struct GetCommunityData {
        public static let getCommunitiesDataApi = "\(baseV2Url)?type=get-community-data"
    }
    
    public struct GetCommunityPost {
        public static let getCommunityPostApi = "\(baseV2Url)?type=posts"
    }
    
    public struct JoinCommunity {
        public static let joinCommunityAPi = "\(baseV2Url)?type=join-community"
    }
    
    public struct AddMembertoCommunity {
        public static let addMmembertoCommunityApi = "\(baseURl)/community_add"
    }
    
    public struct GetCommunityMember {
        public static let getCommunityMemberApi = "\(baseV2Url)?type=get_community_members"
    }
    
    public struct UpdateCommunityData {
        public static let updateCommunityDataApi = "\(baseV2Url)?type=update-community-data"
    }
    
    public struct GetCommunity {
        public static let getCommunityApi = "\(baseV2Url)?type=get-community"
    }
    
    public struct Params {
        public static let name = "name"
        public static let country = "country"
        public static let state = "state"
        public static let lga = "lga"
        public static let about = "about"
        public static let privacy = "privacy"
        public static let community_id = "community_id"
        public static let communityId = "communityId"
        public static let fetch = "fetch"
        public static let limit = "limit"
        public static let offset = "offset"
        public static let category = "category"
    }
}
