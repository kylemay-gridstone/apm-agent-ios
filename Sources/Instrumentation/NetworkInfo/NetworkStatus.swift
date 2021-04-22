// Copyright © 2021 Elasticsearch BV
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import Foundation
import CoreTelephony
import Network
import Reachability

public class NetworkStatus {
    public private(set) var networkInfo : CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
    public private(set) var reachability :Reachability
    public init() throws {
        try reachability = Reachability()
        try reachability.startNotifier()
    }
    
    deinit {
        reachability.stopNotifier()
    }

    public func getConnection() -> (String, CTCarrier?) {
        switch reachability.connection {
        case .wifi:
            return ("wifi",nil)
        case .cellular:
            if #available(iOS 13.0, *) {
                if let value = networkInfo.serviceCurrentRadioAccessTechnology?[networkInfo.dataServiceIdentifier!] {
                    return (simpleConnectionName(connectionType: value), networkInfo.serviceSubscriberCellularProviders?[networkInfo.dataServiceIdentifier!])
                }
            } else {
                if let radioType = networkInfo.currentRadioAccessTechnology {
                return (simpleConnectionName(connectionType: radioType), networkInfo.subscriberCellularProvider)
                }
            }
            return ("cell", nil)
        case .unavailable:
            return ("unavailable", nil)
        }
    }
    
    func simpleConnectionName(connectionType: String) -> String {
        switch connectionType {
        case "CTRadioAccessTechnologyEdge", "CTRadioAccessTechnologyCDMA1x","CTRadioAccessTechnologyGPRS":
            return "2G"
        case "CTRadioAccessTechnologyWCDMA", "CTRadioAccessTechnologyHSDPA", "CTRadioAccessTechnologyHSUPA", "CTRadioAccessTechnologyCDMAEVDORev0", "CTRadioAccessTechnologyCDMAEVDORevA", "CTRadioAccessTechnologyCDMAEVDORevB","CTRadioAccessTechnologyeHRPD":
            return "3G"
        case "CTRadioAccessTechnologyLTE":
            return "4G"
        case "CTRadioAccessTechnologyNRNSA", "CTRadioAccessTechnologyNR":
            return "5G"
            
        default:
            return "cell"
        }
    }
}
