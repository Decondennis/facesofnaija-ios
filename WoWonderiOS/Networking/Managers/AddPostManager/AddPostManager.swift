

import Foundation
import Alamofire

import ZKProgressHUD

class AddPostManager{
    
    static let instance = AddPostManager()
    
    func parseError(from json: Any?) -> AddPostModel.AddPostErrorModel {
        if let dict = json as? [String: Any] {
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let model = try? JSONDecoder().decode(AddPostModel.AddPostErrorModel.self, from: data) {
                return model
            }
            var errText = "Something went wrong. Please try again."
            if let errors = dict["errors"] as? [String: Any], let msg = errors["error_text"] as? String {
                errText = msg
            } else if let msg = dict["error_text"] as? String {
                errText = msg
            } else if let msg = dict["message"] as? String {
                errText = msg
            }
            let status = "\(dict["api_status"] ?? "")"
            return AddPostModel.AddPostErrorModel(apiStatus: status, errors: AddPostModel.Errors(errorID: "", errorText: errText))
        }
        return AddPostModel.AddPostErrorModel(apiStatus: "400", errors: AddPostModel.Errors(errorID: "", errorText: "An unknown error occurred."))
    }

    func handleResponse(value: Any?, error: Error?, completionBlock: @escaping (_ Success: AddPostModel.AddPostSuccessModel?, _ AuthError: AddPostModel.AddPostErrorModel?, Error?) -> ()) {
        if let res = value as? [String: Any] {
            let apiStatusCode = res["api_status"]
            if (apiStatusCode as? Int == 200) || (apiStatusCode as? String == "200") {
                let result = AddPostModel.AddPostSuccessModel.init(json: res)
                completionBlock(result, nil, nil)
            } else {
                let errModel = self.parseError(from: res)
                completionBlock(nil, errModel, nil)
            }
        } else {
            completionBlock(nil, nil, error)
        }
    }
    
