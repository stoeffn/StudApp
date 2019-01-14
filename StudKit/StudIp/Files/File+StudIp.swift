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

import CoreData
import CoreSpotlight

extension File {
    // MARK: - Updating Children

    public func updateChildFiles(forced: Bool = false, completion: @escaping ResultHandler<Set<File>>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let context = managedObjectContext else { fatalError() }

        let updatedAt = \File.state.childFilesUpdatedAt
        update(lastUpdatedAt: updatedAt, expiresAfter: 60 * 10, forced: forced, completion: completion) { updaterCompletion in
            studIpService.api.requestDecoded(.folder(withId: self.id)) { (result: Result<FolderResponse>) in
                context.perform {
                    updaterCompletion(result.map { try self.updateChildFiles(from: $0) })
                }
            }
        }
    }

    func updateChildFiles(from response: FolderResponse) throws -> Set<File> {
        guard let context = managedObjectContext else { fatalError() }

        let folder = try response.coreDataObject(course: course, in: context)

        let searchableItems = folder.children
            .filter { !$0.isFolder }
            .map { $0.searchableItem }
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: folder.objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return folder.children
    }

    // MARK: - Managing Downloads

    @discardableResult
    public func download(completion: @escaping ResultHandler<URL>) -> Progress? {
        guard let context = managedObjectContext else { fatalError() }

        guard !state.isMostRecentVersionDownloaded else {
            completion(.success(localUrl(in: .fileProvider)))
            return nil
        }

        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .downloads))
        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .fileProvider))

        let downloadAt = Date()

        willChangeValue(for: \.state)
        state.isDownloading = true
        didChangeValue(for: \.state)

        let studIpService = ServiceContainer.default[StudIpService.self]
        let route = StudIpRoutes.fileContents(forFileId: id, externalUrl: externalUrl)
        let task = studIpService.api.download(route, to: localUrl(in: .downloads), startsResumed: false) { result in
            context.perform {
                self.willChangeValue(for: \.state)
                self.state.isDownloading = false
                self.didChangeValue(for: \.state)

                guard result.isSuccess else {
                    return completion(.failure(result.error))
                }

                self.downloadedBy.formUnion([User.current?.in(context)].compactMap { $0 })
                self.state.downloadedAt = downloadAt
                try? context.save()

                return completion(.success(self.localUrl(in: .fileProvider)))
            }
        }

        guard let downloadTask = task else { return nil }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: objectIdentifier.rawValue)
            NSFileProviderManager.default.register(downloadTask, forItemWithIdentifier: itemIdentifier) { _ in
                downloadTask.resume()
            }
            return downloadTask.progress
        }

        downloadTask.resume()
        return nil
    }

    public func removeDownload() throws {
        downloadedBy.subtract([User.current].compactMap { $0 })

        guard downloadedBy.isEmpty else { return }

        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: localUrl(in: .downloads))
        try? FileManager.default.removeItem(at: localUrl(in: .fileProvider))
        try managedObjectContext?.saveAndWaitWhenChanged()
    }

    // MARK: - Managing Metadata

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/download/force_download/0/\(id)/\(name)")
        else { return nil }
        return url
    }
}
