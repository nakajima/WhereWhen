import Foundation
import ServerData

@Model(table: "deleted_records") struct DeletedRecord: Codable, Sendable {
	@Column(.primaryKey(autoIncrement: true)) var id: Int?
	@Column(.unique) var uuid: String
	var type: String
	var deletedAt: Date
}
