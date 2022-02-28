//
//  AddDeviceUsingQRCodeViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 15/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit
import AVFoundation

class AddDeviceUsingQRCodeViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var viewCameraDetect: UIView!
    @IBOutlet weak var stackViewScanIndicator: UIStackView!
    @IBOutlet weak var viewScanIndicator: UIView!
    @IBOutlet weak var labelErrorCapture: UILabel!
    @IBOutlet weak var imageViewCameraDetectSquare: UIImageView!
    
    @IBOutlet weak var labelScanTitle: UILabel!
    @IBOutlet weak var labelAddSeriesNumberTitle: UILabel!
    @IBOutlet weak var textFieldViewSerialNumber: DooTextfieldView!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var imageViewBottomGradient: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewScanOuterView: UIView!
    @IBOutlet weak var viewScanIndicatorAnimation: UIView!
    @IBOutlet weak var buttonRescan: UIButton!
    
    // MARK: - Variable
    var addDeviceUsingQRCodeViewModel = AddDeviceUsingQRCodeViewModel()
    var isQRCodeScanned = false
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    var onQRCodeScreen = true
    weak var addDeviceVC: AddDeviceViewController? = nil
    private var deviceModelData: DeviceDataModel? = nil
    var scanResetCount = 0
    var didLoad = true
    var scanStopTime = Date()
    
    let layerScanBar = CAGradientLayer()
    var finalYPositionOfScanLayer = 0
    let animationScanBar = CABasicAnimation(keyPath: "position.y")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureControls()
        setDefaults()
        
        // ======== Old animation code ========= //
        configureScan()
        startScanAnimation(startScanCount: scanResetCount)
        // ======== Old animation code ========= //
        
        // ======== New animation code ========= //
        setUpLayerForScanning(isFirstTime: true)
        // ======== New animation code ========= //
        
        cameraOptionPermissionCheckUp() // camera option checkup
    }
    
    func cameraOptionPermissionCheckUp() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            Utility.checkVideoCameraPermission { (isGranted) in
                if !isGranted{
                    Utility.showAlertForCameraWithSettingOption(viewControler: self,
                                                                customMessage: "Kindly allow 'Doo' app to access camera from Settings!")
                }
            }
        }else{
            self.showAlert(withMessage: cueAlert.Message.cameraAccessDenided)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        configureNavBar()
        self.onQRCodeScreen = true
        if didLoad {
            didLoad = false
        } else {
            //Usage: come back from add device screen. device already exist or etc.
            self.viewScanIndicatorAnimation.alpha = 0
//                self.resetQRCodeStuff()
        }
    }
    
    @IBAction func backActionListener(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Action listeners
extension AddDeviceUsingQRCodeViewController {
    @IBAction func nextActionListener(_ sender: UIButton) {
        view.endEditing(true)
        if validateFields() {
            if self.addDeviceUsingQRCodeViewModel.deviceData == nil{
                self.callGetDeviceDetailFromSerialNumberAPI(isNeedRedirectAddDeviceScreen: true)
            }else{
                redirectToAddDeviceScreen()
            }
            //callGetDeviceDetailFromSerialNumberAPI()
        }
    }
    
    func redirectToAddDeviceScreen(){
        guard let destView = UIStoryboard.devices.addDeviceVC, let deviceDataModel = self.addDeviceUsingQRCodeViewModel.deviceData else { return
        }
        destView.deviceData = deviceDataModel
        self.navigationController?.pushViewController(destView, animated: true)
    }
    
    func validateFields() -> Bool {
        if InputValidator.checkEmpty(value: textFieldViewSerialNumber.getText) {
            textFieldViewSerialNumber.showError(localizeFor("serial_number_is_required"))
            return false
        }
        return true
    }
}

// MARK: - User Defined Methods
extension AddDeviceUsingQRCodeViewController {
    func isValidGatewayQRCode(qrCode:String) -> Bool {
        if !qrCode.isEmpty && qrCode.hasPrefix("DO"){
            return true
        } else {
            CustomAlertView.init(title: "Gateway device QR code not valid", forPurpose: .failure).showForWhile(animated: true)
            self.navigationController?.popViewController(animated: true)
            return false
        }
    }
    
    func isValidDeviceQRCode(qrCode:String) -> Bool {
        let qr = qrCode.split(separator: "_").last ?? ""
        if !qr.isEmpty && qr.hasPrefix("DO"){
//        if !qrCode.isEmpty && qrCode.hasPrefix("DO"){
            return true
        } else {
            CustomAlertView.init(title: "QR code not valid", forPurpose: .failure).showForWhile(animated: true)
            self.navigationController?.popViewController(animated: true)
            return false
        }
    }
}

// MARK: - Scan related Methods
extension AddDeviceUsingQRCodeViewController {
    
    func configureControls() {
        applyShadow(viewScanIndicator, cornerRadius: 0, shadowOpacity: 1.0, size: CGSize(width: 0, height: 10))
        labelErrorCapture.alpha = 0
        imageViewCameraDetectSquare.image = UIImage(named: "imgCameraDetectSquare")
        viewCameraDetect.layoutIfNeeded()
        viewCameraDetect.makeRoundByCorners()
        viewScanIndicator.backgroundColor = UIColor.orangeScanIndicator
    }
    
    func setDefaults() {
        
        buttonBack.setImage(UIImage(named: "imgCrossGray"), for: .normal)
        
        labelScanTitle.font = UIFont.Poppins.regular(12)
        labelScanTitle.textColor = UIColor.blueHeading
        labelScanTitle.text = localizeFor("scan_title")
        labelScanTitle.numberOfLines = 0
        labelScanTitle.textAlignment = .center
        
        labelAddSeriesNumberTitle.font = UIFont.Poppins.regular(12)
        labelAddSeriesNumberTitle.textColor = UIColor.blueHeadingAlpha60
        labelAddSeriesNumberTitle.text = localizeFor("add_series_number_title")
        labelAddSeriesNumberTitle.numberOfLines = 0
        
        textFieldViewSerialNumber.textfieldType = .generic
        textFieldViewSerialNumber.genericTextfield?.addThemeToTextarea(localizeFor("serial_number_placeholder"))
        textFieldViewSerialNumber.genericTextfield?.clearButtonMode = .whileEditing
        textFieldViewSerialNumber.genericTextfield?.returnKeyType = .done
        textFieldViewSerialNumber.activeBehaviour = true
        textFieldViewSerialNumber.genericTextfield?.delegate = self

        //set button type Custom from storyboard
        buttonNext.setThemeAppBlueWithArrow(localizeFor("next_button"))

        buttonRescan.titleLabel?.font = UIFont.Poppins.medium(11.3)
        buttonRescan.setTitle(localizeFor("rescan_button"), for: .normal)
        buttonRescan.setTitleColor(UIColor.greenInvited, for: .normal)
        buttonRescan.addTarget(self, action: #selector(rescanActionListener(_:)), for: .touchUpInside)
        rescanButtonVisibility(text: textFieldViewSerialNumber.getText ?? "")

        imageViewBottomGradient.contentMode = .scaleToFill
        imageViewBottomGradient.image = UIImage(named: "imgGradientShape")
        
        viewContainer.cornerRadius = 10
        viewContainer.borderColor = UIColor.blueHeadingAlpha20
        viewContainer.borderWidth = 0.3
    }
    
    @objc func rescanActionListener(_ sender: UIButton) {
        print("rescanActionListener")
        resetQRCodeStuff()
        textFieldViewSerialNumber.setText = ""
        rescanButtonVisibility(text: textFieldViewSerialNumber.getText ?? "")
    }
    
    func applyShadow(_ view : UIView, cornerRadius:CGFloat = 0, shadowOpacity:CGFloat = 0.3, size:CGSize = CGSize(width: 0, height: 0)){
        view.layer.shadowColor = UIColor.orangeScanIndicator.cgColor
        view.layer.shadowOffset = size
        view.layer.shadowOpacity = Float(shadowOpacity)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = cornerRadius
    }
    
    /// Configure AVCaptureDevice, video preview Layer and sessions
    func configureScan() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            labelErrorCapture.alpha = 1
            debugPrint("Erorr in AVCaptureDevice.default(for: .video)")
            return
        }
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            let containerWidth: CGFloat = cueSize.screen.width * 0.573 //0.8
            let bezelWidth: CGFloat = 0//containerWidth * 0.1
            let viewWidth: CGFloat = containerWidth * 0.573 //0.8
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: containerWidth, height: containerWidth)
            viewCameraDetect.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Give detect area rect out of all capture area.
            let rectOfInterest = videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: CGRect(x: bezelWidth, y: bezelWidth, width: containerWidth, height: containerWidth)) // Increasing and Decreasing area of this containerWidth will going to
            captureMetadataOutput.rectOfInterest = rectOfInterest!
            
        } catch {
            print(error)
            return
        }
    }
    
    
    // ======== New animation code ========= //
    func setUpLayerForScanning(isFirstTime: Bool? = false) {
        stackViewScanIndicator.alpha = 0
        viewScanIndicator.alpha = 0
        applyShadow(viewScanIndicator, cornerRadius: 0, shadowOpacity: 1.0, size: CGSize(width: 0, height: 10))
        
        if isFirstTime == true {
            self.viewScanIndicatorAnimation.alpha = 0
        } else {
            self.viewScanIndicatorAnimation.alpha = 1
        }
        let height: CGFloat = 3
        let opacity: Float = 1.0
        let topColor = UIColor.orangeScanIndicator
        let bottomColor = UIColor.orangeScanIndicator

        self.removeAnimationLayer()
        
        layerScanBar.colors = [topColor.cgColor, bottomColor.cgColor]
        layerScanBar.opacity = opacity
        layerScanBar.name = "scanAnimationLayer"
        
        var frm = self.viewScanIndicatorAnimation.frame
        frm.size.height = height
        self.viewScanIndicatorAnimation.layer.addSublayer(layerScanBar)
        layerScanBar.frame = frm
        
        setUpAnimationForLayerOfScanning()
    }
    
    func setUpAnimationForLayerOfScanning() {
        let initialYPosition = layerScanBar.position.y
        finalYPositionOfScanLayer = Int(initialYPosition + layerScanBar.frame.size.width)
        let duration: CFTimeInterval = 2.3
    
        self.viewScanIndicatorAnimation.layer.removeAllAnimations()
        
        animationScanBar.fromValue = initialYPosition as NSNumber
        animationScanBar.toValue = finalYPositionOfScanLayer as NSNumber
        animationScanBar.duration = duration
        animationScanBar.repeatCount = .infinity
        animationScanBar.isRemovedOnCompletion = false
        animationScanBar.autoreverses = true
        layerScanBar.add(animationScanBar, forKey: "scanningBarAnimation")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var frm = self.viewScanIndicatorAnimation.frame
        frm.size.height = 3
        self.layerScanBar.frame = frm
        let initialYPosition = self.layerScanBar.position.y
        self.finalYPositionOfScanLayer = Int(initialYPosition + frm.size.width)
        self.animationScanBar.toValue = self.finalYPositionOfScanLayer as NSNumber
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.resetQRCodeStuff()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewScanIndicatorAnimation.alpha = 0
        removeAnimationLayer()
    }
    
    func removeAnimationLayer() {
        for item in self.viewScanIndicatorAnimation.layer.sublayers ?? [] where item.name == "scanAnimationLayer" {
                item.removeFromSuperlayer()
        }
    }
    
    // ======== Old animation code ========= //
    func startScanAnimation(startScanCount: Int) {
        
        /*
        if self.isQRCodeScanned, startScanCount != self.scanResetCount { return }
        UIView.animate(withDuration: 2, animations: {
            if self.isQRCodeScanned, startScanCount != self.scanResetCount {
            return }
            self.stackViewScanIndicator.alignment = .bottom
        }) { (flag) in
            if self.isQRCodeScanned, startScanCount != self.scanResetCount {
            return }

            UIView.animate(withDuration: 0.5, animations: {
                if self.isQRCodeScanned, startScanCount != self.scanResetCount {
                return }
                self.stackViewScanIndicator.alpha = 0
            }) { (flag) in
                if self.isQRCodeScanned, startScanCount != self.scanResetCount {
                return }
                self.stackViewScanIndicator.alignment = .top
                UIView.animate(withDuration: 0.1, animations: {
                    if self.isQRCodeScanned, startScanCount != self.scanResetCount {
                        return }
                    self.stackViewScanIndicator.alpha = 1
                }) { (flag) in
                    if self.isQRCodeScanned, startScanCount != self.scanResetCount {
                        return }
                    self.stackViewScanIndicator.alpha = 1
                    self.startScanAnimation(startScanCount: startScanCount)
                }
            }
        }
        */
    }
}