    func addPostText(userID:String,postText:String, postColor:String,postPrivacy:Int,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String,completionBlock :@escaping (_ Success: AddPostModel.AddPostSuccessModel?, _ AuthError: AddPostModel.AddPostErrorModel?, Error?)->()){
        var param =  [String : Any]()
        if postType == "page"{
             param = [
            
            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
            APIClient.Params.userId:userID,
            APIClient.Params.s:UserData.getAccess_Token() ?? "",
            APIClient.Params.postText:postText,
            APIClient.Params.post_color:postColor,
            APIClient.Params.postPrivacy:postPrivacy,
                APIClient.Params.page_id:pageID ?? "","postMap":location
            ]
        }else if postType == "group"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                        APIClient.Params.group_id:groupID ?? "","postMap":location
                      ]
            
        }else if postType == "community"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                        APIClientCustom.Params.community_id:communityID ?? "","postMap":location
                      ]
            
        }else if postType == "event"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                        APIClient.Params.event_id:eventID ?? "","postMap":location
                      ]
        }else{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,"postMap":location
                      ]
        }
        
        param["text"] = postText
        param["post_privacy"] = postPrivacy
        print("PARAMS= \(param)")
        print("URL",APIClient.AddPost.AddPostApi)
        let url = APIClient.AddPost.AddPostApi + "&access_token=\(UserData.getAccess_Token() ?? "")"
        AF.request(url, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response.value as Any)
            self.handleResponse(value: response.value, error: response.error, completionBlock: completionBlock)
        }
    }
    
    func addImages(userID:String,postText:String, postColor:String,postPrivacy:Int,imageDataArray:[Data]?,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String, completionBlock: @escaping (_ Success:AddPostModel.AddPostSuccessModel?,_ AuthError:AddPostModel.AddPostErrorModel?, Error?) ->()){
        
       var param =  [String : Any]()
        if postType == "page"{
             param = [
            
            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
            APIClient.Params.userId:userID,
            APIClient.Params.s:UserData.getAccess_Token() ?? "",
            APIClient.Params.postText:postText,
            APIClient.Params.post_color:postColor,
            APIClient.Params.postPrivacy:postPrivacy,
            APIClient.Params.page_id:pageID ?? "","postMap":location
            ]
        }else if postType == "group"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                      APIClient.Params.group_id:groupID ?? "","postMap":location
                      ]
            
        }else if postType == "community"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                      APIClientCustom.Params.community_id:communityID ?? "","postMap":location
                      ]
            
        }else if postType == "event"{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                      APIClient.Params.event_id:eventID ?? "","postMap":location
                      ]
        }else{
            param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,"postMap":location
                      
                      ]
        }
        
        param["text"] = postText
        param["post_privacy"] = postPrivacy
        if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []),
           let decoded = String(data: jsonData, encoding: .utf8) {
            print("Decoded String = \(decoded)")
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in
            print("============")
            print("1")
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            print("============")
            print("2")
            if (imageDataArray?.count ?? 0) > 1 {
                for (index, data) in (imageDataArray ?? []).enumerated(){
                    multipartFormData.append(data, withName: "postPhotos[\(index)]", fileName: "file.jpg", mimeType: "image/png")
                }
            } else if let data = imageDataArray?.first {
                multipartFormData.append(data, withName: "postPhotos", fileName: "file.jpg", mimeType: "image/png")
            }
            print("============")
            print("3")
        }, to: APIClient.AddPost.AddPostMediaApi + "&access_token=\(UserData.getAccess_Token() ?? "")", method: .post).responseJSON { (result) in
            switch result.result {
            case .success(let value):
                self.handleResponse(value: value, error: nil, completionBlock: completionBlock)
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completionBlock(nil, nil, error)
            }
        }
    }
    func addVideo(userID:String,postText:String, postColor:String,postPrivacy:Int,videoData:Data?,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String, completionBlock: @escaping (_ Success:AddPostModel.AddPostSuccessModel?,_ AuthError:AddPostModel.AddPostErrorModel?, Error?) ->()){
           
         var param =  [String : Any]()
                  if postType == "page"{
                       param = [
                      
                      APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                      APIClient.Params.userId:userID,
                      APIClient.Params.s:UserData.getAccess_Token() ?? "",
                      APIClient.Params.postText:postText,
                      APIClient.Params.post_color:postColor,
                      APIClient.Params.postPrivacy:postPrivacy,
                        APIClient.Params.page_id:pageID ?? "","postMap":location
                      ]
                  }else if postType == "group"{
                      param = [
                                
                                APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                APIClient.Params.userId:userID,
                                APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                APIClient.Params.postText:postText,
                                APIClient.Params.post_color:postColor,
                                APIClient.Params.postPrivacy:postPrivacy,
                                APIClient.Params.group_id:groupID ?? "","postMap":location
                                ]
                      
                  }else if postType == "community"{
                      param = [
                                
                                APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                APIClient.Params.userId:userID,
                                APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                APIClient.Params.postText:postText,
                                APIClient.Params.post_color:postColor,
                                APIClient.Params.postPrivacy:postPrivacy,
                                APIClientCustom.Params.community_id:communityID ?? "","postMap":location
                                ]
                      
                  }else if postType == "event"{
                      param = [
                                
                                APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                APIClient.Params.userId:userID,
                                APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                APIClient.Params.postText:postText,
                                APIClient.Params.post_color:postColor,
                                APIClient.Params.postPrivacy:postPrivacy,
                                  APIClient.Params.event_id:eventID ?? "","postMap":location
                                ]
                  }else{
                      param = [
                                
                                APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                APIClient.Params.userId:userID,
                                APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                APIClient.Params.postText:postText,
                                APIClient.Params.post_color:postColor,
                                APIClient.Params.postPrivacy:postPrivacy,"postMap":location
                                ]
                   }
            
            param["text"] = postText
            param["post_privacy"] = postPrivacy
            if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []),
               let decoded = String(data: jsonData, encoding: .utf8) {
                print("Decoded String = \(decoded)")
            }
            
            AF.upload(multipartFormData: { (multipartFormData) in
               for (key, value) in param {
                   multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
               }
              if let data = videoData{
                            multipartFormData.append(data, withName: "postVideo", fileName: "video.mp4", mimeType: "video/mp4")
                         }
                          
            }, to: APIClient.AddPost.AddPostMediaApi + "&access_token=\(UserData.getAccess_Token() ?? "")", method: .post).responseJSON { (result) in
            switch result.result {
            case .success(let value):
                self.handleResponse(value: value, error: nil, completionBlock: completionBlock)
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completionBlock(nil, nil, error)
            }
        }
    }
    func postGiF(userID:String,postText:String, postColor:String,postPrivacy:Int,GIFUrl:String,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String,completionBlock :@escaping (_ Success: AddPostModel.AddPostSuccessModel?, _ AuthError: AddPostModel.AddPostErrorModel?, Error?)->()){
        var param =  [String : Any]()
                         if postType == "page"{
                              param = [
                             
                             APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                             APIClient.Params.userId:userID,
                             APIClient.Params.s:UserData.getAccess_Token() ?? "",
                             APIClient.Params.postText:postText,
                             APIClient.Params.post_color:postColor,
                             APIClient.Params.postPrivacy:postPrivacy,
                               APIClient.Params.page_id:pageID ?? "",
                                APIClient.Params.postSticker:GIFUrl,"postMap":location

                             ]
                         }else if postType == "group"{
                             param = [
                                       
                                       APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                       APIClient.Params.userId:userID,
                                       APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                       APIClient.Params.postText:postText,
                                       APIClient.Params.post_color:postColor,
                                       APIClient.Params.postPrivacy:postPrivacy,
                                         APIClient.Params.group_id:groupID ?? "",
                                         APIClient.Params.postSticker:GIFUrl,"postMap":location

                                       ]
                             
                         }else if postType == "community"{
                             param = [
                                       
                                       APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                       APIClient.Params.userId:userID,
                                       APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                       APIClient.Params.postText:postText,
                                       APIClient.Params.post_color:postColor,
                                       APIClient.Params.postPrivacy:postPrivacy,
                                         APIClientCustom.Params.community_id:communityID ?? "",
                                         APIClient.Params.postSticker:GIFUrl,"postMap":location

                                       ]
                             
                         }else if postType == "event"{
                             param = [
                                       
                                       APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                       APIClient.Params.userId:userID,
                                       APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                       APIClient.Params.postText:postText,
                                       APIClient.Params.post_color:postColor,
                                       APIClient.Params.postPrivacy:postPrivacy,
                                         APIClient.Params.event_id:eventID ?? "",
                                    APIClient.Params.postSticker:GIFUrl,"postMap":location

                                       ]
                         }else{
                             param = [
                                       
                                       APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                       APIClient.Params.userId:userID,
                                       APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                       APIClient.Params.postText:postText,
                                       APIClient.Params.post_color:postColor,
                                       APIClient.Params.postPrivacy:postPrivacy,
                                       APIClient.Params.postSticker:GIFUrl,"postMap":location

                                       
                                       ]
                         }
        
        param["text"] = postText
        param["post_privacy"] = postPrivacy
        print("PARAMS= \(param)")
        let url = APIClient.AddPost.AddPostMediaApi + "&access_token=\(UserData.getAccess_Token() ?? "")"
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            self.handleResponse(value: response.value, error: response.error, completionBlock: completionBlock)
        }
      }
    func postMusic(userID:String,postText:String, postColor:String,postPrivacy:Int,musicData:Data?,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String,completionBlock: @escaping (_ Success:AddPostModel.AddPostSuccessModel?,_ AuthError:AddPostModel.AddPostErrorModel?, Error?) ->()){
              
               var param =  [String : Any]()
                              if postType == "page"{
                                   param = [
                                  
                                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                  APIClient.Params.userId:userID,
                                  APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                  APIClient.Params.postText:postText,
                                  APIClient.Params.post_color:postColor,
                                  APIClient.Params.postPrivacy:postPrivacy,
                                    APIClient.Params.page_id:pageID ?? "","postMap":location
                                  ]
                              }else if postType == "group"{
                                  param = [
                                            
                                            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                            APIClient.Params.userId:userID,
                                            APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                            APIClient.Params.postText:postText,
                                            APIClient.Params.post_color:postColor,
                                            APIClient.Params.postPrivacy:postPrivacy,
                                              APIClient.Params.group_id:groupID ?? "","postMap":location
                                            ]
                                  
                              }else if postType == "community"{
                                  param = [
                                            
                                            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                            APIClient.Params.userId:userID,
                                            APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                            APIClient.Params.postText:postText,
                                            APIClient.Params.post_color:postColor,
                                            APIClient.Params.postPrivacy:postPrivacy,
                                              APIClientCustom.Params.community_id:communityID ?? "","postMap":location
                                            ]
                                  
                              }else if postType == "event"{
                                  param = [
                                            
                                            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                            APIClient.Params.userId:userID,
                                            APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                            APIClient.Params.postText:postText,
                                            APIClient.Params.post_color:postColor,
                                            APIClient.Params.postPrivacy:postPrivacy,
                                              APIClient.Params.event_id:eventID ?? "","postMap":location
                                            ]
                              }else{
                                  param = [
                                            
                                            APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                            APIClient.Params.userId:userID,
                                            APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                            APIClient.Params.postText:postText,
                                            APIClient.Params.post_color:postColor,
                                            APIClient.Params.postPrivacy:postPrivacy,"postMap":location
                                            
                                            
                                            ]
                              }
              
              param["text"] = postText
              param["post_privacy"] = postPrivacy
              if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []),
                 let decoded = String(data: jsonData, encoding: .utf8) {
                  print("Decoded String = \(decoded)")
              }
              
              AF.upload(multipartFormData: { (multipartFormData) in
                  for (key, value) in param {
                      multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                  }
                 if let data = musicData{
                               multipartFormData.append(data, withName: "postMusic", fileName: "music.mp3", mimeType: "audio/mp3")
                            }
                           
              }, with: APIClient.AddPost.AddPostMediaApi as! URLRequestConvertible).uploadProgress(queue: .main, closure: { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    self.handleResponse(value: value, error: nil, completionBlock: completionBlock)
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    completionBlock(nil, nil, error)
                }
            })
          }
    func postFIle(userID:String,postText:String, postColor:String,postPrivacy:Int,fileData:Data?,extension1:String,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String, completionBlock: @escaping (_ Success:AddPostModel.AddPostSuccessModel?,_ AuthError:AddPostModel.AddPostErrorModel?, Error?) ->()){
        
          var param =  [String : Any]()
                                    if postType == "page"{
                                         param = [
                                        
                                        APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                        APIClient.Params.userId:userID,
                                        APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                        APIClient.Params.postText:postText,
                                        APIClient.Params.post_color:postColor,
                                        APIClient.Params.postPrivacy:postPrivacy,
                                          APIClient.Params.page_id:pageID ?? "",
                                        ]
                                    }else if postType == "group"{
                                        param = [
                                                  
                                                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                  APIClient.Params.userId:userID,
                                                  APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                  APIClient.Params.postText:postText,
                                                  APIClient.Params.post_color:postColor,
                                                  APIClient.Params.postPrivacy:postPrivacy,
                                                    APIClient.Params.group_id:groupID ?? "",
                                                  ]
                                        
                                    }else if postType == "community"{
                                        param = [
                                                  
                                                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                  APIClient.Params.userId:userID,
                                                  APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                  APIClient.Params.postText:postText,
                                                  APIClient.Params.post_color:postColor,
                                                  APIClient.Params.postPrivacy:postPrivacy,
                                                    APIClientCustom.Params.community_id:communityID ?? "",
                                                  ]
                                        
                                    }else if postType == "event"{
                                        param = [
                                                  
                                                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                  APIClient.Params.userId:userID,
                                                  APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                  APIClient.Params.postText:postText,
                                                  APIClient.Params.post_color:postColor,
                                                  APIClient.Params.postPrivacy:postPrivacy,
                                                    APIClient.Params.event_id:eventID ?? "",
                                                  ]
                                    }else{
                                        param = [
                                                  
                                                  APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                  APIClient.Params.userId:userID,
                                                  APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                  APIClient.Params.postText:postText,
                                                  APIClient.Params.post_color:postColor,
                                                  APIClient.Params.postPrivacy:postPrivacy,
                                                  
                                                  
                                                  ]
                                    }
        
        param["text"] = postText
        param["post_privacy"] = postPrivacy
        if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []),
           let decoded = String(data: jsonData, encoding: .utf8) {
            print("Decoded String = \(decoded)")
        }
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
           if let data = fileData{
                         multipartFormData.append(data, withName: "postFile", fileName: "file.\(extension1)", mimeType: "file/\(extension1)")
                      }
                     
        }, with: APIClient.AddPost.AddPostMediaApi as! URLRequestConvertible).uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let value):
                self.handleResponse(value: value, error: nil, completionBlock: completionBlock)
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completionBlock(nil, nil, error)
            }
        })
