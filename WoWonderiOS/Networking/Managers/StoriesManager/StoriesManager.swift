

import Foundation
import Alamofire



class StoriesManager{
    
    func getUserStories(offset: Int, limit: Int,completionBlock :@escaping (_ Success: GetStoriesModel.StoriesScuccessModel?, _ AuthError: GetStoriesModel.StoriesErrorModel?, Error?)->()){
        let params = [
            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
            APIClient.Params.offset:offset,
            APIClient.Params.limit:limit,
        ] as [String : Any]
        let access_token = "access_token=\(UserData.getAccess_Token() ?? "")"
        let urlString = APIClient.Stories.getUserStories + "&" + access_token
        print("📖 Stories API URL: \(urlString)")
        AF.request(urlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print("📖 Stories Status: \(response.response?.statusCode ?? 0)")
            print("📖 Stories Error: \(response.error?.localizedDescription ?? "none")")
            
            if let data = response.data, let rawStr = String(data: data, encoding: .utf8) {
                print("📖 Stories Raw: \(rawStr.prefix(300))")
            }
            
            if let res = response.value as? [String:Any] {
                if let apiStatusCode = res["api_status"] as? Int, apiStatusCode == 200 {
                    // Manual JSON parsing - bypass Codable
                    var model = GetStoriesModel.StoriesScuccessModel()
                    model.apiStatus = apiStatusCode
                    if let storiesData = res["stories"] as? [[String:Any]] {
                        var users: [GetStoriesModel.UserDataElement] = []
                        for storyItem in storiesData {
                            var user = GetStoriesModel.UserDataElement()
                            user.userID = "\(storyItem["user_id"] ?? "")"
                            user.username = storyItem["username"] as? String
                            user.name = storyItem["name"] as? String
                            user.firstName = storyItem["first_name"] as? String
                            user.lastName = storyItem["last_name"] as? String
                            user.avatar = storyItem["avatar"] as? String
                            user.cover = storyItem["cover"] as? String
                            user.gender = storyItem["gender"] as? String
                            // Parse nested stories
                            var nestedStories: [GetStoriesModel.UserDataStory] = []
                            if let nested = storyItem["stories"] as? [[String:Any]] {
                                for subStory in nested {
                                    var s = GetStoriesModel.UserDataStory()
                                    s.id = "\(subStory["id"] ?? "")"
                                    s.userID = "\(subStory["user_id"] ?? "")"
                                    s.title = subStory["title"] as? String
                                    s.storyDescription = subStory["description"] as? String
                                    s.thumbnail = subStory["thumbnail"] as? String
                                    s.posted = subStory["posted"] as? String
                                    s.expire = subStory["expire"] as? String
                                    s.isOwner = (subStory["is_owner"] as? Bool)
                                    s.timeText = subStory["time_text"] as? String
                                    nestedStories.append(s)
                                }
                            }
                            user.stories = nestedStories
                            users.append(user)
                        }
                        model.stories = users
                        print("📖 Stories parsed: \(users.count) users")
                    }
                    completionBlock(model, nil, nil)
                } else {
                    completionBlock(nil, nil, nil)
                }
            } else {
                completionBlock(nil, nil, response.error)
            }
        }
    }
    func createStory(story_data:Data?,mimeType:String,type:String,text:String, completionBlock: @escaping (_ Success:CreateStoryModel.CreateStorySuccessModel?,_ AuthError:CreateStoryModel.CreateStoryErrorModel?, Error?) ->()){
        
        let params = [
            APIClient.Params.FileType : type,
            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
            APIClient.Params.text:text,
           
            ] as [String : Any]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String = \(decoded)")
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if type == "video"{
                if let data = story_data{
                    multipartFormData.append(data, withName: "file", fileName: "file.mp4", mimeType: mimeType)
                }
            }else if type == "image"{
                if let data = story_data{
                     multipartFormData.append(data, withName: "file", fileName: "image.jpg", mimeType: mimeType)
                }
            }
        }, to: APIClient.Stories.createStories +  "&access_token=\(UserData.getAccess_Token() ?? "")", usingThreshold: UInt64.init(), method: .post, headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { response in
            //Do what ever you want to do with response
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                print("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus as? Int == 200{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(CreateStoryModel.CreateStorySuccessModel.self, from: data)
                    print("Success = \(result.storyID ?? 0)")
                    completionBlock(result,nil,nil)
                }else{
                    print("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(CreateStoryModel.CreateStoryErrorModel.self, from: data)
                    print("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,result,nil)

                }

            }else{
                print("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,response.error)
            }
        })
//        }, usingThreshold: UInt64.init(), to: APIClient.Stories.createStories +  "\("?")\("access_token")\("=")\(UserData.getAccess_Token()!)", method: .post, headers: headers) { (result) in
//            switch result{
//            case .success(let upload, _, _):
//                upload.responseJSON { response in
//                    print("Succesfully uploaded")
//                    if (response.value != nil){
//                        guard let res = response.value as? [String:Any] else {return}
//                        print("Response = \(res)")
//                        guard let apiStatus = res["api_status"]  as? Any else {return}
//                        if apiStatus as? Int == 200{
//                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
//                            let result = try! JSONDecoder().decode(CreateStoryModel.CreateStorySuccessModel.self, from: data)
//                            print("Success = \(result.storyID ?? 0)")
//                            completionBlock(result,nil,nil)
//                        }else{
//                            print("apiStatus String = \(apiStatus)")
//                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
//                            let result = try! JSONDecoder().decode(CreateStoryModel.CreateStoryErrorModel.self, from: data)
//                            print("AuthError = \(result.errors!.errorText)")
//                            completionBlock(nil,result,nil)
//
//                        }
//
//                    }else{
//                        print("error = \(response.error?.localizedDescription)")
//                        completionBlock(nil,nil,response.error)
//                    }
//
//                }
//            case .failure(let error):
//                print("Error in upload: \(error.localizedDescription)")
//                completionBlock(nil,nil,error)
//
//            }
//        }
    }
    func deleteStory(storyId:Int, completionBlock: @escaping (_ Success:DeleteStoryModel.DeleteStorySuccessModel?,_ SessionError:DeleteStoryModel.DeleteStoryErrorModel?, Error?) ->()){
        
       let params = [
                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                  APIClient.Params.story_id:storyId,
                  ] as [String : Any]
              let access_token = "access_token=\(UserData.getAccess_Token() ?? "")"
        let urlString = APIClient.Stories.deleteStory + "&" + access_token
        
        AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if (response.value != nil){
                guard let res = response.value as? [String:Any] else {return}
                guard let apiStatus = res["code"]  as? Any else {return}
                if apiStatus as? Int == 200{
                    print("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value!, options: [])
                    let result = try! JSONDecoder().decode(DeleteStoryModel.DeleteStorySuccessModel.self, from: data)
                    completionBlock(result,nil,nil)
                }else{
                    print("apiStatus String = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value as Any, options: [])
                    let result = try! JSONDecoder().decode(DeleteStoryModel.DeleteStoryErrorModel.self, from: data)
                    print("AuthError = \(result.errors?.errorText ?? "")")
                    completionBlock(nil,result,nil)
                }
            }else{
                print("error = \(response.error?.localizedDescription ?? "")")
                completionBlock(nil,nil,response.error)
            }
        }
    }
    static let sharedInstance = StoriesManager()
    private init() {}
}