// MARK: - Service Methods
extension AddDeviceUsingQRCodeViewController {
    func callGetDeviceDetailFromSerialNumberAPI(isNeedRedirectAddDeviceScreen:Bool=false) {
        API_LOADER.show(animated: true)
        guard let serialNumber = textFieldViewSerialNumber.getText else { return }
        guard !self.addDeviceUsingQRCodeViewModel.isAPIStillWorking else { return }
        self.addDeviceUsingQRCodeViewModel.isAPIStillWorking = true
        addDeviceUsingQRCodeViewModel.callGetDeviceDetailFromSerialNumberAPI(serialNumber: serialNumber) {
            API_LOADER.dismiss(animated: true)
            self.captureSession?.stopRunning()
            // ======== New animation code ========= //
            self.viewScanIndicatorAnimation.alpha = 0
            self.removeAnimationLayer()
            // ======== New animation code ========= //
            debugPrint(serialNumber)
             CustomAlertView.init(title: "QR code scanned successfully.",forPurpose: .success).showForWhile(animated: true)
            self.addDeviceUsingQRCodeViewModel.isAPIStillWorking = false
            if isNeedRedirectAddDeviceScreen{
                self.redirectToAddDeviceScreen()
            }
        } failureMessageBlock: { msg in
            CustomAlertView.init(title: msg, forPurpose: .failure).showForWhile(animated: true)
        } failureInform: {
            API_LOADER.dismiss(animated: true)
            self.addDeviceUsingQRCodeViewModel.isAPIStillWorking = false
            self.resetQRCodeStuff()
            self.textFieldViewSerialNumber.setText = serialNumber
            self.rescanButtonVisibility(text: self.textFieldViewSerialNumber.getText ?? "")
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
extension AddDeviceUsingQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !isQRCodeScanned{
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects.count == 0 {
                CustomAlertView.init(title: "QR code not valid", forPurpose: .failure).showForWhile(animated: true)
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            // Get the metadata object.
            if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject{
                if supportedCodeTypes.contains(metadataObj.type) {
                    // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                    if metadataObj.stringValue != nil {
                        
                        /// ======== Old animation code ========= //
                        isQRCodeScanned = true
                        scanResetCount += 1
                        viewScanIndicator.alpha = 0
                        // ======== Old animation code ========= //
                        
                        // ======== New animation code ========= //
                        viewScanIndicatorAnimation.alpha = 0
                        removeAnimationLayer()
                        // ======== New animation code ========= //
                        
                        captureSession?.stopRunning()
                        scanStopTime = Date()
                        
                        let qrCode = (metadataObj.stringValue ?? "")
                        debugPrint("Captured Value : \(metadataObj.stringValue ?? "")")
                        
                        if onQRCodeScreen{
                            if isValidDeviceQRCode(qrCode: qrCode){
                                // textFieldViewSerialNumber.setText = qrCode
                                textFieldViewSerialNumber.setText = String(qrCode.split(separator: "_").last ?? "")
                                rescanButtonVisibility(text: self.textFieldViewSerialNumber.getText ?? "")

//                                callGetDeviceDetailFromSerialNumberAPI()
                            }else{
                                resetQRCodeStuff()
                                
                                CustomAlertView.init(title: "QR code not valid", forPurpose: .failure).showForWhile(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Put 2 sec delay. because on going animation max time is 2 sec. after complete that amiation we can start new one. otherwise on going animation call startScanAnimation() & below code will also call startScanAnimation. two parallal cycle will start(that creating animation issue)
    //Here scanResetCount will help to identify new cycle of animation.
    // Remember one thing whenever you stop anmiation via this flag "isQRCodeScanned = true" increase scanResetCount
    //    isQRCodeScanned = true
    //    scanResetCount += 1
    func resetQRCodeStuff() {

        addDeviceUsingQRCodeViewModel.deviceData = nil
        isQRCodeScanned = false
        viewScanIndicator.alpha = 0
        captureSession?.startRunning() // let it start again

        // ======== New animation code ========= //
        self.viewScanIndicatorAnimation.alpha = 1
        self.setUpLayerForScanning()
        // ======== New animation code ========= //
    }
}

// MARK: - UITextFieldDelegate
extension AddDeviceUsingQRCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.getSearchText(range: range, replacementString: string)
        rescanButtonVisibility(text: text)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        rescanButtonVisibility(text: "")
        return true
    }
    
    func rescanButtonVisibility(text: String) {
        self.buttonRescan.alpha = text.isEmpty.isHiddenToAlpha
    }
    
}
