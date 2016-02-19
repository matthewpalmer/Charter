//
//  AppReducer.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import Foundation
import ReSwift

struct AppReducer: Reducer {
    typealias ReducerStateType = AppState
    
    func handleAction(action: Action, var state: AppState?) -> AppState {
        if action is MoveTo {
            let move = action as! MoveTo
            state?.nextRoute = move.route
        }
        
        if action is NextRouteAcknowledged {
            if let route = state?.nextRoute {
                state?.routeHistory.append(route)
            }
            
            state?.nextRoute = nil
        }
        
        if action is SetSelectedMailingList {
            state?.selectedMailingList = (action as! SetSelectedMailingList).list
        }
        
//        if action is SetSelectedThreadWithRootMessageID {
//            state?.selectedThreadWithRootMessageID = (action as! SetSelectedThreadWithRootMessageID).rootMessageID
//        }
        
        if action is SetEmailList {
            state?.emailList = (action as! SetEmailList).results
        }
        
        if action is SetEmailThread {
            state?.emailThread = (action as! SetEmailThread).thread
        }
        
        if action is SetMailingListIsRefreshing {
            let a = (action as! SetMailingListIsRefreshing)
            state?.mailingListIsRefreshing[a.mailingList] = a.isRefreshing
        }
        
        return state ?? AppState()
    }
}
