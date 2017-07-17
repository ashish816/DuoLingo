//
//  ViewController.swift
//  Duolingo Word Game
//
//  Created by Ashish Mishra on 7/12/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var gameDataSource : [LevelDataSource] = [LevelDataSource]()
    var currentSelectedTargets :  Int = 0
    
    var currentDataSource : LevelDataSource?
    var selectedIndexPaths  = Set<IndexPath>()
    var currentLevelIndex = 0
    
    @IBOutlet var gameCollectionView : UICollectionView!
    @IBOutlet var sourceWord : UILabel!

    var serviceCaller : ServiceCommunicator?
    var startPoint : Point?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceCaller = ServiceCommunicator()
        self.serviceCaller?.fetchWordsGameTextFile(completionHandler: { (gameData, error) in
            if error == nil {
                self.gameDataSource = gameData!
                DispatchQueue.main.async {
                    self.currentDataSource = self.gameDataSource[self.currentLevelIndex]
                    self.gameCollectionView.reloadData()
                    self.sourceWord.text = self.currentDataSource?.source
                }
            }
        })
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.minimumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(handlePan))
        self.gameCollectionView.addGestureRecognizer(panGesture)
        
    }
    
    func handlePan(gestureRecongnizer : UIGestureRecognizer) {
        
        if gestureRecongnizer.state == .began {
            self.gameCollectionView.isUserInteractionEnabled = false
            let swipeLocation = gestureRecongnizer.location(in: self.gameCollectionView)

            if let selectedIndexPath = self.gameCollectionView.indexPathForItem(at: swipeLocation) {
                let collectionViewCell = self.gameCollectionView.cellForItem(at: selectedIndexPath) as! WordGameLetterCell
                startPoint = Point(xCordinate: (collectionViewCell.cellCordinates?.xCordinate)!, yCordinate: (collectionViewCell.cellCordinates?.yCordinate)!)
                    self.highlightCellsBasedOnSelection(selectedIndex: selectedIndexPath)
                
                if !self.selectedIndexPaths.contains(selectedIndexPath){
                    self.selectedIndexPaths.insert(selectedIndexPath)
                }
            }
            
        }else if gestureRecongnizer.state == .changed {
            var tempPoint = startPoint
           
            self.unHighlightCurrentSelection(selectedIndexPaths: self.selectedIndexPaths)
            self.selectedIndexPaths.removeAll()
            
           let startIndex =  self.indexPathFromPoint(cellPoint: tempPoint!, numberOfItemsPerRow: (self.currentDataSource?.charGrid?[0].count)!)
            
            self.selectedIndexPaths.insert(startIndex)
            
            let swipeLocation = gestureRecongnizer.location(in: self.gameCollectionView)
            if let currentSelectedIndexPath = self.gameCollectionView.indexPathForItem(at: swipeLocation) {
                let collectionViewCell = self.gameCollectionView.cellForItem(at: currentSelectedIndexPath) as! WordGameLetterCell
                let currentCordinate = collectionViewCell.cellCordinates!
                
                if currentCordinate.xCordinate == tempPoint?.xCordinate {
                    
                    if currentCordinate.yCordinate > (tempPoint?.yCordinate)! {
                        while(currentCordinate.yCordinate > (tempPoint?.yCordinate)!){
                            tempPoint?.yCordinate = (tempPoint?.yCordinate)! + 1
                            self.insertPointToSelectedIndex(point: tempPoint!)
                        }
                    }else {
                        while(currentCordinate.yCordinate < (tempPoint?.yCordinate)!){
                            tempPoint?.yCordinate = (tempPoint?.yCordinate)! - 1
                            self.insertPointToSelectedIndex(point: tempPoint!)
                        }
                    }
                    
                } else if currentCordinate.yCordinate == tempPoint?.yCordinate {
                    
                    if currentCordinate.xCordinate > (tempPoint?.xCordinate)! {
                        while(currentCordinate.xCordinate > (tempPoint?.xCordinate)!){
                            tempPoint?.xCordinate = (tempPoint?.xCordinate)! + 1
                            self.insertPointToSelectedIndex(point: tempPoint!)
                        }
                        
                    }else {
                        while(currentCordinate.xCordinate < (tempPoint?.xCordinate)!){
                            tempPoint?.xCordinate = (tempPoint?.xCordinate)! - 1
                            self.insertPointToSelectedIndex(point: tempPoint!)
                        }
                    }
                }else {
                    
                    let numberOfDiagnolCells = min(abs(currentCordinate.yCordinate - (startPoint?.yCordinate)!), abs(currentCordinate.xCordinate - (startPoint?.xCordinate)!))
                    
                    
                    for i in 1...numberOfDiagnolCells  {
                        
                        var currentPoint : Point?
                        if currentCordinate.xCordinate < (startPoint?.xCordinate)! && currentCordinate.yCordinate < (startPoint?.yCordinate)! {
                             currentPoint = Point(xCordinate: (startPoint?.xCordinate)! - i , yCordinate: (startPoint?.yCordinate)! - i )
                        }else if currentCordinate.xCordinate > (startPoint?.xCordinate)! && currentCordinate.yCordinate > (startPoint?.yCordinate)! {
                             currentPoint = Point(xCordinate: (startPoint?.xCordinate)! + i , yCordinate: (startPoint?.yCordinate)! + i )
                        } else if currentCordinate.xCordinate < (startPoint?.xCordinate)! && currentCordinate.yCordinate > (startPoint?.yCordinate)! {
                           currentPoint = Point(xCordinate: (startPoint?.xCordinate)! - i , yCordinate: (startPoint?.yCordinate)! + i )
                            
                        } else if currentCordinate.xCordinate > (startPoint?.xCordinate)! && currentCordinate.yCordinate < (startPoint?.yCordinate)! {
                            currentPoint = Point(xCordinate: (startPoint?.xCordinate)! +
                                 i , yCordinate: (startPoint?.yCordinate)! - i )
                        }
                        
                       self.insertPointToSelectedIndex(point: currentPoint!)
                    }
                }
                
                for index in self.selectedIndexPaths {
                    self.highlightCellsBasedOnSelection(selectedIndex: index)
                }

            }
            
        }else if gestureRecongnizer.state == .ended {
            self.gameCollectionView.isUserInteractionEnabled = true
            self.checkIfCorrectTranslationMatched(selectedIndexes: self.selectedIndexPaths)
            self.selectedIndexPaths.removeAll()
            startPoint = nil
        }
    }
    
    func insertPointToSelectedIndex(point : Point) {
        let currentIndexPath = self.indexPathFromPoint(cellPoint: point, numberOfItemsPerRow: (self.currentDataSource?.charGrid?[0].count)!)
        
        if !self.selectedIndexPaths.contains(currentIndexPath){
            self.selectedIndexPaths.insert(currentIndexPath)
        }
    }
    
    func unHighlightCurrentSelection(selectedIndexPaths : Set<IndexPath>) {
        for IndexPath in selectedIndexPaths {
            let collectionViewCell = self.gameCollectionView.cellForItem(at: IndexPath) as! WordGameLetterCell
            collectionViewCell.backgroundColor = UIColor.lightGray
        }
    }
    
    func highlightCellsBasedOnSelection(selectedIndex: IndexPath) {
        let collectionViewCell = self.gameCollectionView.cellForItem(at: selectedIndex)
        collectionViewCell?.backgroundColor = UIColor.orange
    }
    
    func wordLocationFromSelectedIndex(selectedIndexes : Set<IndexPath>) -> String {
        var wordLocation = ""
        let indexArray = Array<IndexPath>(selectedIndexes)
        let sortedIndexes = indexArray.sorted(by: {$0.item < $1.item})
        
        for i in 0...sortedIndexes.count - 1 {
            let index = sortedIndexes[i]
            let collectionViewCell = self.gameCollectionView.cellForItem(at: index) as! WordGameLetterCell
            
            if let  cellCordinates = collectionViewCell.cellCordinates{
                let xCord = cellCordinates.xCordinate
                let yCord = cellCordinates.yCordinate
                
                if i == selectedIndexes.count - 1 {
                    wordLocation = wordLocation + "\(xCord)" + "," + "\(yCord)"
                    
                }else {
                    wordLocation = wordLocation + "\(xCord)" + "," + "\(yCord)" + ","
                }
            }
        }
        return wordLocation
    }
    
    func checkIfCorrectTranslationMatched(selectedIndexes : Set<IndexPath>) {
        
        let selectedWordsLocation = self.wordLocationFromSelectedIndex(selectedIndexes: selectedIndexes)
        
        let uniqueLocations = Array(self.currentDataSource!.wordLocations!.keys)
        
        if (uniqueLocations.contains(selectedWordsLocation)){
            for IndexPath in selectedIndexes {
               let collectionViewCell = self.gameCollectionView.cellForItem(at: IndexPath) as! WordGameLetterCell
                collectionViewCell.backgroundColor = UIColor.green
            }
            self.currentSelectedTargets = self.currentSelectedTargets + 1
            
            if self.currentSelectedTargets == uniqueLocations.count {
              self.showAlertForSuccess()
            }
        } else {
            self.unHighlightCurrentSelection(selectedIndexPaths: selectedIndexes)
        }
    }
    
    func showAlertForSuccess() {
        let successAlert = UIAlertController(title: "Success!", message: "All translations found for current word. Click Ok for next!.", preferredStyle: UIAlertControllerStyle.alert)
        
        successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.setUpNextScreen()
        }))
        present(successAlert, animated: true, completion: nil)
    }
    
    func setUpNextScreen() {
        currentLevelIndex = currentLevelIndex + 1
       
        if currentLevelIndex < self.gameDataSource.count - 1 {
            self.currentDataSource = self.gameDataSource[currentLevelIndex]
            self.currentSelectedTargets = 0
            self.gameCollectionView.reloadData()
            self.sourceWord.text = self.currentDataSource?.source
        }else {
            self.showAlert("Congratulations!", message: "You completed all levels!")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfColums = currentDataSource?.charGrid?[0].count {
            if let numberOfRows = currentDataSource?.charGrid?.count {
                return numberOfColums*numberOfRows
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordGameLetterCell", for: indexPath) as! WordGameLetterCell
        
        let numberOfColums = currentDataSource?.charGrid?[0].count
        let xCordinate = indexPath.item % numberOfColums!
        let yCordinate = indexPath.item / numberOfColums!
        
        let cellPoint =  Point(xCordinate:xCordinate , yCordinate:yCordinate)
        collectionCell.cellCordinates = cellPoint
        
        let currentChar = self.currentDataSource?.flattenedLetters[indexPath.item]
        
        collectionCell.letterLabel.text =   String(currentChar!)
        collectionCell.backgroundColor = UIColor.lightGray
        return collectionCell
    }
    
    func indexPathFromPoint(cellPoint : Point, numberOfItemsPerRow : Int)-> IndexPath {
        let currentItemPosition = numberOfItemsPerRow * cellPoint.yCordinate + cellPoint.xCordinate
        let indexPath = IndexPath(row:currentItemPosition , section: 0)
        return indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColums = currentDataSource?.charGrid?[0].count
        let widthOfCell = (self.view.frame.width)/CGFloat(numberOfColums!)-1
        return CGSize(width : widthOfCell , height: widthOfCell )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    fileprivate func showAlert(_ title : String, message : String) {
        let alertController = UIAlertController(title: title as String, message:message as String, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

