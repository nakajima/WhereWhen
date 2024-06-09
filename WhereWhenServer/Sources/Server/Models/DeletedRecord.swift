import Foundation

struct DeletedRecord: Codable {
	let uuid: String
	let type: String
	let deletedAt: Date
}
