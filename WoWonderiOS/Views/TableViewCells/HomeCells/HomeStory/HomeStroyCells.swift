//
//  HomeStroyCells.swift
//  WoWonderiOS
//
//  Created by Abdul Moid on 10/06/2021.
//  Copyright © 2021 clines329. All rights reserved.
//

import UIKit
import Kingfisher

class HomeStroyCells: UITableViewCell {

    var vc:HomeVC?
    let status = Reach().connectionStatus()
    var stories = [GetStoriesModel.UserDataElement]()
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "StoryCells", bundle: nil), forCellWithReuseIdentifier: "StoryCells")
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func loadStories(){
        switch status {
        case .unknown, .offline: break
          //  ZKProgressHUD.dismiss()
         //   self.view.makeToast(NSLocalizedString("Internet Connection Failed", comment: "Internet Connection Failed"))
        case .online(.wwan), .online(.wiFi):
            performUIUpdatesOnMain {
                StoriesManager.sharedInstance.getUserStories(offset: 0, limit: 10) {[weak self] (success, authError, error) in
                    if success != nil {
                //        let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! HomeStroyCells
                       // let cell = tableView.deq as! HomeStroyCells
                      //  cell.stories = success?.stories ?? []
                        self?.stories = success?.stories ?? []
                        self?.collectionView.reloadData()
                      //  self?.getSuggestedGroup(type: "groups", limit: 8)
                     //   self?.tableView.reloadData()
                    }
                    else if authError != nil {
                     //   ZKProgressHUD.dismiss()
                     //   self!.view.makeToast(authError?.errors?.errorText)
                     //   self!.showAlert(title: "", message: (authError?.errors?.errorText)!)
                    }
                    else if error  != nil {
                     //   ZKProgressHUD.dismiss()
                        print(error?.localizedDescription)
                        
                    }
                }
            }
        }
    }
    
}

extension HomeStroyCells: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCells", for: indexPath) as! StoryCells
        if indexPath.row == 0
        {
            if let imageUrl = UserData.getImage(), !imageUrl.isEmpty {
                let fullImageUrl = imageUrl.hasPrefix("http") ? imageUrl : "\(APIClient.baseURl)/\(imageUrl)"
                if let url = URL(string: fullImageUrl) {
                    cell.userProfileImageView.kf.setImage(with: url, placeholder: UIImage(named: "no-avatar"))
                } else {
                    cell.userProfileImageView.image = UIImage(named: "no-avatar")
                }
            } else {
                cell.userProfileImageView.image = UIImage(named: "no-avatar")
            }
            cell.usernameLabel.text = "Add Story"
            cell.plusImageView.isHidden = false
        }else {
            let index = stories[indexPath.row-1]
            // Use first story's thumbnail as cover, fallback to avatar
            let storyThumb = index.stories?.first?.thumbnail
            let displayUrl = storyThumb ?? index.avatar ?? index.cover ?? ""
            if !displayUrl.isEmpty {
                let fullUrl = displayUrl.hasPrefix("http") ? displayUrl : "\(APIClient.baseURl)/\(displayUrl)"
                if let url = URL(string: fullUrl) {
                    cell.userProfileImageView.kf.setImage(with: url, placeholder: UIImage(named: "no-avatar"))
                } else {
                    cell.userProfileImageView.image = UIImage(named: "no-avatar")
                }
            } else {
                cell.userProfileImageView.image = UIImage(named: "no-avatar")
            }
            cell.usernameLabel.text = index.name ?? index.username ?? "User"
            cell.plusImageView.isHidden = true
            
        }
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.vc?.showStoriesLog()
        } else {
            let index = indexPath.row - 1
            guard index < stories.count else { return }
            let storyBoard = UIStoryboard(name: "Stories", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PreStoriesItemVC") as! PreStoriesItemVC
            vc.items = stories
            vc.pageIndex = index
            vc.modalPresentationStyle = .fullScreen
            self.vc?.present(vc, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: collectionView.frame.height - 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 15, bottom: 15, right: 15)
    }
}

