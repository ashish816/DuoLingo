//
//  WordGameLetterCell.swift
//  Duolingo Word Game
//
//  Created by Ashish Mishra on 7/12/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class WordGameLetterCell: UICollectionViewCell {
    
    @IBOutlet var letterLabel : UILabel!
    var cellCordinates : Point?
    
}

struct Point {
    var xCordinate : Int
    var yCordinate : Int
}
