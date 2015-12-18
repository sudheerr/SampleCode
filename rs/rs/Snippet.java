package rs.rs;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Snippet {
	public static void main(String[] args) {
		String connectionURL = "jdbc:h2:mem/test;user=sa";
		try {
			Class.forName("org.h2.Driver");
			Connection con = DriverManager.getConnection(connectionURL);
			System.out.println("Connection established");
			LoadData.setupDB(con);
			LoadData.cleanDatabase(con);
			//LoadData.setupDB(con);
			
			//LoadData.testInserts(con);

			con.close();
			System.out.println("Connection closed successfully");
		} catch (ClassNotFoundException e) {
			System.out.println(e.getMessage());
		} catch (SQLException e) {
			System.out.println(e.getMessage());
		}
	}
}

