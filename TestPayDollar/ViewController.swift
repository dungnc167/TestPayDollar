//
//  ViewController.swift
//  TestPayDollar
//
//  Created by Squall on 21/09/2021.
//

import UIKit
import Stevia
import AP_PaySDK
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    fileprivate lazy var btnUnionPay: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Union Pay", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        btn.tag = 1
        return btn
    }()
    
    fileprivate lazy var btnOctopus: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Octopus", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        btn.tag = 2
        return btn
    }()
    
    fileprivate lazy var vButtonStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [btnUnionPay, btnOctopus])
        sv.axis = .vertical
        sv.spacing = 16
        sv.distribution = .equalSpacing
        return sv
    }()
    
    var paySDK = PaySDK.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.subviews(vButtonStack)
        vButtonStack.centerVertically().centerHorizontally().width(100).height(116)
        
        view.backgroundColor = .white
        [btnUnionPay, btnOctopus].forEach {
            $0.borderColor = .black
            $0.layer.borderWidth = 1
        }
        paySDK.delegate = self
        paySDK.isBioMetricRequired = false
        paySDK.useSDKProgressScreen = true
        
        let locationManager: CLLocationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    @objc func buttonAction(sender: UIButton) {
        let btn = sender
        var channelType: PayChannel = .WEBVIEW
        var payMethod: String = ""
        switch btn.tag {
        case 1: payMethod = "UPOP"
        case 2:
            channelType = .DIRECT
            payMethod = "OCTOPUS"
        default: break
        }
        
        paySDK.paymentDetails = PayData(channelType: channelType,
                                        envType: EnvType.SANDBOX,
                                        amount : "130",
                                        payGate: .PAYDOLLAR,
                                        currCode: .HKD,
                                        payType: .NORMAL_PAYMENT,
                                        orderRef: "beta_jo1730KHJ",
                                        payMethod: payMethod,
                                        lang: .ENGLISH,
                                        merchantId: "88146903",
                                        remark: "",
                                        payRef: "",
                                        resultpage: "F",
                                        showCloseButton: false,
                                        extraData :  [:])
        
        paySDK.process()
    }
    
    // MARK: -
    func toJson(result: PayResult) -> String {
        let dic = [
            "amount":result.amount,
            "successCode":result.successCode,
            "maskedCardNo":result.maskedCardNo,
            "authId":result.authId,
            "cardHolder":result.cardHolder,
            "currencyCode":result.currencyCode,
            "errMsg":result.errMsg,
            "ord":result.ord,
            "payRef":result.payRef,
            "prc":result.prc,
            "ref":result.ref,
            "src":result.src,
            "transactionTime":result.transactionTime,
            "descriptionStr":result.descriptionStr
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)!
        return jsonStr
    }
    
    func toQueryJson(result: TransQueryResults) -> String {
        if result.detail != nil {
            let dic = [
                "amount":result.detail?[0].amt,
                "successCode":result.detail?[0].successcode,
                "ipCountry":result.detail![0].ipCountry,
                "authId":result.detail![0].authId,
                "cardIssuingCountry":result.detail![0].cardIssuingCountry,
                "currencyCode":result.detail![0].cur,
                "errMsg":result.detail![0].errMsg,
                "ord":result.detail![0].ord,
                "payRef":result.detail![0].payRef,
                "prc":result.detail![0].prc,
                "ref":result.detail![0].ref,
                "src":result.detail![0].src,
                "transactionTime":result.detail![0].txTime,
                "descriptionStr":result.detail![0].description
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)!
            return jsonStr
        }
        return ""
    }
    
    func toPayMethodJson(result: PaymentOptionsDetail) -> String {
        let dic = [
            "card":result.methods.card[0],
            "netbanking":result.methods.netbanking[0],
            "other": result.methods.other[0]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)!
        return jsonStr
    }
}

extension ViewController: PaySDKDelegate {
    func paymentResult(result: PayResult) {
        print(self.toJson(result: result))
    }
    
    func transQueryResults(result: TransQueryResults) {
        print(self.toQueryJson(result: result))
    }
    
    func payMethodOptions(method: PaymentOptionsDetail) {
        print(self.toPayMethodJson(result: method))
    }
}

