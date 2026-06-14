//
//  HomeCommunities.swift
//  FacesofnaijaiOS
//
//  Created by Chibuike Mba on 12/07/2022.
//  Copyright © 2022 Facesofnaija. All rights reserved.
//

import UIKit

class HomeCommunities: UITableViewCell {

    @IBOutlet weak var communityDetailLabel: MarqueeLabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var userprofileImageView: UIImageView!
    var vc:HomeVC?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
