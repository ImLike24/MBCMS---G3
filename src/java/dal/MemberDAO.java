/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.List;
import model.Member;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

/**
 *
 * @author biacb
 */
public class MemberDAO extends DBContext {
    private final String CHECK_EXIST_NAME ="select * from Students where Name like ?";
    private final String GET_ALL_MEMBERS = "select * from Students";
    private final String LOGIN_MEMBER = "select * from Students where StudentID like ? and Name like ?";
    private final String REGISTER = "INSERT INTO Students (Name, Gender, ParentID) VALUES (?, ?, ?)";
    
    
    
    public List<Member> getAllMembers() {
        try {
            PreparedStatement stm = c.prepareStatement(GET_ALL_MEMBERS);
            ResultSet rs = stm.executeQuery();

            List<Member> ListMember = new ArrayList<>();

            while (rs.next()) {
                ListMember.add(new Member(rs.getString("studentID"),
                        rs.getString("Name"),
                        rs.getString("Gender"),
                        rs.getString("parentID")));

            }
            return ListMember;

        } catch (Exception e) {
            return null;
        }

}
    public Member Login(String studentID, String name) {
        try {
            PreparedStatement stm = c.prepareStatement(LOGIN_MEMBER);
            stm.setString(1, studentID);
            stm.setString(2, name);
            
            ResultSet rs = stm.executeQuery();
            if(rs.next()){
                return new Member(rs.getString("studentID"),
                        rs.getString("Name"),
                        rs.getString("Gender"),
                        rs.getString("parentID"));
                
            }
            return null;
            
            
        } catch (Exception e) {
            return null;
        }
        
    }
    
    private boolean checkExistName(String name){
        try {
            PreparedStatement stm = c.prepareStatement(CHECK_EXIST_NAME);
            stm.setString(1, name);
            ResultSet rs = stm.executeQuery();
            if(rs.next()){
                return true;
                
            }
            return false;
            
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean register( String name , String gender, String partentID){
        if (checkExistName(name)) {
            return false;
        }
        
        try {
            PreparedStatement stm = c.prepareStatement(REGISTER);
            
            stm.setString(1, name);
            stm.setString(2, gender);
            stm.setString(3, partentID);
            
            int check = stm.executeUpdate();
            if(check == 1){
                return true;
                
                
            }else{
                return false;
            }
            
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        
    }
    
    
public static void main(String[] args) {
        MemberDAO memberDao = new MemberDAO();
        memberDao.register( "bui quang anh", "m", "3");
        System.out.println(memberDao.Login("1", "Le Minh A"));
        List<Member> members = memberDao.getAllMembers();
//        for (Member member : members) {
//            System.out.println(member.toString());
//            
//        }
    }
}
