//
//  RepoCollectionCell.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 8/5/20.
//  Copyright © 2020 Tuan Truong. All rights reserved.
//

import UIKit
import Reusable

final class RepoCollectionCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarURLStringImageView: UIImageView!
    
    func bindViewModel(_ viewModel: RepoItemViewModel?) {
        if let viewModel = viewModel {
            nameLabel.text = viewModel.name
            avatarURLStringImageView.setImage(with: viewModel.url)
        } else {
            nameLabel.text = ""
            avatarURLStringImageView.image = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarURLStringImageView.image = nil
    }
}
