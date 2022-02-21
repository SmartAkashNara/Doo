//
//  HorizontalTitleCollection.swift
//  Doo-IoT
//
//  Created by smartsense-kiran on 10/08/21.
//  Copyright © 2021 SmartSense. All rights reserved.
//

import UIKit

struct HorizontalTitleCollectionDataModel {
    var title: String = "---"
    var isSelected: Bool = false
    
    // Once stored, will be useful to operate on slider, won't require to do calculation again and again.
    var xPositionInCell: CGFloat? = nil
    var yPositionInCell: CGFloat? = nil
}

protocol HorizontalTitleCollectionProtocol {
    var dataModel: [HorizontalTitleCollectionDataModel] { get set }
}

class HorizontalTitleCollection: UIView, HorizontalTitleCollectionProtocol {
    
    enum Direction {
        case backwards, forwards, none
    }
    
    public var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        initSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
        initSetup()
    }
    
    // Performs the initial setup.
    private func setupView() {
        contentView = viewFromNibForClass()
        contentView.frame = bounds
        // contentView.backgroundColor = UIColor.clear

        // Auto-layout stuff.
        contentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        
        // Show the view.
        addSubview(contentView)
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        /* Usage for swift < 3.x
         let bundle = NSBundle(forClass: self.dynamicType)
         let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
         let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
         */
        
        return view
    }
    
    // Custom Component Work started.........................................................
    @IBOutlet weak var collectionOfTitles: UICollectionView!
    var viewSlider: UIView!
    
    // to load skeleton till content loads.
    var isShowLoader: Bool = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.isShowLoader {
                    self.viewSlider.isHidden = true // don't show it...
                    // self.viewSlider.isHidden = self.isShowLoader // if showing loader, keep it hidden, means true otherwise false.
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.viewSlider.isHidden = self.isShowLoader // if showing loader, keep it hidden, means true otherwise false.  
                    }
                }
                self.collectionOfTitles.reloadData() // show skeleton.
            }
        }
    }
    
    var aboutToSelectedIndex: Int = 0 // will help you to run time switch between indicies, while user dragging from one tab to another one.
    // This is the actual selected index.
    
    var selectedIndex: Int = 0 {
        didSet {
            self.aboutToSelectedIndex = self.selectedIndex
        }
    }
    
    var selectionChanged: ((Int)->())? = nil // inform content scroll view when selection changed by tap.
    
    // Data to operate open
    var dataModel: [HorizontalTitleCollectionDataModel] = []
    
    // for slider run time move helper properties
    var lastContentOffset: CGPoint = CGPoint.zero // This will help us to detect the movement of user, like twards right or left while paginating in horizontal collection.
    var draggingBetweenFirstGap: CGFloat? = nil // This property will help us to keep track of that user is dragging upon which gap, so we don't need to get again and again based on draggingBetweenFirstIndex property.
    var draggingBetweenSecondGap: CGFloat? = nil  // This property will help us to keep track of that user is dragging upon which gap, so we don't need to get again and again based on draggingBetweenFirstIndex property.
    var draggingBetweenFirstIndex: Int? = nil // This property will help us to keep track of that user is dragging from which index to which index.
    var draggingBetweenSecondIndex: Int? = nil  // This property will help us to keep track of that user is dragging from which index to which index.
    
    var isDraggingManually: Bool = false
    var direction: Direction = .none
    
    func initSetup() {
        configureCollectionView()
        // self.contentView.backgroundColor = .red
    }
    
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18.3, bottom: 0, right: 18.3)
        collectionOfTitles.setCollectionViewLayout(layout, animated: false)
        collectionOfTitles.backgroundColor = UIColor.clear
        collectionOfTitles.dataSource = self
        collectionOfTitles.delegate = self
        collectionOfTitles.showsHorizontalScrollIndicator = false
        collectionOfTitles.register(UINib(nibName: GroupTopOptionsCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: GroupTopOptionsCVCell.identifier)
        collectionOfTitles.reloadData()
        
        viewSlider = UIView.init(frame: CGRect.init(x: 0, y: 43, width: 16.7, height: 2.7))
        viewSlider.cornerRadius = 2.3
        viewSlider.clipsToBounds = true
        viewSlider.backgroundColor = .greenInvited
        viewSlider.isHidden = true
        self.collectionOfTitles.addSubview(viewSlider)
    }
    
    func setSliderBarAtSelectedIndex(isChangeItWithAnimation: Bool = false) {
        guard let sliderXPositionWillBe = self.dataModel[self.selectedIndex].xPositionInCell else {return}
        debugPrint("read center: \(sliderXPositionWillBe)")
        // Set position related to selected index
        func setSliderPosition() {
            var frameOfSlider = self.viewSlider.frame
            frameOfSlider.origin.x = sliderXPositionWillBe
            self.viewSlider.frame = frameOfSlider
            self.viewSlider.isHidden = false // also show it if hidden
        }
        if isChangeItWithAnimation {
            // UIView.animate(withDuration: 0.2) {
                setSliderPosition()
              //  self.layoutIfNeeded()
            //}
        }else{
            setSliderPosition()
        }
    }
    
    func resetData() {
        self.collectionOfTitles.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setSliderBarAtSelectedIndex() // set slider bar initial position.
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

// MARK:- UICollectionViewDataSource Methods
extension HorizontalTitleCollection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isShowLoader {
            return 6
        }
        else {
            return self.dataModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupTopOptionsCVCell.identifier, for: indexPath) as! GroupTopOptionsCVCell
        if isShowLoader {
            cell.showSkeletonAnimation()
        }else{
            cell.cellConfig(slideValues: self.dataModel[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isShowLoader {
            self.shift(toIndex: indexPath.row)
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            debugPrint("didSelectItemAt indexPath -> isShowLoader = true")
        }
    }
    
    func shift(toIndex index: Int) {
        guard self.selectedIndex != index else {
            debugPrint("shift(toIndex index: Int) -> Index not found")
            return }
        self.dataModel[self.selectedIndex].isSelected = false
        self.selectedIndex = index
        self.setSelectionTab(withIndexPath: IndexPath.init(row: index, section: 0)) // UI Layout reflections.
    }
    
    func setSelectionTab(withIndexPath indexPath: IndexPath, isInformCaller: Bool = true, withAnimation: Bool = true) {
        self.dataModel[indexPath.row].isSelected = true
        
        collectionOfTitles.reloadData()
        collectionOfTitles.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: withAnimation)
        collectionOfTitles.layoutSubviews()
        
        if let sliderXPositionWillBe = self.dataModel[self.selectedIndex].xPositionInCell {
            setSliderPosition(sliderXPositionWillBe: sliderXPositionWillBe)
        }else if let cell = self.collectionOfTitles.cellForItem(at: indexPath) {
            self.dataModel[self.selectedIndex].xPositionInCell = self.collectionOfTitles.convert(cell.frame, to: cell.superview).minX
            setSliderPosition(sliderXPositionWillBe: self.dataModel[self.selectedIndex].xPositionInCell!)
        }
        
        // will inform caller to react according to new selection
        if isInformCaller {
            self.selectionChanged?(indexPath.row)
        }
    }
    
    func setSliderPosition(sliderXPositionWillBe: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            var frameOfSlider = self.viewSlider.frame
            frameOfSlider.origin.x = sliderXPositionWillBe
            self.viewSlider.frame = frameOfSlider
            self.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if isShowLoader {
            return CGSize.init(width: 80, height: 28) // for skeleton
        }else{
            let content = self.dataModel[indexPath.row].title
            let width = content.sized(UIFont.Poppins.medium(13.3)).width + 23.3
            return CGSize.init(width: width, height: 28)
        }
    }
}

// MARK: - ScrollView Delegates
extension HorizontalTitleCollection {
    
    func didScrollEvent(_ scrollView: UIScrollView) {
        // Go ahead only when manual draging done by user. or don't do any workaround if not dragged manually.
        guard self.isDraggingManually else { return }
        
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        let scrollProgress = self.indexOfMajorCell(scrollView: scrollView, currentOffsetOfScrollViewMain: currentHorizontalOffset)
        // debugPrint("index to highlight: \(currentHorizontalOffset)")
        if scrollProgress.safeIndex != self.aboutToSelectedIndex {
            self.setTab(atSelectedIndex: scrollProgress.safeIndex)
        }
        
        decidePositionOfSliderWhileMoving(withScrollView: scrollView, percentMoved: scrollProgress.percentMoved)
    }
    
    func decidePositionOfSliderWhileMoving(withScrollView scrollView: UIScrollView, percentMoved: CGFloat) {
        // Don't handle 0.0 percent. Because scrollview sends 1.0
        guard percentMoved != 0.0 else {
            return
        }
        
        func moveSlider(withGap gap: CGFloat, andIndex index: Int) {
            let xValue = gap * percentMoved / 1.0
            var frameOfSlider = self.viewSlider.frame
            frameOfSlider.origin.x = (self.dataModel[index].xPositionInCell ?? 0.0) + xValue
            self.viewSlider.frame = frameOfSlider
            
            // Switch
            // debugPrint("xPosition of selected index: \(CGFloat(self.selectedIndex)*UIScreen.main.bounds.size.width)")
            // debugPrint("content off set of x: \(scrollView.contentOffset.x)")
            // debugPrint("xValue: \(frameOfSlider.origin.x)")
            let contentWidthBasedOnSelectedIndex = CGFloat(self.selectedIndex)*UIScreen.main.bounds.size.width
            switch self.direction {
            case .backwards where scrollView.contentOffset.x >= contentWidthBasedOnSelectedIndex:
                // debugPrint("clear stuff")
                self.clearSliderIndexProperties()
            case .forwards  where scrollView.contentOffset.x <= contentWidthBasedOnSelectedIndex:
                self.clearSliderIndexProperties()
            default: break
            }
            if scrollView.contentOffset.x < contentWidthBasedOnSelectedIndex {
                self.direction = .backwards
            }
            if scrollView.contentOffset.x > contentWidthBasedOnSelectedIndex {
                self.direction = .forwards
            }
        }
        
        if (self.lastContentOffset.x > scrollView.contentOffset.x) {
            // scroll to right
            // debugPrint("going towards left")
            if let draggingBetweenFirstIndex = self.draggingBetweenFirstGap,
               let draggingBetweenSecondIndex = self.draggingBetweenSecondGap{
                let gapBetweenTwoCells = draggingBetweenSecondIndex - draggingBetweenFirstIndex
                // passing draggingBetweenFirstIndex in moveSlider, beecause from draggingBetweenFirstIndex slider move
                if gapBetweenTwoCells != 0 {
                    moveSlider(withGap: CGFloat(gapBetweenTwoCells), andIndex: self.draggingBetweenFirstIndex!)
                }
            }
            else if self.dataModel.indices.contains(self.selectedIndex-1) {
                // debugPrint("work on gap between indices: \(self.selectedIndex-1): \(self.selectedIndex)")
                
                if let previousCell = self.collectionOfTitles.cellForItem(at: IndexPath.init(row: self.selectedIndex-1, section: 0)), self.dataModel[self.selectedIndex-1].xPositionInCell == nil{
                    self.dataModel[self.selectedIndex-1].xPositionInCell = self.collectionOfTitles.convert(previousCell.frame, to: previousCell.superview).minX
                }
                if let currentCell = self.collectionOfTitles.cellForItem(at: IndexPath.init(row: self.selectedIndex, section: 0)), self.dataModel[self.selectedIndex].xPositionInCell == nil{
                    self.dataModel[self.selectedIndex].xPositionInCell = self.collectionOfTitles.convert(currentCell.frame, to: currentCell.superview).minX
                }
                if let xPositionOfPreviousCell = self.dataModel[self.selectedIndex-1].xPositionInCell,
                   let xPositionOfCurrentCell = self.dataModel[self.selectedIndex].xPositionInCell{
                    // debugPrint("work on gap between indices: \(xPositionOfPreviousCell): \(xPositionOfCurrentCell)")
                    self.draggingBetweenFirstGap = xPositionOfPreviousCell // first index, to where slider will go
                    self.draggingBetweenSecondGap = xPositionOfCurrentCell// second index, from where slider started
                    self.draggingBetweenFirstIndex = self.selectedIndex-1
                    self.draggingBetweenSecondIndex = self.selectedIndex
                    let gapBetweenTwoCells = xPositionOfCurrentCell - xPositionOfPreviousCell
                    moveSlider(withGap: gapBetweenTwoCells, andIndex: (self.selectedIndex-1 >= 0) ? self.selectedIndex-1 : self.selectedIndex)
                }
            }else{
                if let xPositionOfCurrentCell = self.dataModel[self.selectedIndex].xPositionInCell,
                   let xPositionOfNextCell = self.dataModel[self.selectedIndex].xPositionInCell{
                    self.draggingBetweenFirstGap = xPositionOfCurrentCell // first index, to where slider will go
                    self.draggingBetweenSecondGap = xPositionOfNextCell // second index, from where slider started
                    let gapBetweenTwoCells = xPositionOfNextCell - xPositionOfCurrentCell
                    moveSlider(withGap: gapBetweenTwoCells, andIndex: self.selectedIndex)
                }
            }
        } else if self.lastContentOffset.x < scrollView.contentOffset.x {
            // scroll to left
            // debugPrint("going towards right")
            if let draggingBetweenFirstIndex = self.draggingBetweenFirstGap,
               let draggingBetweenSecondIndex = self.draggingBetweenSecondGap{
                let gapBetweenTwoCells = draggingBetweenSecondIndex - draggingBetweenFirstIndex
                // passing draggingBetweenFirstIndex in moveSlider, beecause from draggingBetweenFirstIndex slider move
                if gapBetweenTwoCells != 0 {
                    moveSlider(withGap: CGFloat(gapBetweenTwoCells), andIndex: self.draggingBetweenFirstIndex!)
                }
            }
            else if self.dataModel.indices.contains(self.selectedIndex+1) {
                // debugPrint("work on gap between indices: \(self.selectedIndex): \(self.selectedIndex+1)")
                
                if let nextCell = self.collectionOfTitles.cellForItem(at: IndexPath.init(row: self.selectedIndex+1, section: 0)), self.dataModel[self.selectedIndex+1].xPositionInCell == nil{
                    self.dataModel[self.selectedIndex+1].xPositionInCell = self.collectionOfTitles.convert(nextCell.frame, to: nextCell.superview).minX
                }
                if let currentCell = self.collectionOfTitles.cellForItem(at: IndexPath.init(row: self.selectedIndex, section: 0)), self.dataModel[self.selectedIndex].xPositionInCell == nil{
                    self.dataModel[self.selectedIndex].xPositionInCell = self.collectionOfTitles.convert(currentCell.frame, to: currentCell.superview).minX
                }
                if let xPositionOfCurrentCell = self.dataModel[self.selectedIndex].xPositionInCell,
                   let xPositionOfNextCell = self.dataModel[self.selectedIndex+1].xPositionInCell{
                    // debugPrint("work on gap between indices: \(xPositionOfCurrentCell): \(xPositionOfNextCell)")
                    self.draggingBetweenFirstGap = xPositionOfCurrentCell // first index, to where slider will go
                    self.draggingBetweenSecondGap = xPositionOfNextCell // second index, from where slider started
                    self.draggingBetweenFirstIndex = self.selectedIndex
                    self.draggingBetweenSecondIndex = self.selectedIndex+1
                    let gapBetweenTwoCells = xPositionOfNextCell - xPositionOfCurrentCell
                    moveSlider(withGap: gapBetweenTwoCells, andIndex: self.selectedIndex)
                }
            }else{
                if let xPositionOfCurrentCell = self.dataModel[self.selectedIndex].xPositionInCell,
                   let xPositionOfNextCell = self.dataModel[self.selectedIndex].xPositionInCell{
                    self.draggingBetweenFirstGap = xPositionOfCurrentCell // first index, to where slider will go
                    self.draggingBetweenSecondGap = xPositionOfNextCell // second index, from where slider started
                    let gapBetweenTwoCells = xPositionOfNextCell - xPositionOfCurrentCell
                    moveSlider(withGap: gapBetweenTwoCells, andIndex: self.selectedIndex)
                }
            }
        }
        self.lastContentOffset = scrollView.contentOffset
    }
    
    func didScrollDoneEvent(_ scrollView: UIScrollView, draggingStart: Bool = false) {
        if draggingStart {
            self.isDraggingManually = true // when started with dragging.
        }else{
            self.isDraggingManually = false // When done with dragging
        }
        self.clearSliderIndexProperties()
        
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        let index = self.indexOfMajorCell(scrollView: scrollView, currentOffsetOfScrollViewMain: currentHorizontalOffset).safeIndex
        self.setTab(atSelectedIndex: index, shallItScrollToItem: true)
        
        // set slider to final position.
        self.selectedIndex = index // once scroll done. set about to selected index to final index.
        self.setSliderBarAtSelectedIndex(isChangeItWithAnimation: true)
    }
    
    func clearSliderIndexProperties() {
        self.draggingBetweenFirstGap = nil // make it nil to let it occupy again when user starts dragging
        self.draggingBetweenSecondGap = nil  // make it nil to let it occupy again when user starts dragging
        self.draggingBetweenFirstIndex = nil // make it nil to let it occupy again when user starts dragging
        self.draggingBetweenSecondIndex = nil // make it nil to let it occupy again when user starts dragging
    }
    
    // calculation of current index from scrolled postion
    private func indexOfMajorCell(scrollView: UIScrollView, currentOffsetOfScrollViewMain: CGFloat) -> (safeIndex: Int, percentMoved: CGFloat) {
        let itemWidth = scrollView.frame.size.width
        
        // get proportionate value from scrolled position using current visiblke width i.e. screen width
        let proportionalOffset = currentOffsetOfScrollViewMain / itemWidth
        
        // Part only fraction value
        var integer = 0.0
        let fraction = modf(Double(proportionalOffset), &integer)
        // debugPrint("proportionalOffset: \(fraction)")
        
        let index = Int(round(proportionalOffset))
        
        let safeIndex = max(0, min(self.dataModel.count - 1, index))
        // print("proportionalOffset:\(proportionalOffset)\nindex: \(index)\nsafeIndex: \(safeIndex)\n\n")
        return (safeIndex, CGFloat(fraction))
    }
    
    // on end of scrollview main slide, the index of selected view/group will be find
    func setTab(atSelectedIndex selectedIndex: Int, shallItScrollToItem: Bool = false) {
        self.dataModel[self.aboutToSelectedIndex].isSelected = false
        self.aboutToSelectedIndex = selectedIndex // replace with new one.
        self.dataModel[selectedIndex].isSelected = true
        self.collectionOfTitles.reloadData()
        
        // Scroll to it
        if shallItScrollToItem {
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            self.collectionOfTitles.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