//                    print("response = \(response.value)")
//                    if (response.value != nil){
//                        guard let res = response.value as? [String:Any] else {return}
//                        print("Response = \(res)")
//                        guard let apiStatusCode = res["api_status"] as? Any else {return}
//                        if (apiStatusCode as? Int == 200) || (apiStatusCode as? String == "200") {
//                            print("apiStatus Int = \(apiStatusCode)")
//                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
//                            let result = AddPostModel.AddPostSuccessModel.init(json: res)
//
////                            let result = try! JSONDecoder().decode(AddPostModel.AddPostSuccessModel.self, from: data)
////                            print("Success = \(result.apiText ?? "")")
//                            completionBlock(result,nil,nil)
//                        }else{
//                            print("apiStatus String = \(apiStatusCode)")
//                            let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
//                            let result = try! JSONDecoder().decode(AddPostModel.AddPostErrorModel.self, from: data)
//                            print("AuthError = \(result.errors?.errorText ?? "unknown")")
//                            completionBlock(nil,result,nil)
//
//                        }
//
//                    }else{
//                        print("error = \(response.error?.localizedDescription)")
//                        completionBlock(nil,nil,response.error)
//                    }
//                }
//            case .failure(let error, _, _):
//                print("Error in upload: \(error.localizedDescription)")
//                completionBlock(nil,nil,error)
//
//            }
    }
    func addFeeling(userID:String,postText:String, postColor:String,postPrivacy:Int,feelingName:String,feelingType:String,pageID:String?,groupID:String?,communityID:String?,eventID:String?,postType:String,location:String,completionBlock :@escaping (_ Success: AddPostModel.AddPostSuccessModel?, _ AuthError: AddPostModel.AddPostErrorModel?, Error?)->()){
        var param =  [String : Any]()
                                          if postType == "page"{
                                               param = [
                                              
                                              APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                              APIClient.Params.userId:userID,
                                              APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                              APIClient.Params.postText:postText,
                                              APIClient.Params.post_color:postColor,
                                              APIClient.Params.postPrivacy:postPrivacy,
                                                APIClient.Params.page_id:pageID ?? "",
                                                APIClient.Params.feeling:feelingName,
                                                APIClient.Params.feeling_type:feelingType,"postMap":location
                                              ]
                                          }else if postType == "group"{
                                              param = [
                                                        
                                                        APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                        APIClient.Params.userId:userID,
                                                        APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                        APIClient.Params.postText:postText,
                                                        APIClient.Params.post_color:postColor,
                                                        APIClient.Params.postPrivacy:postPrivacy,
                                                          APIClient.Params.group_id:groupID ?? "",
                                                          APIClient.Params.feeling:feelingName,
                                                          APIClient.Params.feeling_type:feelingType,"postMap":location
                                                        ]
                                              
                                          }else if postType == "community"{
                                              param = [
                                                        
                                                        APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                        APIClient.Params.userId:userID,
                                                        APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                        APIClient.Params.postText:postText,
                                                        APIClient.Params.post_color:postColor,
                                                        APIClient.Params.postPrivacy:postPrivacy,
                                                          APIClientCustom.Params.community_id:communityID ?? "",
                                                          APIClient.Params.feeling:feelingName,
                                                          APIClient.Params.feeling_type:feelingType,"postMap":location
                                                        ]
                                              
                                          }else if postType == "event"{
                                              param = [
                                                        
                                                        APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                        APIClient.Params.userId:userID,
                                                        APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                        APIClient.Params.postText:postText,
                                                        APIClient.Params.post_color:postColor,
                                                        APIClient.Params.postPrivacy:postPrivacy,
                                                          APIClient.Params.event_id:eventID ?? "",
                                                          APIClient.Params.feeling:feelingName,
                                                          APIClient.Params.feeling_type:feelingType,"postMap":location
                                                        ]
                                          }else{
                                              param = [
                                                        
                                                        APIClient.Params.serverKey:APIClient.SERVER_KEY.Server_Key,
                                                        APIClient.Params.userId:userID,
                                                        APIClient.Params.s:UserData.getAccess_Token() ?? "",
                                                        APIClient.Params.postText:postText,
                                                        APIClient.Params.post_color:postColor,
                                                        APIClient.Params.postPrivacy:postPrivacy,
                                                        APIClient.Params.feeling:feelingName,
                                                        APIClient.Params.feeling_type:feelingType,"postMap":location
                                                        ]
                                          }
          
          
            param["text"] = postText
            param["post_privacy"] = postPrivacy
            print("PARAMS= \(param)")
            let url = APIClient.AddPost.AddPostApi + "&access_token=\(UserData.getAccess_Token() ?? "")"
            AF.request(url, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                self.handleResponse(value: response.value, error: response.error, completionBlock: completionBlock)
            }
       }
      
}
