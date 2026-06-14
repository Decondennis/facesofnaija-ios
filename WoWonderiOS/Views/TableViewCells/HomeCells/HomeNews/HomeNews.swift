//
//  HomeCommunities.swift
//  FacesofnaijaiOS
//
//  Created by Chibuike Mba on 12/07/2022.
//  Copyright © 2022 Facesofnaija. All rights reserved.
//

import UIKit

class HomeNews: UITableViewCell {

    @IBOutlet weak var detailLabel: MarqueeLabel!
    @IBOutlet weak var label: UILabel!
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
