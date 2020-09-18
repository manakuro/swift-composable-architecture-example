import UIKit
import Combine
import Dispatch
import Foundation

//Just(1)
//  .debounce(for: 1, scheduler: DispatchQueue.main)
//


let s = DispatchQueue.testScheduler

s.schedule {
  print("")
}
