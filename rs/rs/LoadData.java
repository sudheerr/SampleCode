package rs.rs;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Iterator;
import java.util.List;
import java.util.Queue;

public class LoadData {
	public static boolean setupDB(Connection con) {
		Statement stmt;

		try {
			stmt = con.createStatement();
			stmt.execute("CREATE TABLE QUEUE(REQUESTID INT, PROSPECTID INT,"
					+ " PROSPECTNAME VARCHAR, IPROCESSWFID VARCHAR,"
					+ " WORKFLOWID INT, STATUS VARCHAR, CLASSIFICATION VARCHAR, DUEDATE DATE);");

			stmt.close();
			return true;
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			return false;
		}
	}

	public static void cleanDatabase(Connection con) {
		Statement stmt;
		try {
			stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery("SELECT COUNT(*) AS COUNT FROM QUEUE;");
			while (rs.next()) {
				System.out.println("COUNT= " + rs.getInt("COUNT"));
			}
			stmt.close();
			System.out.println("closed:");
		} catch (SQLException e) {
			System.out.println("sqlex:" +e.getMessage());
		}
	}
	
	public static void testInserts(Connection con) {
		Statement stmt;
		try {
			stmt = con.createStatement();
			ResultSet rs = stmt
					.executeQuery("select REQUESTID, PROSPECTID from QUEUE");
			while (rs.next()) {
				System.out.println("REQUESTID= " + rs.getInt("REQUESTID")
						+ " PROSPECTID= " + rs.getInt("PROSPECTID"));
			}
			stmt.close();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
		}
	}

	/*public static void insertQueueRecords(Connection con) {
		PreparedStatement insertQueue = null;
		Queue q = null;
		List<Queue> queues = null;
		String insertString = "INSERT INTO QUEUE "
				+ "(REQUESTID, PROSPECTID, PROSPECTNAME, IPROCESSWFID, WORKFLOWID, STATUS, CLASSIFICATION, DUEDATE) VALUES "
				+ "(?,?,?,?,?,?,?,?)";

		try {
			insertQueue = con.prepareStatement(insertString);

			queues = ReadQueueJson.readjson();

			logger.info("size " + queues.size());

			if (queues != null) {
				Iterator<Queue> it = queues.iterator();
				while (it.hasNext()) {
					q = it.next();

					insertQueue.setInt(1, q.getRequestId());
					insertQueue.setInt(2, q.getProspectId());
					insertQueue.setString(3, q.getProspectName());
					insertQueue.setString(4, q.getIprocessWfId());
					insertQueue.setInt(5, q.getWorkflowId());
					insertQueue.setString(6, q.getStatus());
					insertQueue.setString(7, q.getClassification());
					insertQueue.setDate(8, new java.sql.Date(q.getDuedate().getTime()));

					insertQueue.executeUpdate();
				}
			}

		} catch (SQLException e) {
			System.out.println(e.getMessage());
		}
	}*/

}