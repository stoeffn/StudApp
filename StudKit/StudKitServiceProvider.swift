//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

public class StudKitServiceProvider: ServiceProvider {
    public init(context: Targets.Context) {
        Targets.currentContext = context
    }

    func provideReachabilityService() -> ReachabilityService {
        let service = ReachabilityService()
        service.isActive = Distributions.current != .uiTest
        return service
    }

    func provideJsonEncoder() -> JSONEncoder {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        return decoder
    }

    func provideJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", appGroupIdentifier: App.groupIdentifier)
    }

    func provideStudIpService() -> StudIpService {
        return Distributions.current == .uiTest ? MockStudIpService() : StudIpService()
    }

    public func registerServices(in container: ServiceContainer) {
        container[JSONEncoder.self] = provideJsonEncoder()
        container[JSONDecoder.self] = provideJsonDecoder()
        container[KeychainService.self] = KeychainService()
        container[ReachabilityService.self] = provideReachabilityService()
        container[StoreService.self] = StoreService()
        container[StorageService.self] = StorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[PersistentHistoryService.self] = PersistentHistoryService()
        container[StudIpService.self] = provideStudIpService()
        container[HookService.self] = HookService()
    }
}
