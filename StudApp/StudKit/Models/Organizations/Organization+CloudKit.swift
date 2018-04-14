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

import CloudKit
import CoreData

extension Organization {
    static let recordType = entity.rawValue

    private static let ckDatabase = CKContainer(identifier: App.iCloudContainerIdentifier).database(with: .public)

    // MARK: - Errors

    @objc(OrganizationErrors)
    enum Errors: Int, LocalizedError {
        case internalError, networkError

        init?(from error: Error?) {
            switch error {
            case nil:
                return nil
            case CKError.networkUnavailable?, CKError.networkFailure?:
                self = .networkError
            default:
                self = .internalError
            }
        }

        var errorDescription: String? {
            switch self {
            case .internalError:
                return "Unfortunately, there was an internal error.".localized
            case .networkError:
                return "There seems to be a problem with the internet connection.".localized
            }
        }
    }

    // MARK: - Predicates

    private static let enabledPredicate = Distributions.current == .appStore
        ? NSPredicate(format: "isEnabled == YES")
        : NSPredicate(format: "isEnabledInTestFlight == YES")

    private var idPredicate: NSPredicate {
        return NSPredicate(format: "recordID == %@", CKRecordID(recordName: id))
    }

    // MARK: - Updating

    static func update(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Organization]>) {
        var organizations = [OrganizationRecord]()

        let query = CKQuery(recordType: Organization.recordType, predicate: Organization.enabledPredicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.apiUrl, .title]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            let result = Result(organizations, error: Errors(from: error)).map {
                try Organization.update(fetchRequest(), with: $0, in: context) { try $0.coreDataObject(in: context) }
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            organizations.append(organization)
        }

        ckDatabase.add(operation)
    }

    static func updateIconThumbnails(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Void>) {
        let query = CKQuery(recordType: Organization.recordType, predicate: Organization.enabledPredicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.iconThumbnail]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .utility
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async { completion(Result((), error: Errors(from: error))) }
        }
        operation.recordFetchedBlock = { record in
            guard
                let iconThumbnailAsset = record[OrganizationRecord.Keys.iconThumbnail.rawValue] as? CKAsset,
                let organization = try? Organization.fetch(byId: record.recordID.recordName, in: context)
            else { return }

            DispatchQueue.main.async {
                organization?.iconThumbnailData = try? Data(contentsOf: iconThumbnailAsset.fileURL)
            }
        }

        ckDatabase.add(operation)
    }

    func updateIcon(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Void>) {
        let query = CKQuery(recordType: Organization.recordType, predicate: idPredicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.icon]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .utility
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async { completion(Result((), error: Errors(from: error))) }
        }
        operation.recordFetchedBlock = { record in
            guard
                let iconThumbnailAsset = record[OrganizationRecord.Keys.icon.rawValue] as? CKAsset,
                let organization = context.object(with: self.objectID) as? Organization
            else { return }

            DispatchQueue.main.async {
                organization.iconData = try? Data(contentsOf: iconThumbnailAsset.fileURL)
            }
        }

        Organization.ckDatabase.add(operation)
    }

    func apiCredentials(completion: @escaping ResultHandler<(consumerKey: String, consumerSecret: String)>) {
        let query = CKQuery(recordType: Organization.recordType, predicate: idPredicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.consumerKey, .consumerSecret]

        var consumerKeyAndSecret: (String, String)?

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async { completion(Result(consumerKeyAndSecret, error: Errors(from: error))) }
        }
        operation.recordFetchedBlock = { record in
            guard
                let consumerKey = record[OrganizationRecord.Keys.consumerKey.rawValue] as? String,
                let consumerSecret = record[OrganizationRecord.Keys.consumerSecret.rawValue] as? String
            else { return }
            consumerKeyAndSecret = (consumerKey, consumerSecret)
        }

        Organization.ckDatabase.add(operation)
    }
}
