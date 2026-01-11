/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author biacb
 */
public class Member {
    private String studentID , name ,  gender , parentID;

    public Member(String studentsID, String name, String gender, String parentID) {
        this.studentID = studentsID;
        this.name = name;
        this.gender = gender;
        this.parentID = parentID;
    }

    public String getStudentsID() {
        return studentID;
    }

    public void setStudentsID(String studentsID) {
        this.studentID = studentsID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getParentID() {
        return parentID;
    }

    public void setParentID(String parentID) {
        this.parentID = parentID;
    }

    @Override
    public String toString() {
        return "Member{" + "studentsID=" + studentID + ", name=" + name + ", gender=" + gender + ", parentID=" + parentID + '}';
    }
    
        
}
