//
//  DownloadView.swift
//  OurPlanet
//
//  Created by ST21235 on 2018/05/25.
//  Copyright © 2018 Florent Pillet. All rights reserved.
//

import Foundation
import UIKit

class DownloadView: UIStackView {
    let label = UILabel()
    let progress = UIProgressView()
    
    //when superview changes, run this function
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        translatesAutoresizingMaskIntoConstraints = false
        
        //a row of arranged subviews
        axis = .horizontal
        spacing = 0
        distribution = .fillEqually
        
        if let superview = superview {
            backgroundColor = .white
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            heightAnchor.constraint(equalToConstant: 38).isActive = true
            
            label.text = "Downloads"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .lightGray
            label.textAlignment = .center
            
            progress.translatesAutoresizingMaskIntoConstraints = false
            
            let progressWrap = UIView()
            progressWrap.translatesAutoresizingMaskIntoConstraints = false
            progressWrap.backgroundColor = .lightGray
            progressWrap.addSubview(progress)
            
            progress.leftAnchor.constraint(equalTo: progressWrap.leftAnchor).isActive = true
            progress.rightAnchor.constraint(equalTo: progressWrap.rightAnchor, constant: -10).isActive = true
            progress.heightAnchor.constraint(equalToConstant: 4).isActive = true
            progress.centerYAnchor.constraint(equalTo: progressWrap.centerYAnchor).isActive = true
            
            addArrangedSubview(label)
            addArrangedSubview(progressWrap)
        }
    }
}
